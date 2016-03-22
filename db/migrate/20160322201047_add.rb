class Add < ActiveRecord::Migration
  def change
  	add_column :quantities, :unit, :string
  end
end
