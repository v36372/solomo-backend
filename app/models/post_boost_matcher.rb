class PostBoostMatcher
  class << self
    def calculate_score(boost)
      post_tags = boost.post.tag_ids
      selected_tags = boost.post_boost_tags.map(&:tag_id)
      matched_tags = (post_tags & selected_tags).length
      mismtached_tags = (selected_tags - post_tags).length
      matched_tags - mismtached_tags
    end
  end
end