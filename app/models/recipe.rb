class Recipe < ActiveRecord::Base
  belongs_to :user
  has_many :quantities, dependent: :destroy
  has_many :ingredients, through: :quantities #, dependent: :destroy

  belongs_to :event

  has_many :relationships,        foreign_key: "followed_id",
                                   dependent:   :destroy                                 
  has_many :followers, through: :relationships, source: :follower, dependent: :destroy

  has_many :cookeds,               foreign_key: "cooked_id",
                                   dependent:   :destroy   

  ratyrate_rateable "review"
  has_many :rates, as: :rateable, foreign_key: "rateable_id"
  has_many :rating_caches, as: :cacheable, foreign_key: "cacheable_id", class_name: RatingCache

  acts_as_commontable

  has_many :instructions, dependent: :destroy

  has_many :others_photos, dependent: :destroy #, :order => 'id DESC'
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
              :meal_type,
              :cook_time,
              :prep_time,
              :cookware,
              :ratings_count,
              :ratings_average,
              :my_favorites,
              :trending,
              :cooked,
              :owns,
              :following,
              :search_query_my_foods,
              :total_time,
              ]



  scope :search_query, lambda { |query|
    return nil  if query.blank?
    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      # (e.gsub('*', '%') + '%').gsub(/%+/, '%')
      # prepend '%' to search full name
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 3
    where(
      terms.map {
        or_clauses = [
          "LOWER(recipes.name) LIKE ?",
          "LOWER(recipes.description) LIKE ?",
          "LOWER(ingredients.name) LIKE ?"
          # "LOWER(user.fir_name) LIKE ?"
        ].join(' OR ')
        "(#{ or_clauses })"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    ).includes(:ingredients)
    .group('ingredients.id')
    .group('recipes.id')
    #.joins(:user)
  }

  scope :sorted_by, lambda { |sort_option|
    if sort_option == 'RANDOM()'
      order(sort_option)
    else
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
      when /^total_time_/
        # order("recipes.cook_time + recipes.prep_time #{ direction 
        order("COALESCE(recipes.cook_time,0) + COALESCE(recipes.prep_time,0) #{ direction }")
      when /^ratings_average_/
        order("rating_caches.avg #{ direction } NULLS LAST").includes(:rating_caches).group('rating_caches.avg').group('rating_caches.id').group('recipes.id')
      when /^ratings_count_/
        order("rating_caches.qty #{ direction } NULLS LAST").includes(:rating_caches).group('rating_caches.qty').group('rating_caches.id').group('recipes.id')
      when /^my_favorites_/
        order("rates.stars #{ direction } NULLS LAST").includes(:rates).group('rates.stars').group('rates.id').group('recipes.id')
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
      end
    end
  }

  scope :latest, lambda { |latest|
    order("recipes.created_at desc")
  }

  scope :style, lambda { |style|
    # recipes = Recipe.arel_table
    # where(recipes[:category].eq("#{style[0]}"))
    styles = []
    style.each do |s|
      styles.push(options_for_style[s-1][0].downcase) # use strings as well as keys
      styles.push(options_for_style[s-1][1])
    end
    pg_styles = styles.map {|val| "%#{val}%" }
    where('lower(recipes.category) ILIKE ANY ( array[?] )', pg_styles)
  }

  scope :difficulty, lambda { |difficulty|
    # recipes = Recipe.arel_table
    # where(recipes[:difficulty].eq("#{difficulty[0]}"))
    difficulty = difficulty.map(&:to_s)
    where(difficulty: [*difficulty])
  }

  scope :meal_type, lambda { |meal_type|
     # recipes = Recipe.arel_table
     # where(recipes[:meal_type].eq("#{meal_type[0]}"))
     meal_type = meal_type.map(&:to_s)
     where(meal_type: [*meal_type])
  }

  scope :with_created_at_gte, lambda { |ref_date|
    where('recipes.created_at >= ?', ref_date)
  }

  scope :owns, lambda { |user_id|
     recipes = Recipe.arel_table
     where(recipes[:user_id].eq("#{user_id}"))
  }

  scope :following, lambda { |user_id|
     recipes = Recipe.arel_table
     relationships = Relationship.arel_table
     # let AREL generate a complex SQL query
     where(
       Relationship \
         .where(relationships[:followed_id].eq(recipes[:id])) \
         .where(relationships[:follower_id].eq("#{user_id}")) \
         .exists
     )
  }

  scope :cooked, lambda { |user_id|
     recipes = Recipe.arel_table
     cookeds = Cooked.arel_table
     # let AREL generate a complex SQL query
     where(
       Cooked \
         .where(cookeds[:cooked_id].eq(recipes[:id])) \
         .where(cookeds[:cooker_id].eq("#{user_id}")) \
         .exists
     )
  }

  scope :total_time, lambda { |total_time|
    bottom = options_for_total_time[total_time[0]-1][2]
    top = options_for_total_time[total_time[0]-1][3]
    where('cook_time + prep_time >= :b AND cook_time + prep_time < :t', {b: bottom, t: top})
  }

  scope :sort_by_ingredients, lambda { |ingredient_ids|
    # get a reference to the join table
        # quantities = Quantity.arel_table
        # ingredients = Ingredient.arel_table
        # recipes = Recipe.arel_table
      puts ingredient_ids
        main_ingredients = []
        ingredient_ids.each do |i|
          main_ingredients.push(options_for_sort_by_ingredients[i-1][0].downcase) # get ingredient name
          # if options_for_sort_by_ingredients[i-1][2]
          #   main_ingredients.push(options_for_sort_by_ingredients[i-1][2].downcase) # for alternate names
          # end
        end
        pg_ingredients = main_ingredients.map {|val| "%#{val}%" }
        @matching_ingredients = Ingredient.where('lower(name) ILIKE ANY ( array[?] )', pg_ingredients)
        @ingred_ids = []
        @matching_ingredients.each do |i|
          @ingred_ids.push(i.id.to_i)
        end
        puts @ingred_ids

    # let AREL generate a complex SQL query
    # @ingred_ids.each do |id|
    # id = 1
    #   where(
    #     Quantity \
    #       .where(quantities[:recipe_id].eq(recipes[:id])) \
    #       .where(quantities[:ingredient_id].eq(id)) \
    #       # .where(quantities[:ingredient_id].in([*@ingred_ids].map(&:to_i))) \
    #       .exists
    #   )
       #.join(' AND '),
      # if id != @indred_ids.last
        # " AND "
      # end
    # end

      # num_or_conditions = 1
      # where(
      #   ingredient_ids.map {
      #     or_clauses = [
      #       "ingredients.id) = ?"
      #     ].join(' OR ')
      #     "(#{ or_clauses })"
      #   }.join(' AND '),
      #   *ingredient_ids.map { |e| [e] * num_or_conditions }.flatten
      # ).includes(:ingredients)


      # Recipe.joins(:ingredients).where("ingredients.id IN (?)", @ingred_ids)

      # @people = Person.find(:all, 
      #    :joins => :favourites,
      #    :select => "person.*, count(favourites) favourite_count", 
      #    :conditions => {:favourites => @array_of_favourites}, 
      #    :group => "persons.id having favourite_count = #{@array_of_favourites.count}")

      # .where(ingredients: { name: pg_ingredients })
      Recipe.joins(:ingredients)
        .where('lower(ingredients.name) ILIKE ANY ( array[?] )', pg_ingredients)
        .group("recipes.id")
        .having("count(ingredients.name) = #{pg_ingredients.count}")
  }

  scope :search_query_my_foods, lambda { |query|
    return nil  if query.blank?
    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      # (e.gsub('*', '%') + '%').gsub(/%+/, '%')
      # prepend '%' to search full name
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 1
    where(
      terms.map {
        or_clauses = [
          "LOWER(recipes.name) LIKE ?",
          # "LOWER(recipes.description) LIKE ?",
          # "LOWER(ingredients.name) LIKE ?"
        ].join(' OR ')
        "(#{ or_clauses })"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
    # .includes(:ingredients)
    # .group('ingredients.id')
    # .group('recipes.id')
    #.joins(:user)
  }

  def self.options_for_sort_by_ingredients
    [
      ['Meat',1,'Beef'],
      ['Chicken',2],
      ['Soup',3],
      ['Vegetarian',4,'vegetable'],
      ['Vegan',5],
      ['Fish',6],
      ['Lobster',7],
      ['Octopus',8],
      ['Shrimp',9],
      ['Clams',10],
      ['Rice',11],
      ['Quinoa',12],
      ['Pasta',13],
      ['Pizza',14],
      ['Sandwiches',15],
      ['Salads',16],
      ['Duck',17],
      ['Cheese',18],
      ['Tofu',19]
    ]
  end

  def self.options_for_style
    [
      ['Burgers', 1],
      ['Casserole', 2],
      ['Chili', 3],
      ['Healthy', 4],
      ['Italian', 5],
      ['Mexican', 6],
      ['Salad', 7],
      ['Seafood', 8],
      ['Soup', 9],
      ['Mediterranean', 10]
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

  def self.options_for_cookware
    [
      ['Microwave', 1],
      ['Oven', 2],
      ['Frying Pan', 3],
      ['Barbecue Grill', 4],
      ['Toaster', 5],
      ['Pancake Maker', 6],
      ['Fundu', 7]
    ]
  end

  def self.options_for_sorted_by
    [
      ['Recommended', 'created_at_asc'],
      ['Trending', 'created_at_desc'],
      ['Latest', 'created_at_desc'],
      ['Oldest', 'created_at_asc'],
      # ['Difficulty (hardest first)',       'difficulty_desc'],
      # ['Difficulty (easiest first)',       'difficulty_asc'],
      # ['Cook Time (longest first)',        'cook_time_desc'],
      # ['Cook Time (shortest first)',       'cook_time_asc'],
      # ['Prep Time (longest first)',        'prep_time_desc'],
      # ['Prep Time (shortest first)',       'prep_time_asc'],
      ['Time (shortest first)',              'total_time_asc'],
      ['Time (longest first)',               'total_time_desc'],
      ['Average Rating',                     'ratings_average_desc'],
      ['Most Rated',                         'ratings_count_desc'],
      ['My Favorites',                       'my_favorites_desc'],
      # ['Lowest Rating',       'prep_time_asc'],
      # ['Popular',       'prep_time_asc'],
      # ['Fewest Ratings',       'prep_time_asc']
    ]
  end

  def self.options_for_total_time
    [
      ['< 15 min', 1, 0,14],
      ['15-30 min', 2, 15,29],
      ['30-45 min', 3, 20,44],
      ['45-60 min', 4, 45,59],
      ['> 1 hour', 5, 60,9999]
    ]
  end

  def self.options_for_cook_time
  end

  def self.options_for_prep_time
  end

  def self.options_for_ratings_count
  end

  def self.options_for_ratings_average
  end

  def self.options_for_my_favorites
  end

  def self.options_for_trending
  end

  def self.options_for_cooked
    [
      ["Recipes I've Cooked"]
    ]
  end

  def self.options_for_following
  end

  def self.options_for_owns
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

  def get_short_time(cookOrPrep)
    if cookOrPrep == 'cook'
      minutes = cook_time.to_i
    else
      minutes = prep_time.to_i
    end
    if minutes < 60
      minutes.to_s + ' mins'
    else
      hrs = minutes/60
      mins = minutes % 60
      mins = '0' + mins.to_s if mins < 10
      if mins == '00'
        hrs.to_s + ' hour' if hrs == 1
        hrs.to_s + ' hrs' if hrs != 1
      else
        # hrs.to_s + 'h ' + mins.to_s + 'mins'
        hrs.to_s + ':' + mins.to_s + ' hrs'
      end
    end
  end

  def get_friendly_time(cookOrPrep)
    if cookOrPrep == 'cook'
      minutes = cook_time.to_i
    else
      minutes = prep_time.to_i
    end
    timeString = ''
    unitString = ''
    if minutes < 60
      timeString = minutes.to_s
      unitString = 'Minutes'
    else
      hrs = minutes/60
      unitString = hrs > 1 ? 'Hours' : 'Hour'

      mins = minutes % 60
      mins = '0' + mins.to_s if mins < 10

      if mins == '00'
        timeString = hrs.to_s
      else
        timeString =  hrs.to_s + ':' + mins.to_s
      end
    end
    [timeString, unitString]
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
