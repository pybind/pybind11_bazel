#pragma once

class Adder {
public:
  Adder(int a, int b) : a_(a), b_(b) {}

  int sum() const { return a_ + b_; }

private:
  int a_;
  int b_;
};
