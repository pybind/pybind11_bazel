# Bazel extensions for pybind11

In your BUILD file:

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


In your WORKSPACE FILE:

If you wish to clone to a directory other than //third_party as in the examples,

- `load("//your/directory/pybind11_bazel:python_configure.bzl", "PYBIND11_BAZEL_DIR")`
- `PYBIND11_BAZEL_DIR = "//your/directory/pybind11_bazel"`
- change `//third_party` in the examples to `//your/directory`

```
# Create a repository rule for the system python headers.
# pybind11.BUILD depends on this repository rule to detect your python configuration
load("//third_party/pybind11_bazel:python_configure.bzl", "python_configure")

python_configure(name = "local_config_python")

Create a pybind11 external repository
# If using another pybind11 version:
# Use tar URL of desired version, change strip_prefix to your version "pybind11-x.x.x",
# Supply correct sha256 for your version.
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "pybind11",
    build_file = "@//third_party/pybind11_bazel:pybind11.BUILD",
    sha256 = "1eed57bc6863190e35637290f97a20c81cfe4d9090ac0a24f3bbf08f265eb71d",
    strip_prefix = "pybind11-2.4.3",
    url = "https://github.com/pybind/pybind11/archive/v2.4.3.tar.gz",
)
```

Alternatively, if you need to have pybind11 on your local system:
```
new_local_repository(
    name = "pybind11",
    path = "full_path_to_local_pybind11",
    build_file = "@//third_party/pybind11_bazel:pybind11.BUILD",
)
```

Add python rules for your python targets:
```
# @rules_python repository, used to create python build targets
http_archive(
    name = "rules_python",
    sha256 = "aa96a691d3a8177f3215b14b0edc9641787abaaa30363a080165d06ab65e1161",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.0.1/rules_python-0.0.1.tar.gz",
)

# Currently does nothing, futureproofs your core Python rule dependencies.
load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

# Pulls in dependencies needed to use the python packaging rules.
load("@rules_python//python:pip.bzl", "pip_repositories")

pip_repositories()
```