defmodule Auction do
  @moduledoc """
  Context for `Auction`.
  Public interface
  """
  alias Auction.{Repo, Item, User, Password}
  @repo Auction.Repo

  def list_items do
    @repo.all(Item)
  end

  def get_item(id) do
    @repo.get!(Item, id)
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
end
