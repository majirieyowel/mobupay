defmodule Mobupay.Helpers.Encryption do

  def hash(hash) do
    :crypto.hash(:sha256, hash)
    |> :base64.encode()
  end
end
