class AddFieldsToRecipes < ActiveRecord::Migration
  def change
  	 add_column :recipes, :description, :string
  	 add_column :recipes, :instructions, :string
  end
end
