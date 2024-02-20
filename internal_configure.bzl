"""Module extension for "configuring" pybind11_bazel."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _parse_my_own_version_from_module_dot_bazel(module_ctx):
    lines = module_ctx.read(Label("//:MODULE.bazel")).split("\n")
    for line in lines:
        parts = line.split("\"")
        if parts[0] == "    version = ":
            return parts[1]
    fail("Failed to parse my own version from `MODULE.bazel`! " +
         "This should never happen!")

def _internal_configure_extension_impl(module_ctx):
    version = _parse_my_own_version_from_module_dot_bazel(module_ctx)

    # The pybind11_bazel version should typically just be the pybind11 version,
    # but can end with ".bzl.<N>" if the Bazel plumbing was updated separately.
    version = version.split(".bzl.")[0]
    http_archive(
        name = "pybind11",
        build_file = "//:pybind11-BUILD.bazel",
        strip_prefix = "pybind11-%s" % version,
        urls = ["https://github.com/pybind/pybind11/archive/v%s.zip" % version],
    )

internal_configure_extension = module_extension(implementation = _internal_configure_extension_impl)
