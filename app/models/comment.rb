class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  belongs_to :parent_comment, class_name: 'Comment', foreign_key: 'parent_id'
  has_many :child_comments, class_name: 'Comment', foreign_key: 'parent_id', dependent: :destroy

  validates :user, presence: true
  validates :post, presence: true
  validates :content, presence: true
  validate :comment_tree_depth

  scope :root, -> { where(parent_id: nil) }
  scope :in_order, -> { order(created_at: :desc) }

  after_create :send_notification

  def comment_tree_depth
    if self.parent_comment.present? && self.parent_comment.parent_id.present?
      self.errors[:base] << 'Comment tree is too deep. Only allow one level of nested comments'
      return false
    end
  end

  def to_api_json
    child_comments_json = []
    if child_comments.present?
      child_comments_json = child_comments.map &:to_api_json
    end
    {
      id: self.id,
      user: self.user.to_api_json,
      created_at: self.created_at,
      content: self.content,
      child_comments: child_comments_json
    }
  end

  def send_notification
    Notification.create(
      notifier: user,
      receiver: (post.user if post.user.present?),
      notification_type: Notification.notification_types[:comment],
      notifiable: self
    )
  end
end
