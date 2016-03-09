class Picture < ActiveRecord::Base
  has_attached_file :file, styles: {
      fb_image: "1200x630#",
      fb_image_thumb: "600x315#",
      cover: "600x"
  }
  validates_attachment_content_type :file, content_type: /\Aimage\/.*\Z/

  def file_url=(url)
    return unless url.present?

    if /^data:image/.match(url)
      self.file = url
    else
      self.file = URI.parse(url)
    end
  end
end