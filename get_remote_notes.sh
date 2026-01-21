#!/bin/bash

# Rysnc all notes back to `notes` folder
# --dry-run \
rsync -av \
  --exclude='.DS_Store' \
  notes/ ~/Documents/Vault/GATECH/CS6290/
