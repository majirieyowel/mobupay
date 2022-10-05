defmodule Mobupay.Helpers.UtilityTest do
  use MobupayWeb.ConnCase

  alias Mobupay.Helpers.Utility

  test "will remove deciimal properly" do
    assert 5000 = Utility.remove_decimal("50")
    assert 5040 = Utility.remove_decimal("50.40")
    assert 5000 = Utility.remove_decimal(50)
  end
end
