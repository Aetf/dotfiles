#!/usr/bin/bash
gcc -fpreprocessed -dD -E -P $1 > $2
