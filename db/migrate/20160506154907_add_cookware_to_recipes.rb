class AddCookwareToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :cookware, :text
  end
end
