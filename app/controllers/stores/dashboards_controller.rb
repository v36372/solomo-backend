module Stores
  class DashboardsController < StoreController
    before_action :authenticate_store!

    def show
      if params[:end_at].present? && params[:start_at].present?
        arr_end_at = params[:end_at].split('/').map &:to_i
        arr_start_at = params[:start_at].split('/').map &:to_i
        @end_at = Time.new(arr_end_at[2], arr_end_at[1], arr_end_at[0])
        @start_at = Time.new(arr_start_at[2], arr_start_at[1], arr_start_at[0])
        @delta_at = (@start_at - ((@end_at - @start_at) / 24 / 60 / 60).days).beginning_of_day
      else
        @end_at = Time.current.end_of_day
        @delta_at = (@end_at - 14.days).beginning_of_day
        @start_at = (@end_at - 7.days).beginning_of_day
      end

      @total_followers = current_user.followers.count
      @total_page_views = PostView.where(post_id: current_user.posts.pluck(:id)).count

      ################################################
      # Filtered statistics
      ################################################
      @filtered_post_views = PostView.where(post_id: current_user.posts.pluck(:id))
                               .where(created_at: @start_at..@end_at)
                               .count
      @filtered_post_likes = PostLike.where(post_id: current_user.posts.pluck(:id))
                               .where(created_at: @start_at..@end_at)
                               .count
      @filtered_post_comments = Comment.where(post_id: current_user.posts.pluck(:id))
                                  .where(created_at: @start_at..@end_at)
                                  .count
      @filtered_followers = UserFollowing.where(following_id: current_user.id)
                              .where(created_at:@start_at..@end_at)
                              .count

      @before_post_views = PostView.where(post_id: current_user.posts.pluck(:id))
                               .where(created_at: @delta_at..@start_at)
                               .count
      @before_post_likes = PostLike.where(post_id: current_user.posts.pluck(:id))
                               .where(created_at: @delta_at..@start_at)
                               .count
      @before_post_comments = Comment.where(post_id: current_user.posts.pluck(:id))
                                  .where(created_at: @delta_at..@start_at)
                                  .count
      @before_followers = UserFollowing.where(following_id: current_user.id)
                              .where(created_at:@delta_at..@start_at)
                              .count
      @delta_post_likes = (@before_post_likes.blank? || @before_post_likes == 0) ? nil : ((@filtered_post_likes - @before_post_likes).to_f / @before_post_likes * 100).round
      @delta_post_views = (@before_post_views.blank? || @before_post_views == 0) ? nil : ((@filtered_post_views - @before_post_views).to_f / @before_post_views * 100).round
      @delta_post_comments = (@before_post_comments.blank? || @before_post_comments == 0) ? nil : ((@filtered_post_comments - @before_post_comments).to_f / @before_post_comments * 100).round
      @delta_followers = (@before_followers.blank? || @before_followers == 0) ? nil : ((@filtered_followers - @before_followers).to_f / @before_followers * 100).round

      ################################################
      # Filtered graphs
      ################################################
      days = []
      runner = @end_at
      while runner >= @start_at.beginning_of_day
        days << runner.beginning_of_day
        runner -= 1.days
      end
      days.reverse!

      post_views_days = days.map do |day|
        PostView.where(post_id: current_user.posts.pluck(:id))
          .where(created_at: day.beginning_of_day..day.end_of_day)
          .count
      end

      post_likes_days = days.map do |day|
        PostLike.where(post_id: current_user.posts.pluck(:id))
          .where(created_at: day.beginning_of_day..day.end_of_day)
          .count
      end

      post_comments_days = days.map do |day|
        Comment.where(post_id: current_user.posts.pluck(:id))
          .where(created_at: day.beginning_of_day..day.end_of_day)
          .count
      end

      followers_days = days.map do |day|
        UserFollowing.where(following_id: current_user.id)
          .where(created_at: day.beginning_of_day..day.end_of_day)
          .count
      end

      options = {
        fillColor: "rgba(220,220,220,0.2)",
        strokeColor: "rgba(220,220,220,1)",
        pointColor: "rgba(220,220,220,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(220,220,220,1)"
      }
      @post_views_data = {
        labels: days.map{|d| d.strftime("%d %b")},
        datasets: [
          options.merge(
            data: post_views_days
          )
        ]
      }

      @post_likes_data = {
        labels: days.map{|d| d.strftime("%d %b")},
        datasets: [
          options.merge(
            data: post_likes_days
          )
        ]
      }

      @post_comments_data = {
        labels: days.map{|d| d.strftime("%d %b")},
        datasets: [
          options.merge(
            data: post_comments_days
          )
        ]
      }

      @followers_data = {
        labels: days.map{|d| d.strftime("%d %b")},
        datasets: [
          options.merge(
            data: followers_days
          )
        ]
      }
      ################################################
      # Filtered graphs
      ################################################
      @visiting_user_ids = UserProfileView.where(target_user_id: current_user.id).pluck(:user_id)
      @visting_users = User.where(id: @visiting_user_ids.uniq)

      @groups = [1..16, 17..25, 26..30, 31..100]
      @group_data = []
      @groups.each_with_index do |group, index|
        @group_data[index] = User.where.not(birthday: nil).where('(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR from birthday)) BETWEEN ? AND ?', group.to_a.first, group.to_a.last).count
      end
      @groups = @groups.map do |group|
        "#{group.to_a.first} - #{group.to_a.last}"
      end

      raw_views = UserProfileView.where(target_user_id: current_user.id).group(:user_id).count
      avg_views = raw_views.map do |user_id, views|
        start_at = UserProfileView.where(user_id: user_id).order(created_at: :asc).first.created_at
        end_at= UserProfileView.where(user_id: user_id).order(created_at: :asc).last.created_at
        days = (end_at - start_at) / 24 / 60 / 60
        if days == 0
          1
        else
          (views.to_f / days * 7).round
        end
      end
      @view_groups = [0..5, 6..10, 11..15, 16..10000]
      @view_group_data = []
      @view_groups.each_with_index do |group, index|
        @view_group_data[index] = avg_views.count do |view| group.include?(view) end
      end
      @view_groups = @view_groups.map do |group|
        "#{group.to_a.first} - #{group.to_a.last}"
      end
      @user_tags = UserTag.where(user_id: @visiting_user_ids)
                    .group(:tag_id).count
                    .sort_by {|tag_id, count| count}
                    .reverse.first(5).map do |tag_id, count| [Tag.find_by_id(tag_id), count] end

      @boosting_posts = current_user.posts.select do |post|
        post.boosting_status == :active || post.boosting_status == :halted
      end
    end
  end
end