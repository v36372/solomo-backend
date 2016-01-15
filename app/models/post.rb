class Post < ActiveRecord::Base
  has_many :post_tags
  has_many :tags, through: :post_tags
  belongs_to :user

  has_attached_file :picture, styles: {
    fb_image: "1200x630#",
    fb_image_thumb: "600x315#",
    cover: "600x"
  }
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
end
