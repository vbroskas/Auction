defmodule Auction do
  @moduledoc """
  Context for `Auction`.
  Public interface
  """
  import Ecto.Query
  alias Auction.{Repo, Item, User, Password, Bid}
  @repo Auction.Repo

  def list_items do
    @repo.all(Item)
  end

  def get_item(id) do
    @repo.get!(Item, id)
  end

  def get_item_with_bids(id) do
    query = from(b in Bid, order_by: [desc: b.inserted_at])

    id
    |> get_item()
    # Preloads the item’s bids and the users for those bids
    |> @repo.preload(bids: {query, [:user]})
  end

  @spec get_item_by(map()) :: any
  def get_item_by(attrs) do
    @repo.get_by(Item, attrs)
  end

  @doc """
  takes in a map as attrs
  will return {:ok, struct} or {:error, changeset}
  """
  def insert_item(attrs) do
    %Item{}
    |> Item.changeset(attrs)
    |> @repo.insert()
  end

  def update_item(%Item{} = item, updates) do
    item
    |> Item.changeset(updates)
    |> Repo.update()
  end

  def delete_item(%Item{} = item), do: @repo.delete(item)

  @doc """
  return an empty Auction.Item changeset
  """
  def new_item() do
    Item.changeset(%Item{})
  end

  def edit_item(id) do
    get_item(id)
    |> Item.changeset()
  end

  # ------------------User Calls--------------------------------
  def get_user(id) do
    @repo.get!(User, id)
  end

  def get_user_by_username_and_password(username, password) do
    with user when not is_nil(user) <- @repo.get_by(User, %{username: username}),
         true <- Password.verify_with_hash(password, user.hashed_password) do
      user
    else
      _ -> Password.dummy_verify()
    end
  end

  @doc """
  display form for a new user to register, creates changeset
  """
  def new_user() do
    User.changeset_with_password(%User{})
  end

  def insert_user(params) do
    %User{}
    |> User.changeset_with_password(params)
    |> @repo.insert
  end

  def get_bids_for_user(user) do
    query =
      from(b in Bid,
        where: b.user_id == ^user.id,
        order_by: [desc: :inserted_at],
        preload: :item,
        limit: 10
      )

    @repo.all(query)
  end

  # -----------------------------------------Bid calls---------------------------
  def insert_bid(params) do
    %Bid{}
    |> Bid.changeset(params)
    |> @repo.insert()
  end

  @doc """
  create blank bid that goes through a blank changeset
  this will return everything the form needs to render & accept a bid
  """
  def new_bid() do
    Bid.changeset(%Bid{})
  end
end
