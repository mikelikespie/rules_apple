workspace(name = "build_bazel_rules_apple")

git_repository(
    name = "bazel_skylib",
    remote = "https://github.com/bazelbuild/bazel-skylib.git",
    tag = "0.2.0",
)

http_file(
    name = "xctestrunner",
    executable = 1,
    url = "https://github.com/google/xctestrunner/releases/download/0.2.1/ios_test_runner.par",
)

maven_jar(
  name = "com_google_guava_guava",
  artifact = "com.google.guava:guava:18.0",
  sha1 = "cce0823396aa693798f8882e64213b1772032b09",
)

maven_jar(
  name = "com_google_code_findbugs",
  artifact = "com.google.code.findbugs:jsr305:3.0.1",
  sha1 = "f7be08ec23c21485b9b5a1cf1654c2ec8c58168d",
)

new_http_archive(
  name = "Branch",
  build_file = "examples/pods/BUILD.Branch",
  strip_prefix = "ios-branch-deep-linking-0.22.5",
  url = "https://github.com/BranchMetrics/ios-branch-deep-linking/archive/0.22.5.zip",
  sha256 = "75186ad658e25485f7186504ed73eec13bc6051613088c7c459d741990bd27d6",
)

new_git_repository(
  name = "KIF",
  build_file = "examples/pods/BUILD.KIF",
  commit = "8cb63de1feaa4d9ca929acf1170fde6b2de380d1",
  remote = "https://github.com/kif-framework/KIF.git",
)


new_git_repository(
  name = "ObjectiveZip",
  build_file = "examples/pods/BUILD.ObjectiveZip",
  commit = "1.0.2",
  remote = "https://github.com/gianlucabertani/Objective-Zip.git",
)

new_git_repository(
  name = "ThumborURL",
  build_file = "examples/pods/BUILD.ThumborURL",
  commit = "v0.0.4",
  remote = "https://github.com/square/ThumborURL.git",
)
