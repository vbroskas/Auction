defmodule AuctionWeb.Authenticator do
  import Plug.Conn

  def init(opts) do
    opts
  end

  @doc """
  Plug.Conn.get_session(conn, :user_id) returns either an Auction.User id or nil.
  """
  def call(conn, _opts) do
    user =
      conn
      |> get_session(:user_id)
      |> case do
        nil -> nil
        id -> Auction.get_user(id)
      end

    assign(conn, :current_user, user)
  end

  @doc """
  not used, currently logging out via the delete() in session_controller
  """
  def logout(conn) do
    # delete_session(conn, :user_id)
    configure_session(conn, drop: true)
  end
end
