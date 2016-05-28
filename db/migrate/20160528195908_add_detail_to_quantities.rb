class AddDetailToQuantities < ActiveRecord::Migration
  def change
    add_column :quantities, :detail, :string
  end
end
