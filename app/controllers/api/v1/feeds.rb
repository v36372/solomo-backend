module API
  module V1
    class Feeds < Grape::API
      include API::V1::Defaults

      resources :feeds, desc: "Posts" do
        before do
          authenticate_user!
        end

        desc "Get all news feeds"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :page, type: Integer, desc: 'Page want to fetch'
        end
        get do
          per_page = 20
          page = (params[:page] || 1).to_i
          @feeds = UserFeed.of_user(current_user)
                           .page(page)
                           .per(per_page)
          posts = @feeds.map do |feed|
            feed.post.to_api_json.merge(
              feed_id: feed.id,
              feed_seen: feed.seen,
              feed_related_score: feed.related_score
            )
          end
          {
            posts: posts,
            pagination: {
              current_page: page,
              total_pages: @feeds.total_pages
            }
          }
        end

        desc "Mark news feeds read"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :feed_ids, type: String, desc: 'Serialized string of feeds that want to mark read. For example: "1,2,3,4,5". No spaces allowed'
        end
        post :read do
          feed_ids = params[:feed_ids].to_s.split(',')
          UserFeed.where(id: feed_ids).update_all(seen: true)
          {
            result: 'Marked read successfully'
          }
        end
      end
    end
  end
end
