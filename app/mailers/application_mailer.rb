class ApplicationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  default from: "Solomo Team <noreply@#{Rails.application.secrets.mailgun_domain}>"
  layout 'mailer'
end
