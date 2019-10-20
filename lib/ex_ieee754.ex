defmodule ExIeee754 do
  @moduledoc """
  Documentation for ExIEEE754.
  """

  @doc """
  See `ExIEEE754.SinglePrecision.to_float/1`
  """
  defdelegate to_float32(binary), to: ExIEEE754.SinglePrecision, as: :to_float

  @doc """
  See `ExIEEE754.SinglePrecision.from_float/1`
  """
  defdelegate from_float32(float), to: ExIEEE754.SinglePrecision, as: :from_float

  @doc """
  See `ExIEEE754.DoublePrecision.to_float/1`
  """
  defdelegate to_float64(binary), to: ExIEEE754.DoublePrecision, as: :to_float

  @doc """
  See `ExIEEE754.DoublePrecision.from_float/1`
  """
  defdelegate from_float64(float), to: ExIEEE754.DoublePrecision, as: :from_float
end
