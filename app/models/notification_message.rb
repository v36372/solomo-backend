class NotificationMessage
  class << self
    def generate(notification)
      case notification.notification_type
      when 'like'
        <<-EOF
            <span class='notifier'>
              #{notification.notifier.name}
            </span>
            vừa thích post
            <span class='target'>
              "#{notification.notifiable.post.description.split(' ').first(7).join(' ')}..."
            </span>
            của bạn
        EOF
      when 'comment'
        <<-EOF
            <span class='notifier'>
              #{notification.notifier.name}
            </span>
            vừa bình luận trong post
            <span class='target'>
              "#{notification.notifiable.post.description.split(' ').first(7).join(' ')}..."
            </span>
            của bạn
        EOF
      when 'follow'
        <<-EOF
            <span class='notifier'>
              #{notification.notifier.name}
            </span>
            vừa theo dõi bạn
        EOF
      end
    end
  end
end
