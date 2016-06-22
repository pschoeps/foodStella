class AddIndivServingToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :servings, :integer
  end
end
