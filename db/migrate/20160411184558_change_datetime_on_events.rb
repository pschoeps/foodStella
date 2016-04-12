class ChangeDatetimeOnEvents < ActiveRecord::Migration
  def change
  	change_column :events, :start_at, :string
  	change_column :events, :end_at, :string
  end
end
