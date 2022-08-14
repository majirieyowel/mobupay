defmodule Mobupay.TransactionFundingSourceEnum do
  @moduledoc nil
  use EctoEnum,
    type: :transaction_funding_source,
    enums: [
      :card,
      :self
    ]
end
