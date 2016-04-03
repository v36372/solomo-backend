class PostLike < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  after_create :send_notification

  def send_notification
    Notification.create(
      notifier: user,
      receiver: (post.user if post.user.present?),
      notification_type: Notification.notification_types[:like],
      notifiable: self
    )
  end
end
