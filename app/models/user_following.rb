class UserFollowing < ActiveRecord::Base
  belongs_to :user
  belongs_to :following, class_name: 'User', foreign_key: 'following_id'

  after_create :send_notification

  private
  def send_notification
    Notification.create(
      notifier: user,
      receiver: following,
      notification_type: Notification.notification_types[:follow],
      notifiable: self
    )
  end
end
