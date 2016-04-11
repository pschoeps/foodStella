class Profile < ActiveRecord::Base
	has_one :user
	# for favorite ingredients?
	# has_many :ingredients
end
