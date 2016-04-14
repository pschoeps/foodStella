class Profile < ActiveRecord::Base
	belongs_to :user
	# for favorite ingredients?
	# has_many :ingredients

	# mount_uploader :picture_url, ProfilePictureUploader

	 def picture_size
      if picture_url.size > 5.megabytes
        errors.add(:picture_url, "should be less than 5MB")
      end
    end
end
