#!/usr/bin/env python3
"""
Convert a Radicale 1.x storage ("filesystem": one file per collection) to the
"multifilesystem" layout of Radicale 3 (one folder per collection, one file
per item), like "radicale --export-storage" of Radicale 1.1 did.

Nothing is dropped silently: duplicate or missing UIDs are rewritten, names
refused by Radicale 3 are changed, and each change is reported as a warning.
The source is only read; the destination is written to a temporary folder
and moved into place at the end.

Usage: migrate_radicale1_storage.py [--users FILE] SOURCE DESTINATION
  --users FILE  existing usernames, one per line, to fix the case of user folders
"""

import argparse
import json
import os
import re
import shutil
import sys
import tempfile
import uuid

ITEM_TAGS = ("VEVENT", "VTODO", "VJOURNAL", "VCARD", "VTIMEZONE")
VCS_FOLDERS = (".git", ".hg", ".svn", ".bzr")

warnings = []
stats = {"collections": 0, "items": 0}


def warn(message):
    warnings.append(message)
    print("WARNING: " + message, file=sys.stderr)


def is_safe_name(name):
    """Same rule as pathutils.is_safe_filesystem_path_component in Radicale 3."""
    return (bool(name) and "/" not in name and "\0" not in name
            and name not in (".", "..") and not name.startswith(".")
            and not name.endswith("~"))


def make_safe_name(name, used):
    """Closest name accepted by Radicale 3 that is not in `used`."""
    safe = name.replace("/", "_").replace("\0", "")
    if safe.startswith("."):
        safe = "_" + safe[1:]
    if safe.endswith("~"):
        safe = safe[:-1] + "_"
    if not safe or safe in (".", ".."):
        safe = str(uuid.uuid4())
    candidate, counter = safe, 2
    while candidate in used:
        candidate = "%s-%d" % (safe, counter)
        counter += 1
    return candidate


def read_text(path):
    with open(path, "rb") as f:
        data = f.read()
    try:
        return data.decode("utf-8")
    except UnicodeDecodeError:
        warn("%s is not valid UTF-8, decoded as Latin-1" % path)
        return data.decode("latin-1")


def read_props(path):
    props_path = path + ".props"
    if not os.path.isfile(props_path):
        return {}
    try:
        props = json.loads(read_text(props_path))
    except ValueError as e:
        warn("ignoring unreadable properties file %s: %s" % (props_path, e))
        return {}
    if not isinstance(props, dict):
        warn("ignoring unexpected properties in %s" % props_path)
        return {}
    return props


def write_props(dest_path, props):
    with open(os.path.join(dest_path, ".Radicale.props"), "w", encoding="utf-8") as f:
        json.dump(props, f)


def unfold(text):
    """Unfold continuation lines (Radicale 1 wrote LF or CRLF)."""
    return re.sub("\r?\n[ \t]", "", text).splitlines()


def property_value(lines, name):
    for line in lines:
        if line.upper().startswith(name + ":"):
            return line.split(":", 1)[1].strip()
    return None


def set_uid(lines, uid):
    """Return the component lines with their UID replaced (or added)."""
    out, replaced = [], False
    for line in lines:
        if not replaced and line.upper().startswith("UID:"):
            out.append("UID:%s" % uid)
            replaced = True
        else:
            out.append(line)
    if not replaced:
        out.insert(1, "UID:%s" % uid)
    return out


def collection_tag(path, props, lines):
    """Collection type, guessed like Radicale 1 did."""
    tag = props.get("tag")
    if tag in ("VCALENDAR", "VADDRESSBOOK"):
        return tag
    for line in lines:
        upper = line.strip().upper()
        if upper in ("BEGIN:VCARD", "BEGIN:VADDRESSBOOK"):
            return "VADDRESSBOOK"
        if upper == "BEGIN:VCALENDAR":
            return "VCALENDAR"
    return "VADDRESSBOOK" if path.endswith(".vcf") else "VCALENDAR"


