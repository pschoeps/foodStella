class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :references
      t.string :user

      t.string :fir_name
      t.string :las_name
      t.string :email
      t.string :country

      t.string :about_me
      t.string :picture_url
      t.integer :cooking_experience
      t.integer :average_cook_time

      t.timestamps
    end
  end
end
