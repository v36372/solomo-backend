class UserFeedGenerator

  class << self
    def related_score(post, user, updating_method = nil)
      score = 0
      # Factor 1: user following
      if post.user.present?
        score += 3 if user.is_following?(post.user)
        score += 1 if user.followed_by?(post.user)
      end
      # Factor 2: post updating
      if updating_method
        case updating_method
          when :create
            score += 5
          when :update
            score += 4
          when :interaction
            score += 2
          else
            score += 1
        end
      end
      # Factor 3: boost post

      score
    end

    def related_users(post)
      related_user_ids = []
      # Factor 1: Users which is following and follower of the post's author
      if post.user.present?
        related_user_ids += post.user.followings.pluck(:id)
        related_user_ids += post.user.followers.pluck(:id)
      end
      # Factor 2: Users that used to interact with the tags the post contains
      # Factor 3: Users that match the post boost meta

      User.where(id: related_user_ids)
    end

    def push_post(post, updating_method = nil)
      self.related_users(post).each do |user|
        next if user.id == post.user_id
        user_feed = UserFeed.find_or_initialize_by(
          user_id: user.id,
          post_id: post.id
        )
        new_related_score = UserFeedGenerator::related_score(post, user, updating_method)
        if user_feed.seen
          user_feed.related_score = new_related_score
        else
          user_feed.related_score = [user_feed.related_score || 0, new_related_score].max
        end
        user_feed.seen = false
        user_feed.updated_at = Time.current
        user_feed.save!
      end
    end
  end

end