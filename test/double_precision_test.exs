defmodule DoublePrecisionTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use PropCheck
  alias ExIEEE754.DoublePrecision

  doctest ExIEEE754.DoublePrecision

  property "should convert float to binary and vice versa" do
    forall {sign, exponent, mantisa} <-
             {oneof([0, 1]), bitstring(11), bitstring(52)} do
      hex = <<sign::1, exponent::bitstring, mantisa::bitstring>>

      rv =
        hex
        |> DoublePrecision.to_float()
        |> Result.map(&DoublePrecision.from_float/1)

      check_error(rv) or check_conversion(rv, hex)
    end
  end

  test "should failed with Error conversion binary to float64" do
    data = 0x42B63C43

    rv =
      data
      |> DoublePrecision.to_float()

    assert rv == {:error, "Error conversion. It is not possible convert to float64!"}
  end

  test "should failed with error NaN" do
    data = <<0x7FF8000000000000::size(64)>>

    rv =
      data
      |> DoublePrecision.to_float()

    assert rv == {:error, "NaN"}
  end

  test "should failed with error +Inf" do
    data = <<0x7FF0000000000000::size(64)>>

    rv =
      data
      |> DoublePrecision.to_float()

    assert rv == {:error, "+Inf"}
  end

  test "should failed with error -Inf" do
    data = <<0xFFF0000000000000::size(64)>>

    rv =
      data
      |> DoublePrecision.to_float()

    assert rv == {:error, "-Inf"}
  end

  defp check_error({:error, err}) do
    err in ["+Inf", "-Inf", "NaN"]
  end

  defp check_error(_) do
    false
  end

  defp check_conversion({:ok, result}, hex) do
    result == hex
  end

  defp check_conversion(_, _) do
    false
  end
end
