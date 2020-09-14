defmodule AuctionWeb.ItemController do
  use AuctionWeb, :controller

  plug :require_logged_in_user when action in [:new]

  def index(conn, _params) do
    items = Auction.list_items()
    render(conn, "index.html", items: items)
  end

  def show(conn, %{"id" => id}) do
    item = Auction.get_item_with_bids(id)

    empty_bid_struct = Auction.new_bid()
    render(conn, "show.html", item: item, bid: empty_bid_struct)
  end

  @doc """
  display page with form to create new item
  """
  def new(conn, _params) do
    item_changeset = Auction.new_item()
    render(conn, "new.html", item: item_changeset)
  end

  @doc """
  handle POST request from form to create new item
  """
  def create(conn, %{"item" => item_params}) do
    case Auction.insert_item(item_params) do
      {:ok, item} -> redirect(conn, to: Routes.item_path(conn, :show, item))
      {:error, changeset} -> render(conn, "new.html", item: changeset)
    end

    # If the Auction.Item.changeset/2 function determines that the changeset is invalid,
    # Auction.insert_item/1 will return {:error, item}, with item being the changeset
    # with an errors attribute. In the case of an invalid item, you want to rerender the form
    # and notify the user of any errors so they can fix them. You need to make changes in
    # two places: AuctionWeb.ItemController.create/2 and .../templates/item/new
    # .html.eex. In the former, you need to handle the error case and render the form
    # again. In the latter, you need to display any relevant errors.
  end

  @doc """
  display page with form to edit item
  """
  def edit(conn, %{"id" => id}) do
    item_changeset = Auction.edit_item(id)
    render(conn, "edit.html", item: item_changeset)
  end

  @doc """
  update/2 will be remarkably similar to create/2—you need the params from the
  item’s form, but this time you also need the ID of the item to update. You’ll also pat-
  tern-match on the success or failure of the submission, so you know where to send
  your user next. Finally, you’ll also use Auction.update_item/2 instead of Auction
  .create_item/1.
  """
  def update(conn, %{"id" => id, "item" => item_params}) do
    item = Auction.get_item(id)

    case Auction.update_item(item, item_params) do
      {:ok, item} -> redirect(conn, to: Routes.item_path(conn, :show, item))
      {:error, item} -> render(conn, "edit.html", item: item)
    end
  end

  defp require_logged_in_user(%{assigns: %{current_user: nil}} = conn, _opts) do
    conn
    |> put_flash(:error, "Must be logged in to create an item!")
    |> redirect(to: Routes.item_path(conn, :index))
    |> halt()
  end

  defp require_logged_in_user(conn, _opts) do
    conn
  end
end
