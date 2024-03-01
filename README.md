# Bazel extensions for pybind11

Provided rules:

-   `pybind_extension`: Builds a python extension, automatically adding the
    required build flags and pybind11 dependencies. It defines a target which
    can be included as a `data` dependency of a `py_*` target.
-   `pybind_library`: Builds a C++ library, automatically adding the required
    build flags and pybind11 dependencies. This library can then be used as a
    dependency of a `pybind_extension`. The arguments match a `cc_library`.
-   `pybind_library_test`: Builds a C++ test for a `pybind_library`. The
    arguments match a `cc_test`.

To test a `pybind_extension`, the most common approach is to write the test in
Python and use the standard `py_test` build rule.

To embed Python, add `@rules_python//python/cc:current_py_cc_libs` as a
dependency to your `cc_binary`.

## Installation

In your `WORKSPACE` file:

```starlark
http_archive(
  name = "pybind11_bazel",
  strip_prefix = "pybind11_bazel-<version>",
  urls = ["https://github.com/pybind/pybind11_bazel/archive/v<version>.zip"],
)
# We still require the pybind library.
http_archive(
  name = "pybind11",
  build_file = "@pybind11_bazel//:pybind11-BUILD.bazel",
  strip_prefix = "pybind11-<version>",
  urls = ["https://github.com/pybind/pybind11/archive/v<version>.zip"],
)
```

Then, in your `BUILD` file:

```starlark
load("@pybind11_bazel//:build_defs.bzl", "pybind_extension")
```

## Bzlmod

In your `MODULE.bazel` file:

```starlark
bazel_dep(name = "pybind11_bazel", version = "<version>")
```

Usage in your `BUILD` file is as described previously.
