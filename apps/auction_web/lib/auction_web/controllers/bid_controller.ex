defmodule AuctionWeb.BidController do
  use AuctionWeb, :controller

  plug :require_logged_in_user

  @doc """
  create new bid on item
  # this should receive bid params, user_id, item_id
    # call Auction.insert_bid(params_from_form)
    # Auction.insert_bid(%{amount: amount, user_id: user_id, item_id: item_id})
  """
  def create(conn, %{"bid" => %{"amount" => amount}, "item_id" => item_id}) do
    # get user_id
    user_id = conn.assigns.current_user.id

    case Auction.insert_bid(%{amount: amount, user_id: user_id, item_id: item_id}) do
      {:ok, bid} ->
        IO.puts("IN BID CREATE!!")
        IO.inspect(bid)
        IO.inspect(item_id)
        redirect(conn, to: Routes.item_path(conn, :show, bid.item_id))

      {:error, bid} ->
        item = Auction.get_item(item_id)
        render(conn, AuctionWeb.ItemView, "show.html", item: item, bid: bid)
    end
  end

  def new(conn, _params) do
  end

  defp require_logged_in_user(%{assigns: %{current_user: nil}} = conn, _opts) do
    conn
    |> put_flash(:error, "Must be loggin in to bid!")
    |> redirect(to: Routes.item_path(conn, :index))
    |> halt()
  end

  defp require_logged_in_user(conn, _opts) do
    conn
  end
end