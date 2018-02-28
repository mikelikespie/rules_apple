licenses(["NOTICE"])

java_library(
  name = "HeaderMap",
  srcs = ["HeaderMap.java"],
  visibility = ["//tools/headermap:__pkg__"],
  deps = [
    "@com_google_code_findbugs//jar",
    "@com_google_guava_guava//jar",
  ],
)

java_binary(
  name = "PrintHeaderMap",
  srcs = ["PrintHeaderMap.java"],
  main_class = "com.facebook.buck.apple.clang.PrintHeaderMap",
  visibility = ["//visibility:public"],
  deps = [
    ":HeaderMap",
    "@com_google_code_findbugs//jar",
    "@com_google_guava_guava//jar",
  ],
)
