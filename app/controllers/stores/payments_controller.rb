module Stores
  class PaymentsController < StoreController
    before_action :find_payment_value, only: [:new, :create]

    def index

    end

    def new

    end

    def create
      customer = Stripe::Customer.create(
        :email => current_user.email,
        :source  => params[:stripe_id]
      )

      charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount      => @payment_value,
        :description => 'store_charge',
        currency: 'vnd'
      )

      payment = UserPayment.create(
         user: current_user,
         detail: "store_charge_stripe",
         amount: @payment_value,
         external_id: charge.id
      )

      if payment.persisted?
        flash[:notice] = "Charge sucessfully"
        redirect_to stores_payments_path
      else
        raise payment.errors.fullmessages.first
      end
    rescue => e
      flash[:error] = e.message
      redirect_to :back
    end

    private

    def find_payment_value
      @payment_value = (params[:payment_value] || 100000).to_i
      @payment_select = params[:payment_select] || '100000'
    end
  end
end
