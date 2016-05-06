class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  has_many :recipes
  has_many :events, dependent: :destroy

  has_many :relationships,        foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :following, through: :relationships, source: :followed

  has_one :profile, dependent: :destroy
  # attr_accessible :fir_name, :las_name, :username, :about_me, :image
  # accepts_nested_attributes_for :profile
  after_create :generate_profile

  def generate_profile
    self.build_profile(fir_name: self.fir_name, las_name: self.las_name, username: self.username, email: self.email, picture_url: self.image, country: self.country)
    # self.build_profile()
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
      user.hometown = auth.extra.raw_info.hometown.name
      user.location = auth.extra.raw_info.location
      user.about_me = auth.extra.raw_info.about_me
      user.age_range = auth.info.age_range
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
        user.hometown = auth.extra.raw_info.hometown.name
        user.location = auth.extra.raw_info.location.name
        user.about_me = auth.extra.raw_info.about_me
        user.age_range = auth.info.age_range
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

  def retrieve_name(firLas = '')
    user = User.find(id)
    fir_name = ''
    las_name = ''
    username = ''
    if user.profile && profile.username
      username = profile.username
    elsif user.username
      username = user.username
    elsif user.profile && user.profile.fir_name && user.profile.las_name
      fir_name = user.profile.fir_name
      las_name = user.profile.las_name
    elsif user.fir_name && user.las_name
      fir_name = user.fir_name
      las_name = user.las_name
    else
      fir_name = ''
      las_name = ''
    end
    #return
    if username != ''
      username
    elsif firLas == 'first'
      fir_name
    elsif firLas == 'last'
      las_name
    else
      fir_name + ' ' + las_name
    end
  end

  def owns?(recipe)
    id == recipe.user_id
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
