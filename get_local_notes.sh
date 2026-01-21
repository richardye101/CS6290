#!/bin/bash

# Rysnc all notes back to `notes` folder
# --dry-run \
rsync -av \
  --exclude='.DS_Store' \
  --exclude='CS6290 Lectures/' \
  ~/Documents/Vault/GATECH/CS6290/ notes/ 
