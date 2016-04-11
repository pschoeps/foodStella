class Profile < ActiveRecord::Base
	belongs_to :user
	# for favorite ingredients?
	# has_many :ingredients
end
