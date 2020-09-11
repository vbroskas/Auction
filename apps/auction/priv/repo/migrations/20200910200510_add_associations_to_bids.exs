defmodule Auction.Repo.Migrations.AddAssociationsToBids do
  use Ecto.Migration

  def change do
    alter table(:bids) do
      add(:item_id, references(:items))
      add(:user_id, references(:users))
    end

    # search bids for specific item
    create(index(:bids, [:item_id]))
    # search bids by specific user
    create(index(:bids, [:user_id]))
    # search bids by specific user on specific item
    create(index(:bids, [:item_id, :user_id]))
  end
end
