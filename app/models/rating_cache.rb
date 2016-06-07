class RatingCache < ActiveRecord::Base
  belongs_to :cacheable, :polymorphic => true #, :foreign_key=>"cacheable_id"
end