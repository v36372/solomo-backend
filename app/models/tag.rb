class Tag < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:name]

  has_many :post_tags
  has_many :posts, through: :post_tags

  class << self
    def top_this_week
      order('(select count(post_tags.id) from post_tags where post_tags.tag_id = tags.id) desc').order(created_at: :desc)
    end
  end

  def to_api_json
    {
      id: id,
      name: name
    }
  end
end
