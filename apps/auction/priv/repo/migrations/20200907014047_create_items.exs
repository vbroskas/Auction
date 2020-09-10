defmodule Auction.Repo.Migrations.CreateItems do
  use Ecto.Migration

  # p.127 for more info

  def change do
    create table("items") do
      add(:title, :string)
      add(:description, :string)
      add(:ends_at, :utc_datetime)
      timestamps()
    end
  end
end
