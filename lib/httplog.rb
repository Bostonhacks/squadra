# Do not log in prod
require 'httplog' unless ENV['PROD']

HttpLog.configure do |config|
  # Tweak which parts of the HTTP cycle to log...
  config.log_connect   = false
  config.log_request   = true
  config.log_headers   = false
  config.log_data      = false
  config.log_status    = false
  config.log_response  = true
  config.log_benchmark = false

  # Prettify the output - see below
  config.color = :cyan
end
