class StoreMailer < ApplicationMailer
  def verify_email(store_id)
    @store = Store.find_by_id store_id
    return if @store.blank?
    mail(to: @store.user.email, subject: "Solomo stores registration")
  end

  def send_feedback_email(store_id)
    @store = Store.find_by_id store_id
    return if @store.blank?
    mail(to: @store.user.email, subject: "Solomo stores registration feedback")
  end

  def send_congratulation_email(store_id)
    @store = Store.find_by_id store_id
    return if @store.blank?
    mail(to: @store.user.email, subject: "Welcome to Solomo Store Network")
  end
end