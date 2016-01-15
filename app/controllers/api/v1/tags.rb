module API
  module V1
    class Tags < Grape::API
      include API::V1::Defaults

      resource :tags, desc: "Tags" do
        desc "Get list of tags"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
        end
        get do
          Tag.all.map do |tag|
            {
              id: tag.id,
              name: tag.name
            }
          end
        end
      end
    end
  end
end
