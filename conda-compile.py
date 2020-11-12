#!/usr/bin/env python3
# analagous to pip-compile, except that it receives input from stdin
import json
from pathlib import Path
import subprocess
import sys


def run(cmd, **kwargs):
    kwargs.setdefault('check', True)
    kwargs.setdefault('text', True)
    sys.stderr.write(' '.join(cmd) + '\n')
    sys.stderr.flush()
    return subprocess.run(cmd, **kwargs)



packages_in = Path('/tmp/packages.in')
packages_in.write_text(sys.stdin.read())

# ensure clean environment
create = run(
   ['conda', 'create', '--name', 'packages',
    '--no-default-packages', '--yes', '--quiet'],
   stdout=sys.stderr.buffer,
)

cmd = [
    # install into clean env
    'conda', 'install', '--name', 'packages',
    '--file', str(packages_in),
    # the channel order here is important, it determines priority
    '--channel', 'r', 
    '--channel', 'conda-forge',
    '--dry-run',    # do not actually install
    '--verbose',
    '--json',       # we want json
]

process = run(cmd, stdout=subprocess.PIPE)
json_packages = json.loads(process.stdout)  
all_pkgs = json_packages['actions']['FETCH'] + json_packages['actions']['LINK']

packages = []
for pkg in all_pkgs:
    packages.append('{}={}'.format(pkg['name'], pkg['version']))

packages.sort()
print('\n'.join(packages))
