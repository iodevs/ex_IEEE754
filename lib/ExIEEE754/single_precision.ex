defmodule ExIEEE754.SinglePrecision do
  @moduledoc """
  Module for converting binary data to float and vice versa.

  For converting to `float` you can use binary data
  as `<<0x42E65600::size(32)>>` or `<<0x42, 0xE6, 0x56, 0x00>>`.
  In both cases, the function `to_float` returns value `115.16796875`.
  """

  @type float32 :: <<_::32>>

  @doc """
  Function returns result:

  {:error, "NaN"}  when exponent = 0xFF,
  {:error, "+Inf"} when exponent = 0xFF and mantinsa = 0 and sign = 0,
  {:error, "-Inf"} when exponent = 0xFF and mantinsa = 0 and sign = 1,
  {:ok, float_value} otherwise.
  """
  @spec to_float(binary()) :: Result.t(String.t(), float())
  def to_float(<<sign::size(1), exponent::size(8), mantisa::bitstring>> = value)
      when is_binary(value) do
    mantisa
    |> to_fraction()
    |> convert(exponent, sign)
  end

  def to_float(_value) do
    Result.error("Error conversion. It is not possible convert to float!")
  end

  @doc """
  Convert float value to binary representation. For example

  ```elixir
  iex> ExIEEE754.SinglePrecision.from_float(115.16796875)
  <<66, 230, 86, 0>>
  ```
  """
  @spec from_float(float()) :: float32()
  def from_float(value) when is_float(value) do
    <<value::float-32>>
  end

  defp to_fraction(<<>>) do
    0
  end

  defp to_fraction(<<0::size(1), rest::bitstring>>) do
    0 + to_fraction(rest)
  end

  defp to_fraction(<<1::size(1), rest::bitstring>>) do
    :math.pow(2, -23 + bit_size(rest)) + to_fraction(rest)
  end

  defp convert(0, 0xFF, 0), do: Result.error("+Inf")
  defp convert(0, 0xFF, 1), do: Result.error("-Inf")
  defp convert(_man, 0xFF, _sign), do: Result.error("NaN")

  defp convert(0, 0x00, _sign),
    do: Result.ok(0.0)

  defp convert(man, 0x00, sign),
    do: Result.ok(:math.pow(-1, sign) * :math.pow(2, -126) * man)

  defp convert(man, exp, sign),
    do: Result.ok(:math.pow(-1, sign) * :math.pow(2, exp - 127) * (1 + man))
end
