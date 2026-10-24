#!/bin/bash
# Storage hook of Radicale, run from the collections folder after each change
# $1: user who made the change

set -eu

git add --all
if ! git diff --cached --quiet; then
    git commit --quiet --message="Changes by ${1:-unknown}"
fi
