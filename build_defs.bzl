# Copyright (c) 2019 The Pybind Development Team. All rights reserved.
#
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

"""Build rules for pybind11."""

load("@bazel_skylib//rules:copy_file.bzl", "copy_file")

def register_extension_info(**kwargs):
    pass

PYBIND_COPTS = select({
    Label("@pybind11//:msvc_compiler"): [],
    "//conditions:default": ["-fexceptions"],
})

PYBIND_FEATURES = [
    "-use_header_modules",  # Required for pybind11.
    "-parse_headers",
]

PYBIND_DEPS = [
    Label("@pybind11//:pybind11"),
]

def pybind_extension(
        name,
        copts = [],
        features = [],
        linkopts = [],
        tags = [],
        deps = [],
        python_headers_target = "@rules_python//python/cc:current_py_cc_headers",
        **kwargs):
    """Builds a Python extension module using pybind11.

    Args:
      name: The name of the extension module.
      copts: Compiler options for building the module.
      features: Features required for building the module.
      linkopts: Linker options for building the module.
      tags: Tags for the module.
      deps: Dependencies required for building the module.
      python_headers_target: The cc_library target that exposes the python C SDK headers
      **kwargs: Additional keyword arguments.

    This can be directly used in Python with the import statement.
    Assuming the name NAME, the following targets will be defined:
    1. NAME.so - the shared/dynamic library for the extension module
    2. NAME.pyd - a copy of NAME.so named for Python on Windows; see
                    https://github.com/pybind/pybind11_bazel/issues/74
    3. NAME - an alias pointing to either NAME.so or NAME.pyd as per
                the platform OS (not-Windows or Windows, respectively)
    Generally, the user will "depend" on this extension module via the
    data attribute of their py_* target; specifying NAME is preferred.
    """

    # Mark common dependencies as required for build_cleaner.
    tags = tags + ["req_dep=%s" % dep for dep in PYBIND_DEPS]

    native.cc_binary(
        name = name + ".so",
        copts = copts + PYBIND_COPTS + select({
            Label("@pybind11//:msvc_compiler"): [],
            "//conditions:default": ["-fvisibility=hidden"],
        }),
        features = features + PYBIND_FEATURES,
        linkopts = linkopts + select({
            "@platforms//os:osx": ["-undefined", "dynamic_lookup"],
            Label("@pybind11//:msvc_compiler"): [],
            "//conditions:default": ["-Wl,-Bsymbolic"],
        }),
        linkshared = 1,
        tags = tags,
        deps = deps + PYBIND_DEPS + [python_headers_target],
        **kwargs
    )

    copy_file(
        name = name + "_copy_so_to_pyd",
        src = name + ".so",
        out = name + ".pyd",
        testonly = kwargs.get("testonly"),
        visibility = kwargs.get("visibility"),
    )

    native.alias(
        name = name,
        actual = select({
            "@platforms//os:windows": name + ".pyd",
            "//conditions:default": name + ".so",
        }),
        testonly = kwargs.get("testonly"),
        visibility = kwargs.get("visibility"),
    )

def pybind_library(
        name,
        copts = [],
        features = [],
        tags = [],
        deps = [],
        python_headers_target = "@rules_python//python/cc:current_py_cc_headers",
        **kwargs):
    """Builds a pybind11 compatible library. This can be linked to a pybind_extension."""

    # Mark common dependencies as required for build_cleaner.
    tags = tags + ["req_dep=%s" % dep for dep in PYBIND_DEPS]

    native.cc_library(
        name = name,
        copts = copts + PYBIND_COPTS,
        features = features + PYBIND_FEATURES,
        tags = tags,
        deps = deps + PYBIND_DEPS + [python_headers_target],
        **kwargs
    )

def pybind_library_test(
        name,
        copts = [],
        features = [],
        tags = [],
        deps = [],
        python_headers_target = "@rules_python//python/cc:current_py_cc_headers",
        python_library_target = "@rules_python//python/cc:current_py_cc_libs",
        **kwargs):
    """Builds a C++ test for a pybind_library."""

    # Mark common dependencies as required for build_cleaner.
    tags = tags + ["req_dep=%s" % dep for dep in PYBIND_DEPS]

    native.cc_test(
        name = name,
        copts = copts + PYBIND_COPTS,
        features = features + PYBIND_FEATURES,
        tags = tags,
        deps = deps + PYBIND_DEPS + [
            python_headers_target,
            python_library_target,
        ],
        **kwargs
    )

# Register extension with build_cleaner.
register_extension_info(
    extension = pybind_extension,
    label_regex_for_dep = "{extension_name}",
)

register_extension_info(
    extension = pybind_library,
    label_regex_for_dep = "{extension_name}",
)

register_extension_info(
    extension = pybind_library_test,
    label_regex_for_dep = "{extension_name}",
)
