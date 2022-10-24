defmodule Mobupay.Helpers.EC do
  @moduledoc """
    This module manages interaction with the error codes json
  """
  @error_codes_file_path File.read!("lib/mobupay/data/error_codes.json") |> Jason.decode!()

  @spec get(String.t()) :: String.t()
  def get(error_name) do
    @error_codes_file_path
    |> Enum.filter(fn {k, _v} -> k == error_name end)
    |> case do
      [{_k, v}] -> v
      [] -> raise "Missing error code"
    end
  end
end
