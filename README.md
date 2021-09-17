# Bazel extensions for pybind11

Provided rules:

- `pybind_extension`: Builds a python extension, automatically adding the
  required build flags and pybind11 dependencies. It defines a `*.so` target
  which can be included as a `data` dependency of a `py_*` target.
- `pybind_library`: Builds a C++ library, automatically adding the required
  build flags and pybind11 dependencies. This library can then be used as a
  dependency of a `pybind_extension`. The arguments match a `cc_library`.
- `pybind_library_test`: Builds a C++ test for a `pybind_library`. The arguments
  match a `cc_test`.

To test a `pybind_extension`, the most common approach is to write the test in
python and use the standard `py_test` build rule.

Provided targets:

 - `@pybind11//:pybind11_embed`: Automatically adds required build flags to 
   embed Python.
   Add as a dependency to your `cc_binary`. 
   
   `@pybind11//:pybind11_embed` currently supports Python 3 MacOS/Ubuntu/Debian
    environments:
   - pyenv
   - pipenv
   - virtualenv
   
   If `pybind11_embed` doesn't work with your embedded Python project, add 
   `@pybind11` as a dependency to your `cc_binary` and [follow the instructions
    for manually retrieving the build flags](https://docs.python.org/3/extending/embedding.html#embedding-python-in-c).
    

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
  urls = ["https://github.com/pybind/pybind11/archive/v<stable-version>.tar.gz"],
)
load("@pybind11_bazel//:python_configure.bzl", "python_configure")
python_configure(name = "local_config_python")
```

Then, in your `BUILD` file:

```starlark
load("@pybind11_bazel//:build_defs.bzl", "pybind_extension")
```

## Hermetic Python

To configure `pybind11_bazel` for hermetic Python, `python_configure` can take
the target providing the Python runtime as an argument:

```starlark
python_configure(
  name = "local_config_python",
  python_interpreter_target = "@python_interpreter//:python_bin",
)
```
