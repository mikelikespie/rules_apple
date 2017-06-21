"""Combines modulemaps into one. This works around "extern" modules that aren't named module.modulemap which is giving us issues sometime"""
import argparse

import re
import os

argument_parser = argparse.ArgumentParser(
    description='Merges modulemaps and updates relative paths.')

argument_parser.add_argument(
    "-m", "--module-map",
    help="Job name for jenkins",
    action="append",
    default=[],
)

argument_parser.add_argument(
    "-o", "--output-module-map",
    help="Resulting file",
    required=True,
)

args = argument_parser.parse_args()

header_re = re.compile(r'(header\s+["\'])(.*?)(["\'])')


def handle_line(module_dirname, new_dirname, line, out):
    spl = line.split()

    def sub_fn(m):
        orig_rel_path = m.group(2)
        orig_path = os.path.normpath(os.path.join(module_dirname, orig_rel_path))
        rel_path = os.path.relpath(orig_path, new_dirname)
        return m.group(1) + rel_path + m.group(3)
    
    if spl and spl[0] == 'extern':
        return

    out.write(header_re.sub(sub_fn, line))

new_dirname = os.path.dirname(args.output_module_map)
with open(args.output_module_map, 'w') as out:
    for input in args.module_map:
        module_dirname = os.path.dirname(input)
        print >>out, "// From " + input
        with open(input) as f:
            for l in f:
                handle_line(module_dirname, new_dirname, l, out)
        print >>out
