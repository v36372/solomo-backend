module API
  module V1
    class Posts < Grape::API
      include API::V1::Defaults

      resource :picture, desc: "Pictures" do
        before do
          authenticate_user!
        end

        desc "Upload new image"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
        end
        post do
          @picture = Picture.new
          file = params[:file]
          attachment = {
            :filename => file[:filename],
            :type => file[:type],
            :headers => file[:head],
            :tempfile => file[:tempfile]
          }
          @picture.file = ActionDispatch::Http::UploadedFile.new(attachment)
          if @picture.save
            return {
                id: @picture.id,
                picture_url: @picture.file.url(:original)
            }
          else
            errors = {error: @post.errors}
            return errors
          end
        end
      end
    end
  end
end
