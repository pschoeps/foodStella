class AddAbbreviatedToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :abbreviated, :string
  end
end
