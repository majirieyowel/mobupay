defmodule Mobupay.Repo do
  use Ecto.Repo,
    otp_app: :mobupay,
    adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 10
end
