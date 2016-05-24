class OthersPhoto < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :user

  mount_uploader :photo_url, RecipePictureUploader
end
