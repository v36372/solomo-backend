module API
  module V1
    class Notifications < Grape::API
      include API::V1::Defaults

      resources :notifications, desc: "Notifications" do
        before do
          authenticate_user!
        end
        desc "Get all notifications of a user"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          optional :read, type: Integer, desc: 'If read = 0, only load unread notifications. If read = 1, only load read notifications. If blank, load both'
          optional :page, type: Integer, desc: 'Page of notifications want to load'
        end

        get do
          @notifications = Notification.where(receiver_id: current_user.id)
                                       .unread_prioritized
                                       .order(created_at: :desc)
          if params[:read].present?
            if params[:read].to_s == '1'
              @notifications = @notifications.where(read: true)
            else
              @notifications = @notifications.where(read: [false, nil])
            end
          end

          page = params[:page] || 1
          per_page = 20

          @notifications = @notifications.page(page).per(per_page)

          return {
            notifications: @notifications.map(&:pusher_hash),
            pagination: {
              current_page: page,
              total_pages: @notifications.total_pages
            }
          }
        end

        desc "Mark attached notifications read"
        params do
          requires :user_token, type: String, desc: 'Generated user token'
          requires :notification_ids, type: String, desc: 'Ids of notifications. Something like: "1,2,3,4,5"'
        end
        post :read do
          notification_ids = params[:notification_ids].split(',').map do |id|
            id.strip.to_i
          end
          @notifications = Notification.where(receiver_id: current_user.id)
                                       .where(id: notification_ids)
          @notifications.update_all(read: true)
          return {}
        end
      end
    end
  end
end
