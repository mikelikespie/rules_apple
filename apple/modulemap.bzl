# Copyright 2016 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def submodule(
    name,
    explicit = False,
    hdrs = [],
    textual_hdrs = [],
    export = ["*"],
):
  """Creates struct to represent a clang submodule

  Args:
      name: Name of the clang submodule
      explicit: If set to true, will become an explicit submodule
      hdrs: List of headers in this submodule
      textual_hdrs: List of tetual headers in this submodule
      export: For each element in this list, will "export". Default is "*"
  """
  return struct(
    name=name,
    explicit=explicit,
    hdrs = hdrs,
    textual_hdrs = textual_hdrs,
    export = export,
  )

def module(
    name,
    submodules = [],
    hdrs = [],
    textual_hdrs = [],
    use = [],
    export = ["*"],
    umbrella_header = None,
):
  """Creates struct to represent a submodule

    Args:
        name: Name of the clang submodule
        submodules: list of submodules to add to this modulemap
        hdrs: List of headers in this submodule
        textual_hdrs: List of tetual headers in this submodule
        export: For each element in this list, will "export". Default is "*"
        use: use definitions which aren't external
  """
  return struct(
    name=name,
    submodules=submodules,
    hdrs = hdrs,
    textual_hdrs = textual_hdrs,
    use=use,
    export = export,
    umbrella_header = umbrella_header,
  )


def _rel_path(relfrom, file, relbase=None):
  segments_to_exec_path = len(relfrom.dirname.split("/"))
  if relfrom.dirname == file.dirname:
    return file.basename

  leading_periods = "../" * segments_to_exec_path

#  if relbase:
#    return leading_periods + "fake_hmap_root/" + relbase + "/" + file.basename
#  else:
  return leading_periods + file.path

def _submodule_contents(output, module, relbase=None):
  contents = '  ' + ('explicit ' if module.explicit else '') + 'module ' + module.name + ' {\n'

  contents += _module_common_contents(
    output=output,
    hdrs=module.hdrs,
    textual_hdrs=module.textual_hdrs,
    export=module.export,
    indent="    ",
    relbase=relbase,
  )

  contents += '}\n'

  return contents


def _module_contents(output, module, relbase=None,):
  contents = 'module ' + module.name + ' {\n'

  if module.umbrella_header:
    contents += 'umbrella header "' + _rel_path(output, module.umbrella_header, relbase=relbase) + '"\n'

  contents += _module_common_contents(
    output=output,
    hdrs=module.hdrs,
    textual_hdrs=module.textual_hdrs,
    export=module.export,
    indent="  ",
    relbase = relbase,
  )

  contents += '\n'.join([_submodule_contents(output, s, relbase=relbase) for s in module.submodules]) + '\n'

  contents += ''.join(['  use "' + u + '"\n' for u in module.use])

  if module.umbrella_header:
    contents += 'module * { export * }\n'

  contents += '}\n'

  return contents

def _module_common_contents(
    output,
    hdrs,
    textual_hdrs,
    export,
    indent,
    relbase=None,
):
  export_lines = ["export " + e for e in export]
  hdrs_lines = ['header "' + _rel_path(output, h, relbase=relbase) + '"' for h in hdrs]
  textual_hdrs_lines = ['textual header "' + _rel_path(output, h, relbase=relbase) + '"' for h in textual_hdrs]

  return "".join([indent + l + "\n" for l in hdrs_lines + textual_hdrs_lines + export_lines])

def modulemap_action(
    ctx,
    output,
    modules,
    external_modules = {},
    relbase=None,
    ):
  """Adds action to create modulemap.

    Args:
      ctx: context object
      modules: List of modulemaps to put in file. Recommended to use helper
        functions `module` and `submodule` to create this
      output: Output file where modulemap will be located
      external_modules: Paths to external modules to include
  """

  modules_contents = [_module_contents(output, m, relbase=relbase) for m in modules]
  extern_contents = [
      'extern module ' + name + ' "' + _rel_path(output, location) + '"'
       for name, location
       in external_modules.items()]

  content = "\n".join(modules_contents + extern_contents)

  ctx.file_action(output=output, content=content)
