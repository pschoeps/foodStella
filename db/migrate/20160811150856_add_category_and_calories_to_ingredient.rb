class AddCategoryAndCaloriesToIngredient < ActiveRecord::Migration[5.0]
  def change
  	add_column :ingredients, :calories, :decimal
  	add_column :ingredients, :category, :string
  end
end
