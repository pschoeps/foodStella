class Recipe < ActiveRecord::Base
  belongs_to :user
  has_many :quantities, dependent: :destroy
  has_many :ingredients, through: :quantities
  has_many :instructions
  has_one :recipe
  #mount profile picture for recipes
  mount_uploader :photo_url, RecipePictureUploader

  accepts_nested_attributes_for :quantities, allow_destroy: true
  accepts_nested_attributes_for :ingredients
  accepts_nested_attributes_for :instructions, allow_destroy: true

  validates :name, presence: true
  validates :category, presence: true
  validate  :picture_size
  validate :instructions_order

  # Validates the size of an uploaded picture.
    def picture_size
      if photo_url.size > 5.megabytes
        errors.add(:photo_url, "should be less than 5MB")
      end
    end

    # Defines the order of the instructions.
    def instructions_order
      instructions.each_with_index do |i, index|
        i.order = index + 1
      end
    end
end
