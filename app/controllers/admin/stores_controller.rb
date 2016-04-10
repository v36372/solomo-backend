module Admin
  class StoresController < AdminController
    before_action :find_user, except: [:new, :create, :processing, :index]

    def index
      @page = params[:page] || 1
      @per_page = 20

      @users = User.verified_stores.page(@page).per(@per_page).order(created_at: :desc)
    end

    def processing
      @page = params[:page] || 1
      @per_page = 20

      @users = User.processing_stores.page(@page).per(@per_page).order(created_at: :desc)
    end

    def map

    end

    def reject

    end

    def process_reject
      @user.store.feedback_content = params[:feedback_content]
      @user.store.save
      if @user.store.created?
        @user.store.send_feedback_email
        flash[:notice] = "Reject successfully"
      else
        @user.store.reset!
        if @user.store.errors
          flash[:error] = @user.store.errors.full_messages.first
        else
          flash[:notice] = "Reject successfully"
        end
      end
      redirect_to :back
    end

    def next_status
      if @user.store.processing_phone?
        @user.store.received_verify_code = @user.store.verify_code
        @user.store.process_phone!
      elsif @user.store.processing_email?
        @user.store.received_verify_code = @user.store.verify_code
        @user.store.process_email!
      elsif @user.store.processing_staff?
        @user.store.process_staff!
      end
      if @user.store.errors.present?
        flash[:error] = @user.stores.errors.full_messages.first
      else
        flash[:notice] = "Process store registration successfully"
      end
      redirect_to :back
    end

    private

    def find_user
      @user = User.find_by_id params[:id]
    end
  end
end