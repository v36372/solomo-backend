module API
  module V1
    class Account < Grape::API
      include API::V1::Defaults

      resource :account, desc: "Account" do
        before do
          authenticate_user!
        end

        desc "Get user information (name, email, avatar url, ...)"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :fields, type: String, desc: 'Fields to return'
        end
        get do
          acceptable_fields = [:name, :email, :avatar_url, :birthday]
          if params[:fields].present?
            fields = params[:fields].to_s.split(',').map(&:to_sym)
          else
            fields = acceptable_fields
          end
          field_accepted = fields.all? { |field| acceptable_fields.include?(field) }
          error!('Invalid fields') and return unless field_accepted

          results = {}
          fields.each do |field|
            case field
            when :birthday
              results[:birthday] = @user.birthday.strftime('%d/%m/%Y') if @user.birthday.present?
            when :avatar_url
              results[:avatar_url] = @user.avatar.url(:thumb) if @user.avatar.present?
            else
              results[field] = @user.public_send(field)
            end
          end
          return results
        end

        desc "Update user information (name, birthday, location)"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :first_name, type: String, desc: 'Updating user first name'
          optional :last_name, type: String, desc: 'Updating user last name'
          optional :birthday, type: String, desc: 'Updating birthday'
          optional :location_province, type: Integer, desc: 'Updating province id'
          optional :location_district, type: Integer, desc: 'Updating province id'
        end
        patch :personal_information do
          @user.assign_attributes(permit_params(:first_name, :last_name, :birthday))
          if @user.save
            return {
              name: @user.name,
              birthday: @user.birthday.try(:strftime, '%d/%m/%Y')
            }
          else
            errors = {error: @user.errors}
            return errors
          end
        end

        desc "Update user avatar"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :image, type: :file, desc: 'Updating user avatar'
        end
        patch :avatar do
          @user.avatar_image = params[:image]
          if @user.save
            return {
              avatar_url:  @user.avatar.url(:thumb)
            }
          else
            errors = {error: @user.errors}
            return errors
          end
        end

        desc "Delete user avatar"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
        end
        delete :avatar do
          @user.avatar.destroy
          if @user.save
            return {}
          else
            errors = {error: @user.errors}
            return errors
          end
        end
      end
    end
  end
end
