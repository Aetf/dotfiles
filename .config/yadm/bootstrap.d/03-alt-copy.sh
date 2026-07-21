#!/usr/bin/env bash

# Alternates must be real copies, not symlinks: systemd rejects unit files
# that are symlinks whose target basename is not a valid unit name, which
# is exactly what ##h.<host> alternates of .service/.timer/.container
# files look like. Consequence: edit the ##-suffixed source, never the
# generated copy, then re-run `yadm alt`.
set -eu

yadm config yadm.alt-copy true
yadm alt
