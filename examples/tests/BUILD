load("@rules_python//python:defs.bzl", "py_test")

package(default_visibility = ["//visibility:public"])

py_test(
    name = "extension_test",
    srcs = ["extension_test.py"],
    data = [
        "//extension:adder_extension",
    ],
    python_version = "PY3",
    srcs_version = "PY3",
)
