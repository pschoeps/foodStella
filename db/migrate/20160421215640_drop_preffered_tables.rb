class DropPrefferedTables < ActiveRecord::Migration
  def change
  	drop_table :preffered_ingredients
  	drop_table :preffered_foods
  	drop_table :deffered_foods
  end
end