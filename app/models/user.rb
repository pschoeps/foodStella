class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  has_many :recipes
  has_many :events, dependent: :destroy

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

  def self.from_omniauth(auth)
     where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
    	user.provider = auth.provider
    	user.uid = auth.uid
      	user.email = auth.info.email
      	user.password = Devise.friendly_token[0,20]
		user.name = auth.info.name
		user.image = auth.info.image
    end
  end
end
