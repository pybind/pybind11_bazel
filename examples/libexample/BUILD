load("@pybind11_bazel//:build_defs.bzl", "pybind_library")

pybind_library(
    # the name of the library has to match the module name in PYBIND11_MODULE
    # bazel will automatically add 'lib' to the name
    name = "example",
    srcs = ["libexample.cpp"],
)
