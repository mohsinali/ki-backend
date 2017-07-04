class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable#, :validatable

  validates :auth_token, uniqueness: true
  validates :name, presence: true

  has_many :points
  has_many :favorites, through: :points, source: :broadband

  has_many :user_broadbands
  has_many :broadbands, through: :user_broadbands

  before_create :generate_authentication_token!

  def generate_authentication_token!
    begin
      self.auth_token = Devise.friendly_token 32
    end while self.class.exists?(auth_token: auth_token)
  end

  def set_favorite_point!(point)
    unless self.favorites.include? point
      self.favorites << point
    end
  end

  def has_favorite?(point)
    self.favorites.include? point
  end

  def remove_favorite_point!(point)
    self.favorites.delete point
  end

  def self.custom_oauth(provider, uid, token)
    where(provider: provider, uid: uid).first_or_create do |user|
      user.provider = provider
      user.uid      = uid
      user.oauth_token = token
      user.save!
    end
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid      = auth.uid
      user.name     = auth.info.name
      user.email    = auth.info.email
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = auth.credentials.expires_at.present? ? Time.at(auth.credentials.expires_at) : ''
      user.save!
    end
  end

  def can_edit_broadband(broadband)
    broadbands.include?(broadband)
  end

end
