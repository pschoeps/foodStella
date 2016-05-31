class ChangeOuncesToDecimal < ActiveRecord::Migration
  def change
  	change_column :quantities, :ounces, :decimal
  end
end
