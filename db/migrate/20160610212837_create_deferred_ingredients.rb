class CreateDeferredIngredients < ActiveRecord::Migration
  def change
    create_table :deferred_ingredients do |t|
			t.references :user, index: true
		  	t.integer :ingredient_id
		  	t.string :ingredient_name
	  t.timestamps
    end
  end
end
