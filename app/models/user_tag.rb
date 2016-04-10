class UserTag < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag

  class << self
    def generate_user_tags(post, user, ratio = 1)
      post.post_tags.each do |post_tag|
        user_tag = UserTag.find_or_initialize_by(
          user: user,
          tag_id: post_tag.tag_id
        )
        user_tag.score ||= 0
        if post_tag.is_auto?
          user_tag.score += 1
        else
          user_tag.score += 5
        end
        user_tag.save
      end
    end
  end
end