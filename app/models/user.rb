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

  has_one :profile

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
    puts '============================================================================================================================'
    puts auth
    puts auth.info.image
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

  def owns?(recipe)
    id == recipe.user_id
  end
end
