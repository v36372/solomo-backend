class UserFeed < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  after_create :send_notification

  class << self
    def of_user(user)
      user.user_feeds
          .order(seen: :asc)
          .order(related_score: :desc)
          .order(updated_at: :desc)
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
end