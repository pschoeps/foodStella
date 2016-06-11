class DropDeferredFoods < ActiveRecord::Migration
  def change
  	drop_table :deferred_foods
  end
end
