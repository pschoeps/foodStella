class ChangeRecipeDescriptionToText < ActiveRecord::Migration
  def change
  	change_column :recipes, :description, :text
  end
end
