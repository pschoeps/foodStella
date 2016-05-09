class AddScrapingIdToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :scraping_id, :integer
  end
end
