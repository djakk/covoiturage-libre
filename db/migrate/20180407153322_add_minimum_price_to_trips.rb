class AddMinimumPriceToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :minimum_price, :integer
  end
end