def parse_collection(path, lines):
    """Headers, timezones and components of a collection, as Radicale 1.1 parsed them."""
    headers = []
    for line in lines[1:]:
        if line.upper().startswith(("BEGIN:", "END:")):
            break
        headers.append(line)

    timezones = {}
    components = []
    in_item = False
    item_tag = None
    item_lines = []
    for line in lines:
        upper = line.upper()
        if not in_item and upper.startswith("BEGIN:"):
            tag = upper[len("BEGIN:"):].strip()
            if tag in ITEM_TAGS:
                in_item = True
                item_tag = tag
                item_lines = []
        if in_item:
            item_lines.append(line)
            if upper.startswith("END:%s" % item_tag):
                in_item = False
                if item_tag == "VTIMEZONE":
                    tzid = property_value(item_lines, "TZID") or str(uuid.uuid4())
                    timezones[tzid] = item_lines
                else:
                    components.append((item_tag, item_lines))
    if in_item:
        warn("%s ends with an unterminated %s component, which was never "
             "visible to clients and is not converted" % (path, item_tag))
    return headers, list(timezones.values()), components


def component_name(lines):
    """X-RADICALE-NAME, else UID, like Radicale 1."""
    name = property_value(lines, "X-RADICALE-NAME") or property_value(lines, "UID")
    return name.strip("{}") if name else None


def group_components(path, tag, components):
    """Items of a collection, each with a UID of its own."""
    items = []
    by_uid = {}
    for comp_tag, comp_lines in components:
        if (tag == "VADDRESSBOOK") != (comp_tag == "VCARD"):
            warn("%s: a %s cannot be stored in a %s collection with Radicale 3 "
                 "and is not converted (it stays in the copy of the Radicale 1 data)"
                 % (path, comp_tag, tag))
            continue
        name = component_name(comp_lines)
        uid = property_value(comp_lines, "UID")
        if tag == "VCALENDAR" and uid:
            # Recurrence overrides share the UID of their event
            key = (comp_tag, uid)
            if key in by_uid:
                by_uid[key]["components"].append(comp_lines)
                continue
            item = {"name": name, "uid": uid, "components": [comp_lines]}
            by_uid[key] = item
        else:
            item = {"name": name, "uid": uid or name, "components": [comp_lines]}
        items.append(item)

    used_uids = set()
    for item in items:
        uid = item["uid"]
        if not uid or uid in used_uids:
            new_uid = str(uuid.uuid4())
            if uid:
                warn("%s: two items share the UID %r, one of them gets the new UID %s"
                     % (path, uid, new_uid))
            uid = new_uid
        used_uids.add(uid)
        if uid != item["uid"] or any(property_value(c, "UID") != uid for c in item["components"]):
            item["components"] = [set_uid(c, uid) for c in item["components"]]
        item["uid"] = uid
    return items


def convert_leaf(source_path, dest_path, props):
    text = read_text(source_path)
    lines = unfold(text)
    tag = collection_tag(source_path, props, lines)
    headers, timezones, components = parse_collection(source_path, lines)
    items = group_components(source_path, tag, components)

    os.makedirs(dest_path)
    props = dict(props)
    props["tag"] = tag
    write_props(dest_path, props)

    if tag == "VCALENDAR":
        extension = ".ics"
        if not any(h.upper().startswith("VERSION:") for h in headers):
            headers.insert(0, "VERSION:2.0")
        if not any(h.upper().startswith("PRODID:") for h in headers):
            headers.insert(0, "PRODID:-//Radicale//NONSGML Radicale Server//EN")
    else:
        extension = ".vcf"

    used = set()
    for item in items:
        name = item["name"]
        if name and is_safe_name(name) and name not in used:
            filename = name
        else:
            filename = make_safe_name("%s%s" % (item["uid"], extension), used)
        used.add(filename)
        if tag == "VCALENDAR":
            out = ["BEGIN:VCALENDAR"] + headers
            for tz_lines in timezones:
                out.extend(tz_lines)
            for comp_lines in item["components"]:
                out.extend(comp_lines)
            out.append("END:VCALENDAR")
        else:
            out = list(item["components"][0])
        with open(os.path.join(dest_path, filename), "w", encoding="utf-8", newline="") as f:
            f.write("\r\n".join(out) + "\r\n")
        stats["items"] += 1

    stats["collections"] += 1
    print("INFO: converted %s (%s, %d items)" % (source_path, tag, len(items)))


