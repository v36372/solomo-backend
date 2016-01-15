class Tag
  has_any :post_tags
  has_many :posts, through: :post_tags
end
