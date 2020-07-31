require 'pathname'
require './rack_app'
require './mail_sender'

mail_client = Bookwatch::MailSender.new(ENV['SENDGRID_USERNAME'],
                                         ENV['SENDGRID_API_KEY'],
                                         {to: ENV['FEEDBACK_TO'], from: ENV['FEEDBACK_FROM']})

run Bookwatch::RackApp.new(Pathname('redirects.rb'), mail_client).app
