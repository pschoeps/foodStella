class CreateUserPreferences < ActiveRecord::Migration[5.0]
  def change
    create_table :user_preferences do |t|
      t.boolean :liked
      t.string :token

      t.references :recipe

      t.timestamps
    end
  end
end
