defmodule AuctionWeb.UserController do
  use AuctionWeb, :controller
  alias Auction.User

  plug :prevent_unauthorized_access when action in [:show]

  @doc """
  MUST pattern match on "id" because that is the key set in the
  user changeset returned from Auction.insert_user()
  """
  def show(conn, %{"id" => id}) do
    user = Auction.get_user(id)
    render(conn, "show.html", user: user)
  end

  @doc """
  show new user registration form
  """
  def new(conn, _params) do
    # send fresh changeset for form
    user = Auction.new_user()

    render(conn, "new.html", user: user)
  end

  @doc """
  the key "user" here is established on the :data property of my scheme struct. will be lowercase of the module name which holds my schema
  """
  def create(conn, %{"user" => user_params}) do
    case Auction.insert_user(user_params) do
      {:ok, user} ->
        # user successfully created
        IO.puts("------------------------------------")
        IO.inspect(user)
        redirect(conn, to: Routes.user_path(conn, :show, user))

      {:error, user} ->
        # send back changeset with errors
        render(conn, "new.html", user: user)
    end
  end

  defp prevent_unauthorized_access(conn, _opts) do
    # grap current user out of conn assigns
    current_user = Map.get(conn.assigns, :current_user)

    requsted_user_id =
      conn.params
      |> Map.get("id")
      |> String.to_integer()

    if current_user == nil || current_user.id != requsted_user_id do
      conn
      |> put_flash(:error, "Sorry, you're not allowed to view this page!")
      |> redirect(to: Routes.item_path(conn, :index))
      # halt tells plug to stop processing path
      |> halt()
    else
      # access is allowed so return original conn untouched
      conn
    end
  end
end
