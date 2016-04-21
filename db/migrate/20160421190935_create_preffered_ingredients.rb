class CreatePrefferedIngredients < ActiveRecord::Migration
  def change
    create_table :preffered_ingredients do |t|
    	t.references :user, index: true
    	t.integer :ingredient_id
    	t.string :ingredient_name
      t.timestamps
    end
  end
end
