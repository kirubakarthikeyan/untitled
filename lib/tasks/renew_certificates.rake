namespace :ssl_certificates_renewer do
  task :renew => :environment do
    SslCertificate.renew_wild_card_certificates()
    SslCertificate.renew_http_certificates()
  end
end
