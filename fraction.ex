defmodule Fraction do
  defstruct a: nil, b: nil
  # one_half = %Fraction{a: 1, b: 2}
  # one_half.a
  # one_half.b
  # one_quarter = %Fraction{one_half | b: 4}

  def new(a, b) do
    %Fraction{a: a, b: b}
  end

  def value(%Fraction{a: a, b: b}) do
    # or: def value(fraction) do
    #       fraction.a / fraction.b
    a / b
  end

  def add(f1, f2) do
    new(f1.a * f2.b + f2.a * f1.b, f2.b * f1.b)
  end
end
