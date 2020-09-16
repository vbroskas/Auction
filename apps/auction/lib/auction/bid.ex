defmodule Auction.Bid do
  use Ecto.Schema
  import Ecto.Changeset

  import Ecto.Query
  alias Auction.Bid
  @repo Auction.Repo

  schema "bids" do
    field(:amount, :integer)

    belongs_to(:user, Auction.User)
    belongs_to(:item, Auction.Item)
    timestamps()
  end

  def changeset(bid, params \\ %{}) do
    bid
    |> cast(params, [:amount, :user_id, :item_id])
    |> validate_required([:amount, :user_id, :item_id])
    |> assoc_constraint(:item)
    |> assoc_constraint(:user)
  end

  def changesetv2(bid, params \\ %{}) do
    bid
    |> cast(params, [:amount, :user_id, :item_id])
    |> validate_required([:amount, :user_id, :item_id])
    |> validate_number(:amount, greater_than: 0)
    |> check_current_bid()
    |> assoc_constraint(:item)
    |> assoc_constraint(:user)
  end

  defp check_current_bid(
         %Ecto.Changeset{changes: %{item_id: item_id, amount: amount}} = changeset
       ) do
    # get highest bid for that item
    query =
      from(b in Bid,
        where: b.item_id == ^item_id,
        select: max(b.amount)
      )

    result = @repo.one(query)

    if amount > result || result == nil do
      IO.puts("GOOOOOOD-------------")
      changeset
    else
      IO.puts("BAAAAAAAAAD-------------")
      changeset = add_error(changeset, :amount, "Bid must be higher than current highest bid!")
      changeset
    end
  end
end
