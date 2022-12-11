defmodule MobupayWhatsapp.Action.ValidationTest do
  use MobupayWeb.ConnCase

  alias MobupayWhatsapp.Action.Validation

  test "validate_amount/1 validates amount properly" do
    input_amount = "800"
    expected_output = {:ok, input_amount}

    assert expected_output == Validation.validate_amount(input_amount)
  end

  test "validate_amount/1 checks if amount only contains digits" do
    input_amount = "NGN800"
    expected_output = {:error, "Please enter a valid amount\rOnly digits allowed \r_e.g 400_\n"}

    assert expected_output == Validation.validate_amount(input_amount)
  end
end
