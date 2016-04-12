class AddRecipeNameToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :recipe_name, :string
  end
end
