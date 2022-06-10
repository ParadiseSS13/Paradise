#!/bin/sh
exec "$(dirname "$0")/../bootstrap/python" -m dmi.merge_driver --posthoc "$@"
