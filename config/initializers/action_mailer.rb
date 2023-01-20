ActionMailer::Base.smtp_settings = {
  domain:         'slate.club',
  address:        "smtp.sendgrid.net",
  port:            465,
  authentication: :plain,
  user_name:      "apikey",
  password:       Rails.application.credentials.dig(:send_grid, :api_key_secret),
  enable_starttls_auto: true,
  tls: true
}
