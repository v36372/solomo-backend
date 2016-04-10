namespace :feeds do
  desc 'Create most ppular tags'
  task create_feeds: :environment do
    UserFeed.destroy_all
    Post.order(updated_at: :desc).find_each do |post|
      UserFeedGenerator.push_post(post)
    end
    UserFeed.update_all(seen: true)
  end
end