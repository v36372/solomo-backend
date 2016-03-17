class Post < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:description, :address]

  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :post_likes
  has_many :liked_users, class_name: 'User', through: :post_likes, source: :user
  belongs_to :user

  has_attached_file :picture, styles: {
    fb_image: "1200x630#",
    fb_image_thumb: "600x315#",
    cover: "600x"
  }
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/

  class << self
    def search_by_location(lat, long)
      Post
        .where.not(lat: nil)
        .where.not(long: nil)
        .order("SQRT(SQR(posts.lat - #{lat}) + SQR(posts.long - #{long})) desc")
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

  def to_api_json
    {
      id: id,
      picture_url: picture.url(:original),
      description: description,
      tag_ids: tags.map {|t| {id: t.id, name: t.name} },
      lat: lat,
      long: long,
      post_type: post_type,
      user: {
        name: user_name,
        email: user_email,
        avatar_url: user_avatar_url
      },
      likes: {
        count: post_likes.count,
        people: post_likes.first(3).map do |p|
          {
            id: p.user_id,
            nmae: p.user.name
          }
        end
      }
    }
  end
end
