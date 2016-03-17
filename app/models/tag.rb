class Tag < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:name]

  has_many :post_tags
  has_many :posts, through: :post_tags

  def to_api_json
    {
      id: id,
      name: name
    }
  end
end
