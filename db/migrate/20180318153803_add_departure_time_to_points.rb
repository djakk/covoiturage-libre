class AddDepartureTimeToPoints < ActiveRecord::Migration[5.0]
  def change
    add_column :points, :departure_time, :time
  end
end
