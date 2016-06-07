class RemoveAbbreviatedFromRecipes < ActiveRecord::Migration
  def change
  	remove_column :recipes, :abbreviated, :string
  end
end
