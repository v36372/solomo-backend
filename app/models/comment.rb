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

  def comment_tree_depth
    if self.parent_comment.present? && self.parent_comment.parent_id.present?
      self.errors[:base] << 'Comment tree is too deep. Only allow one level of nested comments'
      return false
    end
  end
end
