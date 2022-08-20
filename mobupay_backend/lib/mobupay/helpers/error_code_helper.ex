defmodule Mobupay.Helpers.ErrorCode do
  @error_codes_file_path "lib/mobupay/data/error_codes.json"

  def get(error_name) do
    load()
    |> Enum.filter(fn {k, _v} -> k == error_name end)
    |> case do
      [{_k, v}] -> v
      [] -> raise "Missing error code"
    end
  end

  defp load() do
    File.read!(@error_codes_file_path)
    |> Jason.decode!()
  end
end
