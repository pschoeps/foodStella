class DropPreferredFoods < ActiveRecord::Migration
  def change
  	drop_table :preferred_foods
  end
end
