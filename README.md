# Bazel extensions for pybind11

In your build file:

```
load("//third_party/pybind11_bazel:build_defs.bzl", "pybind_extension")
```

Provided rules:

- `pybind_extension`: Builds a python extension, automatically adding the
  required build flags and pybind11 dependencies. It also defines a .so target
  which can be manually built and copied. The arguments match a `py_extension`.
- `pybind_library`: Builds a C++ library, automatically adding the required
  build flags and pybind11 dependencies. This library can then be used as a
  dependency of a `pybind_extension`. The arguments match a `cc_library`.
- `pybind_library_test`: Builds a C++ test for a `pybind_library`. The arguments
  match a cc_test.

To test a `pybind_extension`, the most common approach is to write the test in
python and use the standard `py_test` build rule.
