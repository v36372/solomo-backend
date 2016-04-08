class StoreMailer < ApplicationMailer
  def verify_email(store_id)
    @store = Store.find_by_id store_id
    return if @store.blank?
    mail(to: @store.user.email, subject: "Solomo stores registration")
  end
end