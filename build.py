#!/usr/bin/env python

import json
import os
from subprocess import call

with open('dub.json', 'r') as f:
    dub = f.read()

dub = json.loads(dub)

packages = [ dub["name"] ]
for sub in dub["subPackages"]:
    packages.append(packages[0] + ":" + sub["name"])

for package in packages:
    call(["dub", "build", package])
    
os.system('mv -vt bin/ nym* *.a')
