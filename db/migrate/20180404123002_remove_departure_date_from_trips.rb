class RemoveDepartureDateFromTrips < ActiveRecord::Migration[5.0]
  def change
    remove_column :trips, :departure_date, :date
  end
end
