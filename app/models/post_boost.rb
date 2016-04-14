class PostBoost < ActiveRecord::Base
  belongs_to :post
  has_many :post_boost_tags
  before_create :save_calculated_price
  after_create :force_boost_post
  after_save :boost_post

  scope :active, -> { where(active: true) }

  def calculate_price
    [150 - PostBoostMatcher.calculate_score(self) * 10, 20].max + (self.age_max.to_i - self.age_min.to_i).abs * 10
  end

  def estimate_users
    UserFeedGenerator.related_users(self.post).count
  end

  def boost_post
    return if active_changed? || !active
    self.post.boost_post
  end

  def force_boost_post
    return unless active
    self.post.boost_post
  end

  private

  def save_calculated_price
    self.price = calculate_price
  end
end