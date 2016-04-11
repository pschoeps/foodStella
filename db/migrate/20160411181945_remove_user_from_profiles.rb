class RemoveUserFromProfiles < ActiveRecord::Migration
  def change
  	remove_column :profiles, :user, :string
  	remove_column :profiles, :references, :string
  end
end
