# Build a pybind library with bazel

This minimal example demonstrates how to build a a C++ library that you can load into python with pybind11 and bazel.

To make the build library loadable with your preferred python version, export the path to the python binary:
```bash
export PYTHON_BIN_PATH=$(which python3)
```

Build with:
```bash
bazel build //libexample
```

Test the library file:
```bash
PYTHONPATH=bazel-bin/libexample python3
```
```python
# in the python interpreter
import libexample
libexample.add_ints(5, 8)
```
