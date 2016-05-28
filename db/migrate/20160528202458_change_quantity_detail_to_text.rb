class ChangeQuantityDetailToText < ActiveRecord::Migration
  def change
  	change_column :quantities, :detail, :text
  end
end
