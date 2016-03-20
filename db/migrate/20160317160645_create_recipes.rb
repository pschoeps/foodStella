class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.references :user, index: true
      t.string :name
      t.string :photo_url
      t.string :category

      t.timestamps
    end
  end
end
