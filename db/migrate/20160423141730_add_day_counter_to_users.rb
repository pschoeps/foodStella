class AddDayCounterToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :day_counter, :integer,  default: 3
  	add_column :users, :day_counter_last_updated_at, :datetime
  end
end
