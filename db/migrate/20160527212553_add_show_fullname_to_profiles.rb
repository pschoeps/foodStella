class AddShowFullnameToProfiles < ActiveRecord::Migration
  def change
  	add_column :profiles, :show_full_name, :boolean
  end
end
