#!/usr/bin/env python
from __future__ import print_function

import os
import re
import sys


aliases_path = os.path.join(sys.path[0], '.bash_aliases')
completion_path = '/usr/share/bash-completion/completions/git'
pattern = re.compile(r"alias (\w[\w-]*)='git(?: (\w[\w-]*).*)?'")
exclude_cmds = {'blame', 'gc', 'rev-parse', 'update-index'}

with open(aliases_path) as aliases:
    print('# Git')
    print('[ -f {0} ] && . {0}'.format(completion_path))

    for line in aliases:
        m = pattern.match(line)
        if not m:
            continue

        alias, cmd = m.groups()
        if not cmd:
            print('__git_complete {} __git_main'.format(alias))
        elif cmd not in exclude_cmds:
            print('__git_complete {} _git_{}'.format(alias, cmd.replace('-', '_')))
