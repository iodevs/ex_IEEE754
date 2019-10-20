defmodule SinglePrecisionTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use PropCheck
  alias ExIEEE754.SinglePrecision

  doctest ExIEEE754.SinglePrecision

  property "should convert float to binary and vice versa" do
    forall {sign, exponent, mantisa} <- {oneof([0, 1]), byte(), bitstring(23)} do
      hex = <<sign::1, exponent::8, mantisa::bitstring>>

      rv =
        hex
        |> SinglePrecision.to_float()
        |> Result.map(&SinglePrecision.from_float/1)

      check_error(rv) or check_conversion(rv, hex)
    end
  end

  test "should failed with Error conversion binary to float" do
    data = 0x42B63C43

    rv =
      data
      |> SinglePrecision.to_float()

    assert rv == {:error, "Error conversion. It is not possible convert to float!"}
  end

  test "should failed with error NaN" do
    data = <<0x7FC00000::size(32)>>

    rv =
      data
      |> SinglePrecision.to_float()

    assert rv == {:error, "NaN"}
  end

  test "should failed with error +Inf" do
    data = <<0x7F800000::size(32)>>

    rv =
      data
      |> SinglePrecision.to_float()

    assert rv == {:error, "+Inf"}
  end

  test "should failed with error -Inf" do
    data = <<0xFF800000::size(32)>>

    rv =
      data
      |> SinglePrecision.to_float()

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
