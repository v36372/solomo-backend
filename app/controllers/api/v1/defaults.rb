module API
  module V1
    module Defaults
      ADDRESS_LAST_UPDATED_AT = Time.find_zone('Hanoi').local(2015,12,20,0,0,0).to_i
      extend ActiveSupport::Concern

      included do
        formatter       :json, Grape::Formatter::ActiveModelSerializers
        error_formatter :json, API::V1::Config::ErrorFormatter
        rescue_from     :all, backtrace: true
        use             API::V1::Config::ApiErrorHandler

        helpers ActiveSupport::NumberHelper

        helpers do
          def authenticate_user!
            unless params[:user_token] && @user = User.find_by_authentication_token(params[:user_token])
              return error!("Access token is invalid!", 401)
            end
          end

          def set_page
            @page = (params[:page] || 1).to_i
            @per_page = 10
          end

          def current_user
            @user
          end

          def current_cart
            if @user
              @user.carts.order(id: :desc).first || @user.carts.build
            end
          end

          def user_signed_in?
            @user ||= User.find_by_authentication_token(params[:access_token])
          end

          def permitted_params
            @permitted_params ||= declared(params, include_missing: false)
          end

          def permit_params(*fields)
            return params.to_h if fields.blank?
            real_params = {}
            fields.to_a.each do |field|
              real_params[field] = params[field] if params[field].present?
            end
            return real_params
          end

          def address_last_updated_at
            ADDRESS_LAST_UPDATED_AT
          end

          def vietnamese_currency(input, include_unit=false)
            unit = include_unit ? "đ" : ""
            number_to_currency input, unit: unit, delimiter: ",", precision: 0, format: "%n %u"
          end

          def array_serializer(active_record_relations, options = {})
            return [] unless active_record_relations.present?
            serializer_klass = "::#{active_record_relations.first.class.name}Serializer".constantize
            options.merge!({each_serializer: serializer_klass})

            ActiveModel::ArraySerializer.new(active_record_relations, options)
          end

          def find_object_for(klass, options = {})
            default = {
              id: params[:id]
            }.merge!(options)

            @object =
            if klass.new.respond_to? :slug
              klass.friendly.find(default[:id])
            else
              klass.find_by_id(default[:id])
            end
          end
        end

        rescue_from Grape::Exceptions::ValidationErrors do |e|
          Rollbar.error(e)
          errors = { error: JSON.parse(e.to_json) }
          rack_response errors, 404
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          Rollbar.error(e)
          error!("Not found record!", 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          Rollbar.error(e)
          errors = { error: e.message }
          error!(errors, 422)
        end

        rescue_from FbGraph::InvalidToken do |e|
          Rollbar.error(e)
          error!("Invalid access token", 422)
        end

        rescue_from :all do |e|
          Rollbar.error(e)
          errors = { errors: e.message }
          error!(errors, 500)
        end
      end
    end
  end
end
