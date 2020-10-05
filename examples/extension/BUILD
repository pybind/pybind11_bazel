load("@pybind_config_python//:build_defs.bzl", "pybind_extension")

package(default_visibility = ["//visibility:public"])

pybind_extension(
    name = "adder_extension",
    srcs = ["adder_extension.cpp"],
    deps = [
        "//cpp_class:adder",
    ],
)
