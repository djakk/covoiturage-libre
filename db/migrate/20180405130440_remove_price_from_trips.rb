class RemovePriceFromTrips < ActiveRecord::Migration[5.0]
  def change
    remove_column :trips, :price, :integer
  end
end
