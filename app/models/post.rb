class Post < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:description, :address]

  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :post_likes
  has_many :liked_users, class_name: 'User', through: :post_likes, source: :user
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :post_views

  has_many :post_boosts

  before_create :generate_auto_post_tags

  after_update :push_post_update
  after_touch :push_post_interaction
  after_create :push_post_create, :push_to_user_tags

  has_attached_file :picture, styles: {
    fb_image: "1200x630#",
    fb_image_thumb: "600x315#",
    cover: "600x"
  }
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/

  class << self
    def search_by_location(lat, long, radius = nil)
      if radius.nil?
        Post
          .where.not(lat: nil)
          .where.not(long: nil)
          .order("((posts.lat - #{lat})*(posts.lat - #{lat}) + (posts.long - #{long})*(posts.long - #{long})) asc")
      else
        Post
          .where.not(lat: nil)
          .where.not(long: nil)
          .where("SQRT((posts.lat - #{lat})*(posts.lat - #{lat}) + (posts.long - #{long})*(posts.long - #{long})) <= #{radius}")
          .order(created_at: :desc)
      end
    end
  end

  def user_id
    if post_type == 'crawl'
      return nil
    else
      return user.try(:id)
    end
  end

  def user_name
    if post_type == 'crawl'
      return crawl_user_name
    else
      return user.name
    end
  end

  def user_avatar_url
    if post_type == 'crawl'
      return crawl_user_avatar
    else
      return user.avatar.url(:thumb) if user.avatar.present?
    end
  end

  def user_email
    if post_type == 'crawl'
      return crawl_user_email
    else
      return user.email
    end
  end

  def picture_url=(url)
    return unless url.present?

    if /^data:image/.match(url)
      self.picture = url
    else
      self.picture = URI.parse(url)
    end
  end

  def interaction_count
    post_likes.count + comments.count
  end

  def to_api_json
    {
      id: id,
      picture_url: picture.url(:original),
      description: description,
      tags: self.post_tags.includes(:tag).where(is_auto: false).map {|pt| {id: pt.tag_id, name: pt.tag.name} },
      lat: lat,
      long: long,
      post_type: post_type || 'user',
      promotion_type: promotion_type,
      promotion_value: promotion_value,
      user: {
        id: user_id,
        name: user_name,
        email: user_email,
        avatar_url: user_avatar_url,
        is_store: ((user.present? && user.is_store?) ? true : false)
      },
      likes: {
        count: post_likes.count,
        people: post_likes.map do |p|
          {
            created_at: p.created_at,
            user: p.user.to_api_json
          }
        end
      },
      comments: {
        count: comments.count,
        comments: comments.root.in_order.map(&:to_api_json)
      }
    }
  end

  def push_post_interaction
    UserFeedGenerator.push_post(self, :interaction)
  end

  def push_post_create
    UserFeedGenerator.push_post(self, :create)
  end

  def push_post_update
    UserFeedGenerator.push_post(self, :update)
  end

  def boost_post
    UserFeedGenerator.push_post(self, :boost)
  end

  def extract_terms
    description.to_slug.normalize.transliterate(:vietnamese)
               .to_s.split('-').select {|term| term =~ /[a-zA-Z]+/i}
  end

  def generate_auto_post_tags
    self.extract_terms.each do |term|
      tag = Tag.find_by_name term
      next if tag.blank?
      self.post_tags << PostTag.new(
        post: self,
        tag: tag,
        is_auto: true
      )
    end
  end

  def push_to_user_tags
    return if self.user.blank?
    UserTag.generate_user_tags(self, self.user, 5)
  end

  def last_active_boost
    @last_active_boost = self.post_boosts.active.order(created_at: :desc).first
  end

  def boosting_status
    return @boosting_status if @boosting_status.present?
    if self.last_active_boost.blank? || !self.last_active_boost.persisted?
      @boosting_status = :deactivated
    elsif self.user.balance < self.last_active_boost.price
      @boosting_status = :halted
    else
      @boosting_status = :active
    end
    @boosting_status
  end

  def boost_spent
    @boost_spent = PostView.where(post_boost_id: self.post_boost_ids).sum(:price)
  end
end
