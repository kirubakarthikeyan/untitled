class ApplicationMailer < ActionMailer::Base
  default from: (Rails.env.production? ? "support@slate.club" : "local@slate.club")
  layout "mailer"
  after_action :notify_slack

  def notify_slack
    code_block = Slack.get_code_block("I've sent an owl to #{@_message.to} regarding '#{@_message.subject}'")
    Dobby.slack(code_block, channel: "owl-logs")
  end
end
