class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
    	t.integer :user_id
    	t.integer :recipe_id
    	t.integer :rating

    	t.timestamps null: false
    end
    add_index :ratings, :user_id
    add_index :ratings, :recipe_id
    add_index :ratings, [:user_id, :recipe_id], unique: true
  end
end
