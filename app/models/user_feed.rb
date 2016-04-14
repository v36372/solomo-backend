class UserFeed < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  after_create :send_notification
  after_update :generate_post_views

  class << self
    def of_user(user)
      user.user_feeds
          .order(seen: :asc)
          .order(related_score: :desc)
          .order(updated_at: :desc)
          .order(id: :desc)
    end
  end

  def send_notification
    return if post.user.blank? || !post.user.followed_by?(self.user)
    Notification.create(
      notifier: post.user,
      receiver: user,
      notification_type: Notification.notification_types[:feed],
      notifiable: self
    )
  end

  def generate_post_views
    return unless seen_changed? && seen == true
    PostView.create(
      user_id: user_id,
      post_id: post_id,
      related_score: self.related_score
    )
  end
end