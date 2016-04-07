module Admin
  class DashboardsController < AdminController
    def show
      @posts = Post.all
      @posts_with_location = Post.where.not(lat: nil)
      @posts_top_interaction = Post.all.sort_by { |p| p.interaction_count }.reverse
      @users = User.all
      @users_top_interaction = User.all.sort_by { |u| u.interaction_count }.reverse
      @likes = PostLike.all
      @comments = Comment.all
      @tags = Tag.top_this_week.first(10)
      last_15_days = (0..14).map{|x| x.day.ago }.reverse
      last_15_days_users = last_15_days.map do |day|
        User.where(created_at: day.beginning_of_day..day.end_of_day).count
      end
      @user_data = {
        labels: last_15_days.map{|d| d.strftime("%d %b")},
        datasets: [
          {
            fillColor: "rgba(220,220,220,0.2)",
            strokeColor: "rgba(220,220,220,1)",
            pointColor: "rgba(220,220,220,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: last_15_days_users
          }
        ]
      }

      last_15_days_posts = last_15_days.map do |day|
        Post.where(created_at: day.beginning_of_day..day.end_of_day).count
      end
      @post_data = {
        labels: last_15_days.map{|d| d.strftime("%d %b")},
        datasets: [
          {
            fillColor: "rgba(220,220,220,0.2)",
            strokeColor: "rgba(220,220,220,1)",
            pointColor: "rgba(220,220,220,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: last_15_days_posts
          }
        ]
      }
    end
  end
end