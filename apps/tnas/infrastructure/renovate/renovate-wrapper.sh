#!/bin/sh
# Reads the secret file and uses 'tr' to delete all trailing newlines/returns/spaces
export RENOVATE_TOKEN=$(cat "$RENOVATE_TOKEN_FILE" | tr -d '\r\n ')
exec renovate "$@"
