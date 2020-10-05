# -*- coding: utf-8 -*-

import extension.adder_extension as extension

import unittest


class TestAnswer(unittest.TestCase):
    def test_basic_case(self):
        adder = extension.Adder(40, 2)
        self.assertEqual(adder.sum(), 42)


if __name__ == '__main__':
    unittest.main()
