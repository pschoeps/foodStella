class AddOuncesToQuantities < ActiveRecord::Migration
  def change
    add_column :quantities, :ounces, :integer
  end
end
