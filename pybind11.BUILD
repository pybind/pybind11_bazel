# pybind11 - Seamless operability between C++11 and Python.
load("@rules_cc//cc:defs.bzl", "cc_library")

licenses(["notice"])

exports_files(["LICENSE"])

cc_library(
    name = "pybind11",
    hdrs = glob(
        include = [
            "include/pybind11/**/*.h",
        ],
        exclude = [
            # Deprecated file that just emits a warning
            "include/pybind11/common.h",
        ],
    ),
    copts = select({
        ":msvc_compiler": [],
        "//conditions:default": [
            "-fexceptions",
            # Useless warnings
            "-Xclang-only=-Wno-undefined-inline",
            "-Xclang-only=-Wno-pragma-once-outside-header",
            "-Xgcc-only=-Wno-error",  # no way to just disable the pragma-once warning in gcc
        ],
    }),
    includes = ["include"],
    visibility = ["//visibility:public"],
    deps = ["@rules_python//python/cc:current_py_cc_headers"],
)

config_setting(
    name = "msvc_compiler",
    flag_values = {"@bazel_tools//tools/cpp:compiler": "msvc-cl"},
    visibility = ["//visibility:public"],
)
