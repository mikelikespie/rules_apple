

def _make_headermap_string(mappings):
  return "\n".join([k + ":" + v for k,v in mappings])

def _make_private_headermap(ctx):
  text_hmap = ctx.new_file(ctx.label.name + ".hmap.txt")

  mapping = []

  for hdr in ctx.files.hdrs:
    dest_path = hdr.path
    mapping += [(hdr.basename,  dest_path)]

  if ctx.attr.additional_prefix:
    for hdr in ctx.files.hdrs:
      dest_path = hdr.path
      mapping += [(ctx.attr.additional_prefix + "/" + hdr.basename,  dest_path)]

  ctx.file_action(
    output=text_hmap,
    content = _make_headermap_string(mapping),
  )

  ctx.action(
      inputs = [text_hmap],
      outputs = [ctx.outputs.out],
      mnemonic = "MakeHeaderMap",
      executable = ctx.executable._make_header_map,
      arguments = [text_hmap.path, ctx.outputs.out.path],
  )

  objc_provider = apple_common.new_objc_provider(
      header=depset([ctx.outputs.out]),
      include=depset(["."]),
  )

  return struct(
      objc=objc_provider,
  )

def _make_framework_headermap(ctx):
  text_hmap = ctx.new_file(ctx.label.name + ".hmap.txt")

  mapping = []

  for hdr in ctx.files.hdrs:
    dest_path = hdr.path
    mapping += [((ctx.attr.prefix + "/"  if ctx.attr.prefix else "") + hdr.basename,  dest_path)]

  ctx.file_action(
    output=text_hmap,
    content = _make_headermap_string(mapping),
  )

  ctx.action(
      inputs = [text_hmap],
      outputs = [ctx.outputs.out],
      mnemonic = "MakeHeaderMap",
      executable = ctx.executable._make_header_map,
      arguments = [text_hmap.path, ctx.outputs.out.path],
  )

  objc_provider = apple_common.new_objc_provider(
      header=depset([ctx.outputs.out]),
      include=depset([ctx.outputs.out.path, "."]),
  )

  return struct(
      objc=objc_provider,
  )

def _make_preserving_headermap(ctx):
  text_hmap = ctx.new_file(ctx.label.name + ".hmap.txt")

  mapping = []

  # same as dirname
  build_rel_root = "/".join(ctx.build_file_path.split('/')[:-1])

  prefix_to_strip = build_rel_root + "/" + ctx.attr.stripped_prefix + "/"

  num_components = len(text_hmap.dirname.split('/'))
  maybe_relative = "../" * num_components

  for hdr in ctx.files.hdrs:
    dest_path = hdr.path
    stripped_path = hdr.path
    if stripped_path.startswith(prefix_to_strip):
      stripped_path = stripped_path[len(prefix_to_strip):]

    mapping += [(ctx.attr.prefix + "/" + stripped_path,  dest_path)]

  ctx.file_action(
    output=text_hmap,
    content = _make_headermap_string(mapping),
  )

  ctx.action(
      inputs = [text_hmap],
      outputs = [ctx.outputs.out],
      mnemonic = "MakeHeaderMap",
      executable = ctx.executable._make_header_map,
      arguments = [text_hmap.path, ctx.outputs.out.path],
  )

  objc_provider = apple_common.new_objc_provider(
      header=depset([ctx.outputs.out]),
      include=depset([ctx.outputs.out.path, "."]),
  )

  return struct(
      objc=objc_provider,
  )


make_preserving_headermap = rule(
    _make_preserving_headermap,
    attrs = {
            "_make_header_map": attr.label(
                default = Label("//tools/third_party:MakeHeaderMap"),
                allow_files = True,
                cfg = "host",
                executable = True,
            ),

        "hdrs": attr.label_list(allow_files = FileType([".h", ".hh", ".def"])),
        "prefix": attr.string(mandatory = True),
        "stripped_prefix": attr.string(mandatory = True),
    },
    outputs = {"out": "%{name}.hmap"},
    fragments = ["apple", "objc"],
    output_to_genfiles = True,
)

make_framework_headermap = rule(
    _make_framework_headermap,
    attrs = {
            "_make_header_map": attr.label(
                default = Label("//tools/headermap:MakeHeaderMap"),
                allow_files = True,
                cfg = "host",
                executable = True,
            ),

        "hdrs": attr.label_list(allow_files = FileType([".h", ".hh", ".def"])),
        "prefix": attr.string(mandatory = False),
    },
    outputs = {"out": "%{name}.hmap"},
    fragments = ["apple", "objc"],
    output_to_genfiles = True,
)

make_private_headermap = rule(
    _make_private_headermap,
    attrs = {
            "_make_header_map": attr.label(
                default = Label("//tools/headermap:MakeHeaderMap"),
                allow_files = True,
                cfg = "host",
                executable = True,
            ),

        "hdrs": attr.label_list(allow_files = FileType([".h", ".hh", ".def"])),
        "additional_prefix": attr.string(mandatory = False),
    },
    outputs = {"out": "%{name}.hmap"},
    output_to_genfiles = True,
)
