# Copyright (c) 2019 The Pybind Development Team. All rights reserved.
#
# All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

"""Build rules for pybind11."""

load("@bazel_skylib//rules:copy_file.bzl", "copy_file")
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_cc//cc:cc_test.bzl", "cc_test")

def _pybind_py_env_test_impl(ctx):
    toolchain = ctx.toolchains["@rules_python//python:toolchain_type"]
    py3_runtime = toolchain.py3_runtime
    if not py3_runtime:
        fail("No python3 runtime found in toolchain")

    # On Windows, we cannot use the shell script wrapper.
    if ctx.target_platform_has_constraint(ctx.attr._windows_constraint[platform_common.ConstraintValueInfo]):
        # On Windows, we need to return an executable created by this rule.
        # We create a symlink to the actual binary.
        # We use the same extension as the original binary (usually .exe).
        extension = ctx.executable.binary.extension
        executable = ctx.actions.declare_file(ctx.label.name + ("." + extension if extension else ""))
        ctx.actions.symlink(output = executable, target_file = ctx.executable.binary, is_executable = True)
        return [
            DefaultInfo(
                executable = executable,
                runfiles = ctx.runfiles(files = [executable])
                    .merge(ctx.attr.binary[DefaultInfo].default_runfiles)
                    .merge(ctx.runfiles(transitive_files = py3_runtime.files)),
            ),
        ]

    interpreter = py3_runtime.interpreter

    # Generate a wrapper script that sets PYTHONHOME and runs the C++ binary.
    script = ctx.actions.declare_file(ctx.label.name + ".sh")

    content = "#!/bin/bash\n"
    content += "if [ -z \"$RUNFILES_DIR\" ]; then\n"
    content += "  if [ -d \"$0.runfiles\" ]; then\n"
    content += "    RUNFILES_DIR=\"$0.runfiles\"\n"
    content += "  else\n"
    content += "    RUNFILES_DIR=\"$(dirname \"$0\")/../..\"\n"
    content += "  fi\n"
    content += "fi\n"
    content += "INTERPRETER_PATH=\"$RUNFILES_DIR/" + ctx.workspace_name + "/" + interpreter.short_path + "\"\n"
    content += "if [ ! -f \"$INTERPRETER_PATH\" ]; then\n"
    content += "  INTERPRETER_PATH=$(find \"$RUNFILES_DIR\" -path \"*/" + interpreter.short_path + "\" | head -n 1)\n"
    content += "fi\n"
    content += "export PYTHONHOME=$(dirname $(dirname $(readlink -f \"$INTERPRETER_PATH\")))\n"
    content += "BINARY_PATH=\"$RUNFILES_DIR/" + ctx.workspace_name + "/" + ctx.executable.binary.short_path + "\"\n"
    content += "if [ ! -f \"$BINARY_PATH\" ]; then\n"
    content += "  BINARY_PATH=$(find \"$RUNFILES_DIR\" -path \"*/" + ctx.executable.binary.short_path + "\" | head -n 1)\n"
    content += "fi\n"
    content += "exec \"$BINARY_PATH\" \"$@\"\n"

    ctx.actions.write(script, content, is_executable = True)

    runfiles = ctx.runfiles(files = [script, ctx.executable.binary])
    runfiles = runfiles.merge(ctx.attr.binary[DefaultInfo].default_runfiles)
    runfiles = runfiles.merge(ctx.runfiles(transitive_files = py3_runtime.files))

    return [
        DefaultInfo(
            executable = script,
            runfiles = runfiles,
        ),
    ]

pybind_py_env_test = rule(
    implementation = _pybind_py_env_test_impl,
    test = True,
    attrs = {
        "binary": attr.label(
            executable = True,
            cfg = "target",
            mandatory = True,
        ),
        "_windows_constraint": attr.label(default = "@platforms//os:windows"),
    },
    toolchains = ["@rules_python//python:toolchain_type"],
)

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
    "@rules_python//python/cc:current_py_cc_headers",
]

def pybind_extension(
        name,
        copts = [],
        features = [],
        linkopts = [],
        tags = [],
        deps = [],
        **kwargs):
    """Builds a Python extension module using pybind11.

    Args:
      name: The name of the extension module.
      copts: Compiler options for building the module.
      features: Features required for building the module.
      linkopts: Linker options for building the module.
      tags: Tags for the module.
      deps: Dependencies required for building the module.
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

    cc_binary(
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
        target_compatible_with = select({
            "@platforms//os:windows": ["@platforms//:incompatible"],
            "//conditions:default": [],
        }),
        deps = deps + PYBIND_DEPS,
        **kwargs
    )

    cc_binary(
        name = name + ".pyd",
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
        target_compatible_with = select({
            "@platforms//os:windows": [],
            "//conditions:default": ["@platforms//:incompatible"],
        }),
        deps = deps + PYBIND_DEPS,
        **kwargs
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
        **kwargs):
    """Builds a pybind11 compatible library. This can be linked to a pybind_extension."""

    # Mark common dependencies as required for build_cleaner.
    tags = tags + ["req_dep=%s" % dep for dep in PYBIND_DEPS]

    cc_library(
        name = name,
        copts = copts + PYBIND_COPTS,
        features = features + PYBIND_FEATURES,
        tags = tags,
        deps = deps + PYBIND_DEPS,
        **kwargs
    )

def pybind_library_test(
        name,
        copts = [],
        features = [],
        tags = [],
        deps = [],
        **kwargs):
    """Builds a C++ test for a pybind_library."""

    # Mark common dependencies as required for build_cleaner.
    tags = tags + ["req_dep=%s" % dep for dep in PYBIND_DEPS]

    # Pop test-only attributes that cc_binary doesn't support.
    test_kwargs = {}
    for attr in ["size", "timeout", "flaky", "shard_count", "local"]:
        if attr in kwargs:
            test_kwargs[attr] = kwargs.pop(attr)

    # Build the actual C++ binary.
    cc_binary(
        name = name + "_bin",
        copts = copts + PYBIND_COPTS,
        features = features + PYBIND_FEATURES,
        testonly = True,
        visibility = ["//visibility:private"],
        deps = deps + PYBIND_DEPS + [
            "@rules_python//python/cc:current_py_cc_libs",
        ],
        **kwargs
    )

    # Use a wrapper rule to set PYTHONHOME and run the binary.
    pybind_py_env_test(
        name = name,
        binary = ":" + name + "_bin",
        testonly = True,
        tags = tags,
        visibility = kwargs.get("visibility"),
        **test_kwargs
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
