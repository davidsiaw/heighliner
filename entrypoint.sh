#!/bin/sh

# Do NOT collapse "$@" into a string and re-run it through `sh -c`: that parses
# the arguments a second time, which strips quotes and splits on spaces. It
# mangled things like `heighliner set cert-1password-fields '{"key":"privkey"}'`
# into `{key:privkey}`. Passing "$@" straight through keeps argv intact.
cd "$CONTEXT_DIR" || exit 1   # Move to the context directory
exec heighliner "$@"          # Execute Heighliner
