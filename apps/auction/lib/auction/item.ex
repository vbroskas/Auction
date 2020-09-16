defmodule Auction.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field(:title, :string)
    field(:description, :string)
    field(:ends_at, :utc_datetime)
    has_many(:bids, Auction.Bid)
    belongs_to(:user, Auction.User)
    timestamps()
  end

  @doc """
  accepts:
  1-An Auction.Item struct that needs (or has) changes
  2-A map of attributes to update, with the default being an empty map

  """
  def changeset(item, params \\ %{}) do
    # cast takes 4 params:
    # 1-struct that you are starting from (including any corre-sponding data)
    # 2-A map of the parameters you’re using for updating
    # 3-A list of fields that you’ll allow to be changed
    # 4-An optional list of options to pass to Ecto.Changeset
    item
    |> cast(params, [:title, :description, :ends_at, :user_id])
    |> validate_required([:title, :description, :user_id])
    |> validate_length(:title, min: 3)
    |> validate_length(:description, max: 200)
    # https://hexdocs.pm/ecto/Ecto.Changeset.html#validate_change/3
    |> validate_change(:ends_at, &validate/2)
  end

  defp validate(:ends_at, ends_at_date) do
    # DateTime.compare check if first date is greater(:gt), less than (:lt) or equal (:eq) to second date
    case DateTime.compare(ends_at_date, DateTime.utc_now()) do
      :lt -> [ends_at: "date cannot be in the past!"]
      _ -> []
    end
  end
end
