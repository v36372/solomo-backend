# Preview all emails at http://localhost:3000/rails/mailers/store_mailer
class StoreMailerPreview < ActionMailer::Preview
  def verify_email
    StoreMailer.verify_email(Store.last.id)
  end
  def send_feedback_mail
    StoreMailer.send_feedback_email(Store.last.id)
  end
  def send_congratulation_email
    StoreMailer.send_congratulation_email(Store.last.id)
  end
end
