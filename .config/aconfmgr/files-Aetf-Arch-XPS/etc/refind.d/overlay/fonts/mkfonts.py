#!/usr/bin/env python
from __future__ import print_function, division, absolute_import

import subprocess as sp

FONTS = [
    ("Source-Code-Pro", 32, "-9%"),
    ("Source-Code-Pro", 20, "-5%"),
    ("Source-Code-Pro", 16, "-4%"),
]

for name, size, yoff in FONTS:
    filename = '{}-{}.png'.format(name.lower(), size)
    sp.check_call(['refind-mkfont', name, str(size), str(yoff), filename])
    sp.check_call(['file', filename])
