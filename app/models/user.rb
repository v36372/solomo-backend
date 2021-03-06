class User < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:first_name, :last_name, :email]

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
  has_many :followings, through: :user_followings, source: :following

  has_many :user_followers, class_name: 'UserFollowing', foreign_key: 'following_id'
  has_many :followers, through: :user_followers, source: :user

  has_many :post_likes
  has_many :liked_posts, class_name: 'Post', through: :post_likes, source: :post

  has_many :comments, dependent: :destroy
  has_many :user_feeds

  has_one :store, dependent: :destroy
  accepts_nested_attributes_for :store

  has_many :user_tags, dependent: :destroy
  has_many :post_views

  has_many :user_profile_views
  has_many :user_payments
  has_many :user_transactions

  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
  validates :first_name, :last_name, presence: true, unless: :api?

  before_save :ensure_authentication_token

  scope :verified_stores, -> { joins(:store).where(stores: {status: 'verified'}) }
  scope :processing_stores, -> { joins(:store).where.not(stores: {status: 'verified'}) }

  ##############################################################
  # REGISTRATION
  ##############################################################
  def assign_fb_attributes(auth)
    # Basic information
    self.first_name ||= auth.info.first_name
    self.last_name ||= auth.info.last_name

    if self.first_name.blank? && self.last_name.blank? && auth.info.name.present?
      name_splits = auth.info.name.split(' ')
      self.first_name = name_splits.first
      self.last_name = name_splits[1..(name_splits.length - 1)].join(' ')
    end

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

  def name=(other_name)
    name_splits = other_name.split(' ')
    self.last_name = name_splits.first
    self.first_name = name_splits[1..(name_splits.length - 1)].join(' ')
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.exists?(authentication_token: token)
    end
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def to_api_json(options = {})
    processed_birthday = nil
    processed_birthday = birthday.strftime('%d/%m/%Y') if birthday.present?

    processed_avatar = nil
    processed_avatar = avatar.url(:thumb) if avatar.present?

    result = {
      id: id,
      name: name,
      emai: email,
      birthday: processed_birthday,
      avatar: processed_avatar,
      is_store: self.is_store?,
      followers: followers.count,
      followings: followings.count
    }

    if options[:include_store] && self.is_store?
      result[:store] = self.store.to_api_json
    end

    if options[:include_posts]
      result[:posts] = self.posts.map(&:to_api_json)
    end

    if options[:include_liked_posts]
      like_post_ids = PostLike.where(user_id: self.id).pluck(:post_id)
      result[:liked_posts] = Post.where(id: like_post_ids).map(&:to_api_json)
    end

    result
  end

  def interaction_count
    posts.count + post_likes.count + comments.count
  end

  def age
    return nil if birthday.nil?
    Time.current.beginning_of_year.year - birthday.beginning_of_year.year
  end

  def is_store?
    self.store.present? && self.store.verified?
  end

  def is_following?(other_user)
    UserFollowing.where(user_id: self.id, following_id: other_user.id).exists?
  end

  def followed_by?(other_user)
    UserFollowing.where(user_id: other_user.id, following_id: self.id).exists?
  end

  def balance_used
    UserTransaction.where('amount is not null and amount < 0').sum(:amount).abs
  end

  def balance_charged
    UserTransaction.where('amount is not null and amount > 0').sum(:amount)
  end

  private

  def api?
    self.validation_context == :api
  end

end
