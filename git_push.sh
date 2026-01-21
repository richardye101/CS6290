#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 'Enter commit message here'"
    exit 1
fi

./get_local_notes.sh
git add .
git commit -m "$1"
git push