def entries_of(source_path):
    """Collections of a Radicale 1 folder."""
    for entry in sorted(os.listdir(source_path)):
        entry_path = os.path.join(source_path, entry)
        if entry in VCS_FOLDERS and os.path.isdir(entry_path):
            print("INFO: skipping version control folder %s" % entry_path)
            continue
        if entry.endswith(".props") and not os.path.isdir(entry_path):
            continue
        if os.path.islink(entry_path):
            warn("%s is a symbolic link and is not converted" % entry_path)
            continue
        if not (os.path.isdir(entry_path) or os.path.isfile(entry_path)):
            continue
        yield entry, entry_path


def convert_node(source_path, dest_path, users=None):
    """`users` is only given for the root folder."""
    os.makedirs(dest_path, exist_ok=True)
    if users is None:
        props = read_props(source_path)
        if "tag" in props:
            # Radicale 3 rejects tagged folders that have children
            del props["tag"]
        if props:
            write_props(dest_path, props)

    entries = list(entries_of(source_path))
    used = set()
    renames = {}
    if users is not None:
        # Radicale 1 kept the login as typed, Radicale 3 uses the username
        names = {entry for entry, _ in entries}
        by_lower = {u.lower(): u for u in users}
        for entry, entry_path in entries:
            if not os.path.isdir(entry_path) or not users or entry in users:
                continue
            user = by_lower.get(entry.lower())
            if user and user not in names and user not in renames.values():
                warn("user folder %s renamed to %s, the YunoHost username" % (entry, user))
                renames[entry] = user
            elif user:
                warn("user folder %s and %s both exist: %s is converted under its own "
                     "name, which %s cannot access with Radicale 3 (its data stays in "
                     "the copy of the Radicale 1 data)" % (entry, user, entry, user))
            else:
                warn("user folder %s does not match any YunoHost user: it is converted, "
                     "but nobody will be able to access it" % entry)
        used.update(entry for entry, _ in entries if entry not in renames)
        used.update(renames.values())

    for entry, entry_path in entries:
        target = renames.get(entry, entry)
        if not is_safe_name(target):
            target = make_safe_name(target, used)
            warn("%s renamed to %s, a name Radicale 3 accepts (its address changes)"
                 % (entry_path, target))
        used.add(target)
        if users is not None and os.path.isfile(entry_path):
            warn("%s is not inside a user folder: it is converted, but nobody will "
                 "be able to access it" % entry_path)
        if os.path.isdir(entry_path):
            convert_node(entry_path, os.path.join(dest_path, target))
        else:
            convert_leaf(entry_path, os.path.join(dest_path, target), read_props(entry_path))


def main():
    parser = argparse.ArgumentParser(description="Convert a Radicale 1.x storage to the Radicale 3 layout.")
    parser.add_argument("--users", help="file with one existing username per line")
    parser.add_argument("source")
    parser.add_argument("destination")
    args = parser.parse_args()
    source = os.path.abspath(args.source)
    destination = os.path.abspath(args.destination)

    users = []
    if args.users:
        with open(args.users, encoding="utf-8") as f:
            users = [line.strip() for line in f if line.strip()]

    if not os.path.isdir(source):
        print("ERROR: source folder %s does not exist" % source, file=sys.stderr)
        return 1
    if os.path.exists(destination) and os.listdir(destination):
        print("ERROR: destination folder %s is not empty" % destination, file=sys.stderr)
        return 1

    parent = os.path.dirname(destination)
    os.makedirs(parent, exist_ok=True)
    temp = tempfile.mkdtemp(prefix=".radicale-migration-", dir=parent)
    try:
        convert_node(source, os.path.join(temp, "collection-root"), users=users)
        if os.path.exists(destination):
            os.rmdir(destination)
        os.rename(temp, destination)
    except Exception as e:
        shutil.rmtree(temp, ignore_errors=True)
        print("ERROR: conversion failed: %s: %s" % (type(e).__name__, e), file=sys.stderr)
        return 1

    print("INFO: converted %d collections and %d items, %d warnings"
          % (stats["collections"], stats["items"], len(warnings)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
