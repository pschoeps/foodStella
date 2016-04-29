class ChangeInstructionsToText < ActiveRecord::Migration
  def change
  	change_column :instructions, :description, :text
  end
end
