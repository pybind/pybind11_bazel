"""Module extension for "configuring" pybind11_bazel."""

load("@bazel_features//:features.bzl", "bazel_features")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_INTEGRITIES = {
    # Generate with "sha256-$(curl -fsSL "$url" | sha256sum | cut -d' ' -f1 | xxd -r -p | base64)"
    "2.11.1": "sha256-1HWXjaDNwtQ7c/MJEHhnWdWTqdjuBbG2hG0esWxtLgw=",
    "2.12.0": "sha256-v48kKr0avNN11RanBnSQ+3Gr15UZooLSK25NGSghhac=",
    "2.13.1": "sha256-UWMeiJYKiFb5xJcCf1XJ8vkRXK+wjAAFQ5g4oFuhe/w=",
    "2.13.5": "sha256-seIJxCs6ntdNo+CyWk9M1HjYnV77tI8EsnffQn+vYlI=",
    "2.13.6": "sha256-4Iy4f0dz2pf6e18DXeh2OrxlbYfVdz5i9toFh9Hw7CA=",
    "3.0.0": "sha256-RTsaPismbDrp2ockEcrbbWk6wYBjvXMibZbPtwFaIAw=",
    "3.0.1": "sha256-dBYz2nRrfHOLtx8YVPlXudpmC80tzmjXGUkDfwlp0Mo=",
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

    if bazel_features.external_deps.extension_metadata_has_reproducible:
        return module_ctx.extension_metadata(reproducible = True)
    else:
        return None

internal_configure_extension = module_extension(implementation = _internal_configure_extension_impl)
