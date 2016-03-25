class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.references :user, index: true
      t.references :recipe, index: true

      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end
end
