class Cooked < ActiveRecord::Base
  belongs_to :cooker, class_name: "User"
  belongs_to :cooked, class_name: "Recipe"
  validates :cooker_id, presence: true
  validates :cooked_id, presence: true
end

