class AddInfoToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :prep_time, :integer
    add_column :recipes, :cook_time, :integer
    add_column :recipes, :difficulty, :string
    add_column :recipes, :meal_type, :string
  end
end
