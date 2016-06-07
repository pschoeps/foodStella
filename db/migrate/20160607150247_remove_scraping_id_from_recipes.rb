class RemoveScrapingIdFromRecipes < ActiveRecord::Migration
  def change
  	remove_column :recipes, :scraping_id, :integer
  end
end
