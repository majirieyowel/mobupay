defmodule MobupayWeb.Plugs.AssignGuardianResource do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    assign(conn, :current_user, Mobupay.Guardian.Plug.current_resource(conn))
  end
end
