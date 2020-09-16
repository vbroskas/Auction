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

    # check ends_at
    item = Auction.get_item(item_id)

    # DateTime.compare check if first date is greater(:gt), less than (:lt) or equal (:eq) to second date
    case DateTime.compare(item.ends_at, DateTime.utc_now()) do
      # item expired
      result when result in [:lt, :eq] ->
        conn
        |> put_flash(:error, "Bidding on that item has expired!")
        |> redirect(to: Routes.item_path(conn, :show, item_id))

      _ ->
        # item still active
        case Auction.insert_bid(%{amount: amount, user_id: user_id, item_id: item_id}) do
          {:ok, bid} ->
            html =
              Phoenix.View.render_to_string(AuctionWeb.BidView, "bid.html",
                bid: bid,
                username: conn.assigns.current_user.username
              )

            # broadcast out new bid
            AuctionWeb.Endpoint.broadcast("item:#{item_id}", "new_bid", %{body: html})

            redirect(conn, to: Routes.item_path(conn, :show, bid.item_id))

          {:error, bid} ->
            IO.puts("BACK IN CONT----------")
            IO.inspect(bid)
            item = Auction.get_item_with_bids(item_id)
            owner = Auction.get_user(item.user_id)

            render(conn, AuctionWeb.ItemView, "show.html",
              item: item,
              bid: bid,
              owner: owner.username
            )
        end
    end
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
