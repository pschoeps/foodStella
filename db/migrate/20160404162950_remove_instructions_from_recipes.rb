class RemoveInstructionsFromRecipes < ActiveRecord::Migration
  def change
    remove_column :recipes, :instructions, :string
  end
end
