class UpdateQuantities < ActiveRecord::Migration
  def change
  	change_table :quantities do |t|
      t.belongs_to :recipe, index: true
      t.belongs_to :ingredient, index: true
    end
  end
end
