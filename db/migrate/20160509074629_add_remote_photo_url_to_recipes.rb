class AddRemotePhotoUrlToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :remote_photo_url, :string
  end
end
