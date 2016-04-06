class Event < ActiveRecord::Base
  belongs_to :user
  has_one :recipe
end
