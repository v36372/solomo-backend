class Notification < ActiveRecord::Base
  enum notification_type: [:like, :comment, :follow, :feed]

  belongs_to :notifiable, polymorphic: true
  belongs_to :receiver, class_name: 'User'
  belongs_to :notifier, class_name: 'User'

  scope :unread, -> { where("`read` IS NULL or `read` = ?", false) }
  scope :unread_prioritized, -> { order(read: :asc) }

  validates :notifiable, presence: true
  validates :receiver, presence: true
  validates :notifier, presence: true

  after_create :render_hash
  after_create :send_to_pusher

  serialize :rendered_hash, Hash

  class << self
    def mark_read
      update_all(read: true)
    end
  end

  def pusher_hash(cache = true)
    if rendered_hash.present? && cache
      rendered_hash
    else
      {
        id: self.id,
        notification_type: self.notification_type,
        message: NotificationMessage.generate(self),
        read: read,
        notifier: {
          id: notifier.id,
          name: notifier.name,
          avatar: (notifier.avatar.url(:thumb) if notifier.avatar.present?)
        },
        notifiable: notifiable.try(:attributes),
        referrer: NotificationReferrer.generate(self),
        created_at: self.created_at
      }
    end
  end

  def render_hash
    self.update(rendered_hash: pusher_hash(false))
  end

  def send_to_pusher
    Pusher.trigger("notification_user_#{receiver_id}", "new_notification", rendered_hash)
  end
end
