class AddSeatsToPoints < ActiveRecord::Migration[5.0]
  def change
    add_column :points, :seats, :integer
  end
end
