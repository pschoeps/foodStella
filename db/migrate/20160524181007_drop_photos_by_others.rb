class DropPhotosByOthers < ActiveRecord::Migration
  def change
  	drop_table :photos_by_others
  end
end
