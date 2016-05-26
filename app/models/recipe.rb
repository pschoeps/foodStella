class Recipe < ActiveRecord::Base
  belongs_to :user
  has_many :quantities, dependent: :destroy
  has_many :ingredients, through: :quantities, dependent: :destroy

  belongs_to :event

  has_many :relationships,        foreign_key: "followed_id",
                                   dependent:   :destroy                                 
  has_many :followers, through: :relationships, source: :follower, dependent: :destroy

  has_many :cookeds,               foreign_key: "cooked_id",
                                   dependent:   :destroy   

  ratyrate_rateable "review"

  acts_as_commontable

  has_many :instructions, dependent: :destroy

  has_many :others_photos, dependent: :destroy, :order => 'id DESC'
  accepts_nested_attributes_for :others_photos, allow_destroy: true

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
  self.per_page = 12

  #this is some stuff I'm playing around with for searching and filtering recipes
  filterrific :default_filter_params => { :sorted_by => 'created_at_desc' },
              available_filters: [
              :sorted_by,
              :search_query,
              :with_created_at_gte,
              :latest,
              :sort_by_ingredients,
              :style,
              :difficulty,
              :meal_type
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
    when /^name_/
      order("LOWER(recipes.name) #{ direction }")
    when /^difficulty_/
      order("recipes.difficulty #{ direction }")
    when /^cook_time_/
      order("recipes.cook_time #{ direction }")
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :latest, lambda { |latest|
    order("recipes.created_at desc")
  }

  scope :style, lambda { |style|
    recipes = Recipe.arel_table
    where(recipes[:category].eq("#{style[0]}"))
  }

  scope :difficulty, lambda { |difficulty|
    recipes = Recipe.arel_table
    where(recipes[:difficulty].eq("#{difficulty[0]}"))
  }

  scope :meal_type, lambda { |meal_type|
     recipes = Recipe.arel_table
     where(recipes[:meal_type].eq("#{meal_type[0]}"))
  }

  scope :with_created_at_gte, lambda { |ref_date|
    where('recipes.created_at >= ?', ref_date)
  }

  scope :sort_by_ingredients, lambda { |ingredient_ids|
    # get a reference to the join table
    quantities = Quantity.arel_table
    # get a reference to the filtered table
    recipes = Recipe.arel_table
    # let AREL generate a complex SQL query
    where(
      Quantity \
        .where(quantities[:recipe_id].eq(recipes[:id])) \
        .where(quantities[:ingredient_id].in([*ingredient_ids].map(&:to_i))) \
        .exists
    )
  }

  def self.options_for_sort_by_ingredients
    [
      ['Tomato', 94], #tomato
      ['Rice', 95] #rice
    ]
  end

  def self.options_for_style
    [
      ['Medditerranean', 1], 
      ['Chinese', 2] 
    ]
  end

  def self.options_for_latest
    [
      ['Latest', 'created_at_desc']
    ]
  end

  def self.options_for_difficulty
    [
      ['Easy', 1],
      ['Medium', 2],
      ['Hard', 3]
    ]
  end

  def self.options_for_meal_type
    [
      ['Snack', 1],
      ['Side Dish', 2],
      ['Main Dish', 3],
      ['Dessert', 4],
      ['Drink', 5]
    ]
  end

  def self.options_for_sorted_by
    [
      ['Name (a-z)', 'name_asc'],
      ['Registration date (newest first)', 'created_at_desc'],
      ['Registration date (oldest first)', 'created_at_asc'],
      ['Difficulty (hardest first)',       'difficulty_desc'],
      ['Difficulty (easiest first)',       'difficulty_asc'],
      ['Cook Time (longest first)',        'cook_time_desc'],
      ['Cook Time (shortest first)',       'cook_time_asc']
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

    def get_user(id)
      if id == 0
        ''  # for stock recipes
      else
        User.find(id)
      end
    end

  def retrieve_pic
    recipe = Recipe.find(id)
    if recipe.remote_photo_url
      puts 'remote recipe url'
      recipe.remote_photo_url
    elsif recipe.photo_url
      puts recipe.photo_url
      puts "recipe photo url"
      recipe.photo_url.url
    else
      puts "no recipe url"
      ActionController::Base.helpers.asset_path('fallback/plate.jpg')
    end
  end

  def get_friendly_name
    recipe = Recipe.find(id)
    
    new_name = recipe.name.delete(' ').delete(')').delete('(').delete('/').delete('!').delete('.').delete('@')
    if new_name == nil
     "placeholder"
    else
      new_name
    end
  end

  def similar_recipes
    similar = []
    similar_ids = [id]
    keywords = Recipe.find(id).name.split(' ').reverse!
    keywords.each do |keyword|
      break if similar.length >= 16
      Recipe.where("lower(name) LIKE ?", "%#{keyword.downcase}%").each do |similar_recipe|
        break if similar.length >= 16
        unless similar_ids.include?(similar_recipe.id)
          similar.push( similar_recipe ) 
          similar_ids.push( similar_recipe.id ) 
        end
      end
    end
    # add random recipes until total == 16
    if similar.length < 16
      extra = Recipe.where('id NOT IN (?)', similar_ids).limit(16).order("RANDOM()")
      extra.each do |r|
        break if similar.length >= 16
        similar.push( r )
      end
    end
    similar
  end

  def ratings_count
    Rate.where("rateable_id = ?", id).length
  end

end
