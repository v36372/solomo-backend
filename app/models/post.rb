class Post < ActiveRecord::Base
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
end
