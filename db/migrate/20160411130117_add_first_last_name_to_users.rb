class AddFirstLastNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fir_name, :string
    add_column :users, :las_name, :string
  end
end
