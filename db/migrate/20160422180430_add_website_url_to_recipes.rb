class AddWebsiteUrlToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :website_url, :string
  end
end
