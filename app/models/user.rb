class User < ActiveRecord::Base
  attr_accessor :avatar_image
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :async,
         :validatable, :omniauthable, omniauth_providers: [:facebook]
  has_attached_file :avatar, styles: {
    large: "400x400#",
    edium: "200x200#",
    thumb: "100x100#"
  }

  has_many :posts

  has_many :user_followings, class_name: 'UserFollowing', foreign_key: 'user_id'
  has_many :followings, through: :user_followings, source: :user

  has_many :user_followers, class_name: 'UserFollowing', foreign_key: 'following_id'
  has_many :followers, through: :user_followers, source: :following

  has_many :post_likes
  has_many :liked_posts, class_name: 'Post', through: :post_likes, source: :post

  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
  validates :first_name, :last_name, presence: true, unless: :api?

  before_save :ensure_authentication_token

  ##############################################################
  # REGISTRATION
  ##############################################################
  def assign_fb_attributes(auth)
    # Basic information
    self.first_name ||= auth.info.first_name
    self.last_name ||= auth.info.last_name
    self.email ||= auth.info.email
    self.uid = auth.uid
    self.provider = "facebook"
    self.avatar_image = "https://graph.facebook.com/#{auth.uid}/picture?type=large" unless self.avatar?
    # Token to use for calling facebook api
    self.facebook_expires_at = auth.credentials.expires_at
    self.facebook_token = auth.credentials.token
  end

  def avatar_image=(url)
    return unless url.present?

    if /^data:image/.match(url)
      self.avatar = url
    else
      self.avatar = URI.parse(url)
    end
  end

  def name
    [last_name, first_name].join(" ")
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.exists?(authentication_token: token)
    end
  end

  private

  def api?
    self.validation_context == :api
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end
end
