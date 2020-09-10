defmodule AuctionWeb.SessionController do
  use AuctionWeb, :controller

  @doc """
  display login template/form
  """
  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
    # try to find user in db
    case Auction.get_user_by_username_and_password(username, password) do
      %Auction.User{} = user ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Successfully logged in!")
        |> redirect(to: Routes.user_path(conn, :show, user))

      _ ->
        conn
        |> put_flash(:error, "Username or pass wrong")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(to: Routes.item_path(conn, :index))

    # conn
    # |> AuctionWeb.Authenticator.logout()
    # |> redirect(to: Routes.page_path(conn, :index))
  end
end
