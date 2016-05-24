class CreateOthersPhotos < ActiveRecord::Migration
  def change
    create_table :others_photos do |t|
    	t.string   "photo_url"

    	t.belongs_to :recipe, index: true
    	t.belongs_to :user, index: true
    end
  end
end
