class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable, :omniauth_providers => [:facebook]

  has_many :recipes
  has_many :events, dependent: :destroy

  has_many :relationships,        foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :following, through: :relationships, source: :followed

  has_many :cookeds,             foreign_key: "cooker_id",
                                  dependent:   :destroy
  # has_many :following, through: :relationships, source: :followed

  has_many :others_photos, dependent: :destroy
  
  ratyrate_rater

  acts_as_commontator

  validates_uniqueness_of :username, allow_blank: true

  has_one :profile, dependent: :destroy
  # attr_accessible :fir_name, :las_name, :username, :about_me, :image
  # accepts_nested_attributes_for :profile
  after_create :generate_profile
  # after_create :default_foods

  def generate_profile
    # self.build_profile(fir_name: self.fir_name, las_name: self.las_name, username: self.username, email: self.email, picture_url: self.image, country: self.country)
    # self.build_profile()
    Profile.create(user_id: self.id, fir_name: self.fir_name, las_name: self.las_name, username: self.username, email: self.email, picture_url: self.image, country: self.country)
  end

  def default_foods
    snack = Recipe.where(name: 'Two-Cheese Party Pastries').first
    Relationship.create(follower_id: self.id, followed_id: snack.id)
    main_dish_1 = Recipe.where(name: 'Pizza-Style Vegetables').first
    Relationship.create(follower_id: self.id, followed_id: main_dish_1.id )
    main_dish_2 = Recipe.where(name: 'Juicy Texas Burgers').first
    Relationship.create(follower_id: self.id, followed_id: main_dish_2.id )
    dessert = Recipe.where(name: 'Apricot Bar Cookies').first
    Relationship.create(follower_id: self.id, followed_id: dessert.id)
  end

  has_many :preferred_ingredients, dependent: :destroy
  # accepts_nested_attributes_for :preferred_ingredients
  has_many :preferred_foods, dependent: :destroy
  has_many :deferred_foods, dependent: :destroy

  #friendships setup
  has_many :friendships
  has_many :friends, -> { where(friendships: {status: 'accepted'}).order('created_at DESC') },
           :through => :friendships

  
  has_many :requested_friends, -> { where(friendships: {status: 'requested'}).order('created_at DESC') },
           :through => :friendships,
           :source => :friend
  
  has_many :pending_friends, -> { where(friendships: {status: 'pending'}).order('created_at DESC') },
           :through => :friendships,
           :source => :friend

  # facebook omniauth info
  def self.from_omniauth(auth)
    if !where(email: auth.info.email).empty?
  		user = where(email: auth.info.email).first
  		user.provider = auth.provider
  		user.uid = auth.uid
  		user.image = auth.info.image
      user.fir_name = auth.info.first_name
      user.las_name = auth.info.last_name
      # user.hometown = auth.extra.raw_info.hometown.name
      user.location = auth.extra.raw_info.locale
      user.about_me = auth.extra.raw_info.about_me
      user.age_range = auth.info.age_range
      user.skip_confirmation!
  		user.save!
  		user
  	else
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.password = Devise.friendly_token[0,20]
        user.name = auth.info.name
        user.image = auth.info.image
        user.fir_name = auth.info.first_name
        user.las_name = auth.info.last_name
        # user.hometown = auth.extra.raw_info.hometown.name
        user.location = auth.extra.raw_info.locale
        user.about_me = auth.extra.raw_info.about_me
        user.age_range = auth.info.age_range

        user.skip_confirmation!
        user.save!
        user
        # user.country = auth.extra.raw_info.location.country ??
      end
    end
  end

  def following?(recipe)
    Relationship.exists? follower_id: id, followed_id: recipe.id
  end

  def retrieve_pic
    user = User.find(id)
    if user.profile && user.profile.picture_url
      user.profile.picture_url
    elsif user.image
      user.image
    else
      ActionController::Base.helpers.asset_path('fallback/plate.jpg')
    end
  end

  def retrieve_name(whichName = '')
    user = User.find(id)
    if whichName == 'check'
      whichName = user.profile.show_full_name ? '' : 'username'
    end
    if whichName == 'username'
      if user.profile && profile.username
        profile.username
      elsif user.username
        user.username
      elsif user.profile && user.profile.fir_name && user.profile.las_name
        user.profile.fir_name + ' ' + user.profile.las_name[0] + '.'
      elsif user.fir_name && user.las_name
        user.fir_name + ' ' + user.las_name[0] + '.'
      end
    elsif whichName == 'first'
      if user.profile && user.profile.fir_name
        user.profile.fir_name
      elsif user.fir_name
        user.fir_name
      else
        ''
      end
    else
      if user.profile && user.profile.fir_name && user.profile.las_name
        user.profile.fir_name + ' ' + user.profile.las_name
      elsif user.fir_name && user.las_name
        user.fir_name + ' ' + user.las_name
      else
        '- -'
      end
    end
  end

  def owns?(recipeOrProfile)
    id == recipeOrProfile.user_id
  end

  def cooked?(recipe)
    Cooked.exists? cooker_id: id, cooked_id: recipe.id
  end


  # default for will_paginate
  self.per_page = 10

  filterrific :default_filter_params => { :sorted_by => 'created_at_desc' },
            available_filters: [
                :sorted_by,
                :search_query,
                :with_created_at_gte
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
          "LOWER(users.fir_name) LIKE ?"
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
      order("users.created_at #{ direction }")
    when /^name_/
      order("LOWER(users.fir_name) #{ direction }")
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def self.options_for_sorted_by
  [
    ['Name (a-z)', 'name_asc'],
    ['Registration date (newest first)', 'created_at_desc'],
    ['Registration date (oldest first)', 'created_at_asc']
  ]
  end

end
