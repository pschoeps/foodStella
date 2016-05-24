class CreatePhotosByOthers < ActiveRecord::Migration
  def change
    create_table :photos_by_others do |t|
		t.string   "photo_url"

		t.belongs_to :recipe, index: true
		t.belongs_to :user, index: true
    end
  end
end
