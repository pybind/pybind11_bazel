# Bazel extensions for pybind11

Provided rules:

-   `pybind_extension`: Builds a python extension, automatically adding the
    required build flags and pybind11 dependencies. It defines a `*.so` target
    which can be included as a `data` dependency of a `py_*` target.
-   `pybind_library`: Builds a C++ library, automatically adding the required
    build flags and pybind11 dependencies. This library can then be used as a
    dependency of a `pybind_extension`. The arguments match a `cc_library`.
-   `pybind_library_test`: Builds a C++ test for a `pybind_library`. The
    arguments match a `cc_test`.

To test a `pybind_extension`, the most common approach is to write the test in
python and use the standard `py_test` build rule.

Provided targets:

-   `@pybind11//:pybind11_embed`: Automatically adds required build flags to
    embed Python. Add as a dependency to your `cc_binary`.

    `@pybind11//:pybind11_embed` currently supports Python 3 MacOS/Ubuntu/Debian
    environments:

    -   pyenv
    -   pipenv
    -   virtualenv

    If `pybind11_embed` doesn't work with your embedded Python project, add
    `@pybind11` as a dependency to your `cc_binary` and
    [follow the instructions for manually retrieving the build flags](https://docs.python.org/3/extending/embedding.html#embedding-python-in-c).

## Installation

In your `WORKSPACE` file:

```starlark
http_archive(
  name = "pybind11_bazel",
  strip_prefix = "pybind11_bazel-<stable-commit>",
  urls = ["https://github.com/pybind/pybind11_bazel/archive/<stable-commit>.zip"],
)
# We still require the pybind library.
http_archive(
  name = "pybind11",
  build_file = "@pybind11_bazel//:pybind11.BUILD",
  strip_prefix = "pybind11-<stable-version>",
  urls = ["https://github.com/pybind/pybind11/archive/v<stable-version>.zip"],
)
```

Then, in your `BUILD` file:

```starlark
load("@pybind11_bazel//:build_defs.bzl", "pybind_extension")
```

## Bzlmod

In your `MODULE.bazel` file:

```starlark
pybind11_configure = use_extension("@pybind11_bazel//:pybind11_configure.bzl", "pybind11_configure_extension")
use_repo(pybind11_configure, "pybind11")
```

Usage in your `BUILD` file is as described previously.
