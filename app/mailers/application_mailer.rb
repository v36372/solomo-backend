class ApplicationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  default from: "Solomo Team <noreply@#{solomo-api.herokuapp.com}>"
  layout 'mailer'
end
