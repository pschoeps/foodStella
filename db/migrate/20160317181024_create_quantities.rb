class CreateQuantities < ActiveRecord::Migration
  def change
    create_table :quantities do |t|
      t.string :amount
      t.string :decimal
      t.string :ingredient

      t.timestamps
    end
  end
end
