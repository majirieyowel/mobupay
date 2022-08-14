defmodule Mobupay.TransactionTypeEnum do
  @moduledoc nil
  use EctoEnum,
    type: :transaction_type,
    enums: [
      :credit,
      :debit,
      :self_fund
    ]
end
