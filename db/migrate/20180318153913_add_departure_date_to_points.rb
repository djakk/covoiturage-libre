class AddDepartureDateToPoints < ActiveRecord::Migration[5.0]
  def change
    add_column :points, :departure_date, :date
  end
end
