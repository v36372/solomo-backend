class PostLike < ActiveRecord::Base
  belongs_to :user
  belongs_to :post, touch: true
  after_create :send_notification, :push_to_user_tags

  def send_notification
    Notification.create(
      notifier: user,
      receiver: (post.user if post.user.present?),
      notification_type: Notification.notification_types[:like],
      notifiable: self
    )
  end

  def push_to_user_tags
    return if self.user.blank?
    UserTag.generate_user_tags(self.post, self.user, 1)
  end
end
