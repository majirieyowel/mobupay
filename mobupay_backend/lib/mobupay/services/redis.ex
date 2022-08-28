defmodule Mobupay.Services.Redis do
  require Logger

  @process_name :redix

  @doc """

  Adds a key:value pair to redis storage

  """
  @spec set(String.t(), map()) :: {:ok, String.t()} | {:error, any()}
  def set(key, value) when is_bitstring(key) and is_map(value),
    do: do_set(key, encode_value(value))

  @spec set(String.t(), String.t()) :: {:ok, String.t()} | {:error, any()}
  def set(key, value) when is_bitstring(key) and is_bitstring(value), do: do_set(key, value)

  @doc """

  Adds a key:value pair to redis storage with expiration

  """
  @spec set_with_expiration(String.t(), String.t(), integer()) ::
          {:ok, String.t()} | {:error, any()}
  def set_with_expiration(key, value, expiry)
      when is_bitstring(key) and is_bitstring(value) and is_integer(expiry),
      do: do_set_with_expiration(key, value, expiry)

  @spec set_with_expiration(String.t(), map(), integer()) ::
          {:ok, String.t()} | {:error, any()}
  def set_with_expiration(key, value, expiry)
      when is_bitstring(key) and is_map(value) and is_integer(expiry) do
    do_set_with_expiration(key, encode_value(value), expiry)
  end

  def get(key), do: Redix.command(@process_name, ["GET", key])

  def get_map(key) do
    Redix.command(@process_name, ["GET", key])
    |> case do
      {:ok, nil} ->
        {:ok, nil}

      {:ok, value} ->
        {:ok, Jason.decode!(value)}
    end
  end

  def del(key), do: Redix.command(@process_name, ["DEL", key])

  defp do_set(key, value), do: Redix.command(@process_name, ["SET", key, value])

  defp do_set_with_expiration(key, value, expiry) do
    with {:ok, "OK"} <- Redix.command(@process_name, ["SET", key, value]),
         {:ok, 1} <- Redix.command(@process_name, ["EXPIRE", key, expiry]) do
      IO.inspect(key)
      {:ok, key}
    else
      error ->
        Logger.error("do_set_with_expiration/3 is failing to save to redis: #{inspect(error)}")
        {:error, "Unable to save data"}
    end
  end

  defp stringify_keys(irregular_map) do
    irregular_map
    |> Enum.map(fn {k, v} ->
      cond do
        is_atom(k) ->
          {Atom.to_string(k), v}

        true ->
          {k, v}
      end
    end)
    |> Enum.into(%{})
  end

  def encode_value(value) when is_map(value) do
    value
    |> stringify_keys()
    |> Jason.encode!()
  end
end
