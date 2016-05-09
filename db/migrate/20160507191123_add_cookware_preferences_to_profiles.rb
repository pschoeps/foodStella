class AddCookwarePreferencesToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :cookware_preferences, :text
  end
end
