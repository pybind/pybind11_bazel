#include <pybind11/pybind11.h>

int add_ints(int a, int b)
{
    return a + b;
}

namespace py = pybind11;

PYBIND11_MODULE(libexample, m)
{
    m.doc() = R"pbdoc(
        Example Library
    )pbdoc";

    m.def("add_ints", &add_ints, R"pbdoc(
        Add two integers.
    )pbdoc");

#ifdef VERSION_INFO
    m.attr("__version__") = VERSION_INFO;
#else
    m.attr("__version__") = "dev";
#endif
}
