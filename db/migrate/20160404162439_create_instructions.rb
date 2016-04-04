class CreateInstructions < ActiveRecord::Migration
  def change
    create_table :instructions do |t|
      t.references :recipe, index: true
      t.string :description
      t.integer :order

      t.timestamps
    end
  end
end
