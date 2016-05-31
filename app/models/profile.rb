class Profile < ActiveRecord::Base
	belongs_to :user
	# for favorite ingredients?
	# has_many :ingredients

	mount_uploader :picture_url, ProfilePictureUploader
	mount_uploader :background_url, BackgroundPictureUploader

	validates_uniqueness_of :username, allow_blank: true, message: "is already taken"

	 def picture_size
      if picture_url.size > 5.megabytes
        errors.add(:picture_url, "should be less than 5MB")
      end
    end

end
