class AddPreferencesToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :liked_foods, :text
    add_column :profiles, :disliked_foods, :text
  end
end
