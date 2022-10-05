defmodule Mobupay.TransactionStatusEnum do
  @moduledoc nil
  use EctoEnum,
    type: :transaction_status,
    enums: [
      :initiated,
      :floating,
      :accepted,
      :rejected,
      :reclaimed,
      :abandoned
    ]
end
