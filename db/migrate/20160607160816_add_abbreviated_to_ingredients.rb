class AddAbbreviatedToIngredients < ActiveRecord::Migration
  def change
    add_column :ingredients, :abbreviated, :string
  end
end
