module Stores
  class RegistrationsController < StoreController
    before_action :authenticate_store!, except: [:new, :create]

    def show
    end

    def new
      current_user.build_store
    end

    def create
      current_user.build_store
      current_user.assign_attributes(user_params)
      current_user.save

      if current_user.store.present?
        if current_user.store.process_information!
          redirect_to email_stores_registrations_path
        else
          redirect_to edit_stores_registrations_path
        end
      else
        render :new
      end
    end

    def edit
      current_user.validate
      current_user.store.validate
    end

    def update
      current_user.assign_attributes(user_params)
      current_user.save

      if current_user.store.process_information!
        redirect_to email_stores_registrations_path
      else
        redirect_to edit_stores_registrations_path
      end
    end

    def email

    end

    def process_email
      current_user.store.assign_attributes(store_params)
      if current_user.store.process_email!
        flash[:notice] = 'Verify email successfully'
        redirect_to phone_stores_registrations_path
      else
        flash[:error] = 'Fail to verify email'
        redirect_to :back
      end
    end

    def resend_email
      current_user.store.generate_verify_code
      current_user.store.send_verify_email
      redirect_to :back
    end

    def phone

    end

    def process_phone
      current_user.store.assign_attributes(store_params)
      if current_user.store.process_phone!
        flash[:notice] = 'Verify phone successfully'
        redirect_to staff_stores_registrations_path
      else
        flash[:error] = 'Fail to verify phone'
        redirect_to :back
      end
    rescue
      flash[:error] = 'Fail to verify phone. Perhaps you enter wrong phone number. Please try again'
      redirect_to :back
    end

    def resend_phone
      current_user.store.generate_verify_code
      current_user.store.send_verify_sms
      redirect_to :back
    end

    def staff
    end

    def reset
      current_user.store.reset!
      redirect_to edit_stores_registrations_path
    end

    def finish

    end

    private

    def user_params
      params.require(:user).permit!
    end

    def store_params
      params.require(:store).permit!
    end
  end
end