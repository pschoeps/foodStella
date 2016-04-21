class CreateDeferredFoods < ActiveRecord::Migration
  def change
    create_table :deferred_foods do |t|
    		t.references :user, index: true
    	  	t.integer :food_id
    	  	t.string :food_name
      t.timestamps
    end
  end
end
