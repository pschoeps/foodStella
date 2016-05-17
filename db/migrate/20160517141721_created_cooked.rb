class CreatedCooked < ActiveRecord::Migration
  def change
  	create_table :cookeds do |t|
  	  t.integer :cooker_id
  	  t.integer :cooked_id

  	  t.timestamps null: false
  	end
  	add_index :cookeds, :cooker_id
  	add_index :cookeds, :cooked_id
  	add_index :cookeds, [:cooker_id, :cooked_id], unique: true
  end
end
