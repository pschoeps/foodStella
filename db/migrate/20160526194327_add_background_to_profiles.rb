class AddBackgroundToProfiles < ActiveRecord::Migration
  def change
  	add_column :profiles, :background_url, :string
  	add_column :profiles, :background_offset, :integer
  end
end
