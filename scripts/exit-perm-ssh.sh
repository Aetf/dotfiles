#! /usr/bin/bash

DIR=~/.ssh/masters

shopt -s nullglob

for conn in $DIR/*; do
    name=$(basename $conn)
    name=${name%%:*}
    ssh -O exit $name > /dev/null 2>&1
done
