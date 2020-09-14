defmodule Auction.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:username, :string)
    field(:email_address, :string)
    field(:password, :string, virtual: true)
    field(:hashed_password, :string)
    has_many(:bids, Auction.Bid)
    timestamps()
  end

  def changeset(user, params \\ %{}) do
    IO.puts("GOT INTO CHANGE NON PASS")
    IO.inspect(user)
    IO.inspect(params)
    IO.puts("---------------------------")

    user
    |> cast(params, [:username, :email_address])
    |> validate_required([:username, :email_address, :hashed_password])
    |> validate_length(:username, min: 4)
    |> unique_constraint(:username)
  end

  def changeset_with_password(user, params \\ %{}) do
    user
    |> cast(params, [:password])
    |> validate_required(:password)
    |> validate_length(:password, min: 6)
    # validate_confirmation checks against a second confirmation input field
    |> validate_confirmation(:password, required: true)
    |> hash_password()
    # Uses the regular changeset inside this one for passwords
    |> changeset(params)
  end

  @doc """
  password
  changes is: The changes from parameters that were approved in casting
  """
  defp hash_password(%Ecto.Changeset{changes: %{password: password}} = changeset) do
    changeset
    |> put_change(:hashed_password, Auction.Password.hash(password))
  end

  @doc """
  case where password isnt being changed. just pass the changeset along
  """
  defp hash_password(changeset), do: changeset
end
