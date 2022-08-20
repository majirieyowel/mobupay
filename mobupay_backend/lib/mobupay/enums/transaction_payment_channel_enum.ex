defmodule Mobupay.TransactionPaymentChannelEnum do
  @moduledoc nil
  use EctoEnum,
    type: :payment_channel,
    enums: [
      :card,
      :balance
    ]
end
