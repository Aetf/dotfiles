#!/bin/bash
exec /usr/bin/java "$@" 2> >(grep -v "^Picked up _JAVA_OPTIONS:" >&2)
