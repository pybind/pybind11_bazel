"""Module extension for "configuring" pybind11_bazel."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_INTEGRITIES = {
    "2.11.1": "sha256-1HWXjaDNwtQ7c/MJEHhnWdWTqdjuBbG2hG0esWxtLgw=",
    "2.12.0": "sha256-v48kKr0avNN11RanBnSQ+3Gr15UZooLSK25NGSghhac=",
    "2.13.1": "sha256-UWMeiJYKiFb5xJcCf1XJ8vkRXK+wjAAFQ5g4oFuhe/w=",
    "2.13.5": "sha256-seIJxCs6ntdNo+CyWk9M1HjYnV77tI8EsnffQn+vYlI=",
}

def _internal_configure_extension_impl(module_ctx):
    (pybind11_bazel,) = [module for module in module_ctx.modules if module.name == "pybind11_bazel"]
    version = pybind11_bazel.version

    # The pybind11_bazel version should typically just be the pybind11 version,
    # but can end with ".bzl.<N>" if the Bazel plumbing was updated separately.
    version = version.split(".bzl.")[0]
    http_archive(
        name = "pybind11",
        build_file = "//:pybind11-BUILD.bazel",
        strip_prefix = "pybind11-%s" % version,
        url = "https://github.com/pybind/pybind11/archive/refs/tags/v%s.tar.gz" % version,
        integrity = _INTEGRITIES.get(version),
    )

internal_configure_extension = module_extension(implementation = _internal_configure_extension_impl)
