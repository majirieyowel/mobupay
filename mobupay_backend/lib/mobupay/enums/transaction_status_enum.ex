defmodule Mobupay.TransactionStatusEnum do
  @moduledoc nil
  use EctoEnum,
    type: :transaction_status,
    enums: [
      :initiated,
      :floating,
      :accepted,
      :refused,
      :reclaimed,
      :abandoned
    ]
end
