#!/usr/bin/env python

import json
import os
import sys
from subprocess import call

def packages():
    with open('dub.json', 'r') as f:
        dub = f.read()
    dub = json.loads(dub)
    packages = [ dub["name"] ]
    for sub in dub["subPackages"]:
        packages.append(packages[0] + ":" + sub["name"])
    return packages

def build_do():
    for package in packages():
        call(["dub", "build", package])
    os.system('mv -vt bin/ nym* *.a')

def generate_makefile():
    makefile = 'components = '
    for package in packages():
        makefile += (package + ' ')
    makefile += "\n"
    makefile += ".PHONY: all build\n\n\n"
    makefile += "all: build\n\t" + '$(foreach var,$(components),dub build $(var);)' + "\n\t"
    makefile += '@mv -vt bin/ nym* *.a'
    with open('Makefile', 'w') as f:
        f.write(makefile)

def generate_build_sh():
    packages_sh = ''
    for package in packages():
        packages_sh += (package + ' ')
    build_sh  = 'for package in ' + packages_sh + '; do dub build $package; done' + "\n"
    build_sh += 'mv -vt bin/ nym* *.a'
    with open('build.sh', 'w') as f:
        f.write(build_sh)
    call(["chmod", "+x", "build.sh"])

argv = sys.argv
argv.pop(0)
print(argv)
if argv == []:
    build_do()
elif argv[0] == 'make':
    generate_makefile()
elif argv[0] == 'sh':
    generate_build_sh()
else:
    print("No arguments: builds project; make: generates Makefile; sh: generates build.sh")


