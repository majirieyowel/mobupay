defmodule Mobupay.WithdrawalStatusEnum do
  @moduledoc nil
  use EctoEnum,
    type: :withdrawal_status,
    enums: [
      :initiated,
      :pending,
      :failed,
      :success,
      :abandoned
    ]
end
