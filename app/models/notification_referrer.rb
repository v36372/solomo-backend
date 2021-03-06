class NotificationReferrer
  class << self
    def generate(notification)
      case notification.notification_type
      when 'like', 'comment'
        {
          refferer_type: 'Post',
          referrer_id: notification.notifiable.post_id,
          referrer_thumbnail: (notification.notifiable.post.picture.url(:fb_image_thumb) if notification.notifiable.post.picture.present?)
        }
      when 'follow'
        {
          refferer_type: 'User',
          referrer_id: notification.notifiable.user_id,
          referrer_thumbnail: (notification.notifiable.user.avatar.url(:fb_image_thumb) if notification.notifiable.user.avatar.present?)
        }
      when 'feed'
        {
          referrer_type: 'Post',
          referrer_id: notification.notifiable.post_id,
          referrer_thumbnail: (notification.notifiable.post.picture.url(:fb_image_thumb) if notification.notifiable.post.picture.present?)
        }
      else
        {}
      end
    end
  end
end
