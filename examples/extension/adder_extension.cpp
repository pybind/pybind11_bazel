#include "cpp_class/adder.h"
#include "pybind11/pybind11.h"

namespace py = pybind11;

PYBIND11_MODULE(adder_extension, m) {
  py::class_<Adder>(m, "Adder")
      .def(py::init<int, int>())
      .def("sum", &Adder::sum);
}
