class CreatePrefferedFoods < ActiveRecord::Migration
  def change
    create_table :preffered_foods do |t|
      t.references :user, index: true
      t.integer :food_id
      t.string :food_name
    end
  end
end
