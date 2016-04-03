module API
  module V1
    class Search < Grape::API
      include API::V1::Defaults
      resource :search, desc: "Search" do
        before do
          authenticate_user!
          set_page
        end

        desc "Search all factors"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :q, type: String, desc: 'Keyword to serach'
        end
        get :all do
          raw_results = PgSearch.multisearch(params[:q])
          results = Kaminari.paginate_array(raw_results).page(@page).per(@per_page)
          json_results = results.map do |result|
            case result.searchable_type
            when 'Post', 'User', 'Tag'
              data = result.searchable.to_api_json
            else
              data = {}
            end
            {
              result_type: result.searchable_type,
              result_data: data
            }
          end
          return {
            results: json_results
          }
        end

        desc "Search all posts"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :q, type: String, desc: 'Keyword to serach'
        end
        get :posts do
          raw_results = PgSearch.multisearch(params[:q]).where(searchable_type: 'Post')
          results = Kaminari.paginate_array(raw_results).page(@page).per(@per_page)
          json_results = results.map do |result|
            {
              result_type: result.searchable_type,
              result_data: result.searchable.to_api_json
            }
          end
          return {
            results: json_results
          }
        end

        desc "Search all users"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :q, type: String, desc: 'Keyword to serach'
        end
        get :users do
          results = PgSearch.multisearch(params[:q])
                            .where(searchable_type: 'User')
          json_results = results.map do |result|
            {
              result_type: result.searchable_type,
              result_data: result.searchable.to_api_json
            }
          end
          return {
            results: json_results
          }
        end

        desc "Search all tags"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :q, type: String, desc: 'Keyword to serach'
        end
        get :tags do
          results = PgSearch.multisearch(params[:q])
                            .where(searchable_type: 'Tag')
          json_results = results.map do |result|
            {
              result_type: result.searchable_type,
              result_data: result.searchable.to_api_json
            }
          end
          return {
            results: json_results
          }
        end

        desc 'Search by location'
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :lat, type: Float, desc: 'Keyword to serach'
          requires :long, type: Float, desc: 'Keyword to serach'
          optional :radius, type: Float, desc: 'Radius of google map'
        end
        get :posts_by_location do
          results = Post.search_by_location(params[:lat], params[:long], params[:radius]).limit(20)
          json_results = results.map do |result|
            {
              result_type: 'Post',
              result_data: result.to_api_json
            }
          end
          return {
            results: json_results
          }
        end
      end
    end
  end
end
