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
      user.location = auth.extra.raw_info.hometown.name
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
        user.location = auth.extra.raw_info.hometown.name
      end
    end
  end

  def following?(recipe)
    Relationship.exists? follower_id: id, followed_id: recipe.id
  end

  def owns?(recipe)
    id == recipe.user_id
  end
end
