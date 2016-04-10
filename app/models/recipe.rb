class Recipe < ActiveRecord::Base
  belongs_to :user
  has_many :quantities, dependent: :destroy
  has_many :ingredients, through: :quantities

  belongs_to :event

  has_many :relationships,        foreign_key: "followed_id",
                                   dependent:   :destroy
                                   
  has_many :followers, through: :relationships, source: :follower, dependent: :destroy

  has_many :instructions

  #mount profile picture for recipes
  mount_uploader :photo_url, RecipePictureUploader

  accepts_nested_attributes_for :quantities, allow_destroy: true
  accepts_nested_attributes_for :ingredients
  accepts_nested_attributes_for :instructions, allow_destroy: true

  validates :name, presence: true
  validates :category, presence: true
  validate  :picture_size
  validate :instructions_order

  # default for will_paginate
  self.per_page = 10

  #this is some stuff I'm playing around with for searching and filtering recipes
  filterrific :default_filter_params => { :sorted_by => 'created_at_desc' },
              :available_filters => %w[
                sorted_by
                search_query
                with_created_at_gte
              ]



  scope :search_query, lambda { |query|
    return nil  if query.blank?
    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      (e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 1
    where(
      terms.map {
        or_clauses = [
          "LOWER(recipes.name) LIKE ?"
        ].join(' OR ')
        "(#{ or_clauses })"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/
      order("recipes.created_at #{ direction }")
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_created_at_gte, lambda { |ref_date|
    where('recipes.created_at >= ?', ref_date)
  }

  def self.options_for_sorted_by
    [
      ['Name (a-z)', 'name_asc'],
      ['Registration date (newest first)', 'created_at_desc'],
      ['Registration date (oldest first)', 'created_at_asc']
    ]
  end

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
