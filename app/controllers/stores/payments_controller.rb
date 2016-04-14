module Stores
  class PaymentsController < StoreController
    before_action :find_payment_value, only: [:new, :create]

    def index
      @page = params[:page] || 1
      @per_page = 10

      @payments = current_user.user_payments.page(@page).per(@per_page).order(created_at: :desc)

      last_15_days = (0..14).map{|x| x.day.ago }.reverse
      last_15_days_payments = last_15_days.map do |day|
        UserPayment.where(created_at: day.beginning_of_day..day.end_of_day).sum(:amount)
      end

      last_15_days_transactions = last_15_days.map do |day|
        UserTransaction.where.not(amount: nil).where('amount < 0').where(created_at: day.beginning_of_day..day.end_of_day).sum(:amount).abs
      end
      @graph_data = {
        labels: last_15_days.map{|d| d.strftime("%d %b")},
        datasets: [
          {
            label: 'Income',
            fillColor: "rgba(220,220,220,0.2)",
            strokeColor: "rgba(220,220,220,1)",
            pointColor: "rgba(220,220,220,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: last_15_days_payments
          },
          {
            label: 'Used',
            fillColor: "rgba(151,187,205,0.2)",
            strokeColor: "rgba(151,187,205,1)",
            pointColor: "rgba(151,187,205,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(151,187,205,1)",
            data: last_15_days_transactions
          }
        ]
      }
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
