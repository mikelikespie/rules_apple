load(":headermap.bzl", "make_framework_headermap", "make_private_headermap")
def _split_up_resources(resources):
  """Splits up resources into kwargs used for building. Lets one glob everything easily"""
  unqualified_resources = []
  strings = []
  storyboards = []
  xibs = []
  asset_catalogs = []
  datamodels = []

  for r in depset(resources):
    if r.endswith('.strings'):
      strings += [r]
    elif r.endswith('.xib'):
      xibs += [r]
    elif r.endswith('.storyboard'):
      storyboards += [r]
    elif '.xcdatamodeld/' in r:
      datamodels += [r]
    elif '.xcassets/' in r:
      asset_catalogs += [r]
    else:
      unqualified_resources += [r]

  return dict(
    asset_catalogs = asset_catalogs,
    resources = unqualified_resources,
    strings = strings,
    datamodels = datamodels,
    xibs = xibs,
    storyboards = storyboards,
  )


def _split_up_sources(source_files, public_headers, private_headers, requires_arc):
  srcs = []
  hdrs = []
  private_hdrs = []

  default_visibility_private = public_headers != None

  if private_headers == None:
    private_headers = []

  if public_headers == None:
    public_headers = []

  for s in source_files:
    if s.endswith('.h') or s.endswith('.hh') or s.endswith('.def'):
      if default_visibility_private:
        if s in public_headers:
          hdrs += [s]
        else:
          private_hdrs += [s]
      else:
        if s not in private_headers:
          hdrs += [s]
    else:
      srcs += [s]

  private_hdrs += private_headers

  result = dict(hdrs=hdrs)
  if requires_arc:
    result['srcs'] = srcs + private_hdrs
  else:
    result['non_arc_srcs'] = srcs
    result['srcs'] = private_hdrs

  return result

def pod_library(
                name,
                deps = [],
                source_files = [],
                private_headers = None,
                public_headers = None,
                enable_modules = True,
                resources = [],
                exclude_files = [],
                non_propagated_deps = [],
                includes = [],
                requires_arc = True,
                use_fake_prefix = False, **kwargs):
  """
  macro that matches pod semantids
  """
  extra_properties = _split_up_sources(source_files, public_headers, private_headers, requires_arc) + \
    _split_up_resources(resources)

  hmap_name = name + "_hmap"

  prefix = name.split('_')[0]
  make_framework_headermap(
      name = hmap_name,
      hdrs = extra_properties['hdrs'],
      prefix = prefix, # If we're a subspec, we want to be named like our superspec
  )
  deps += [':' + hmap_name]

  private_hmap_name = name + "private_hmap"

  make_private_headermap(
      name = private_hmap_name,
      hdrs = [h for h in extra_properties['srcs'] if h.endswith('.h') or h.endswith('.hh')] + extra_properties['hdrs'],
      additional_prefix = prefix,
  )

  deps += [':' + private_hmap_name]

  private_hmap_copts = [
    "-iquote\"$(GENDIR)/$(location :" + private_hmap_name + ")\"",
    "-iquote\".\"",
  ]

  non_propagated_deps += [':' + private_hmap_name]


  copts = private_hmap_copts

  if use_fake_prefix:
    copts += ["-includeUIKit/UIKit.h"]

  native.objc_library(
      name = name,
      deps = deps,
      defines = ['DEBUG_MENU=1'],
      enable_modules = enable_modules,
      includes = includes + ["."],
      non_propagated_deps = non_propagated_deps,
      copts = copts,
      visibility = ["//visibility:public"],
      **(extra_properties + kwargs)
  )


def pod_resource_bundle(
                name,
                deps = [],
                resources = [],
                exclude_files = []):
  """
  macro that matches pod semantids
  """
  native.objc_bundle_library(
      name = name,
      families = ["iphone", "ipad"],

      infoplists = ["@build_bazel_rules_apple//apple:generic_info_plist"],
      **_split_up_resources(resources)
  )

