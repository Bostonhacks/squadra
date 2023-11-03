require 'dotenv/load'

puts 'Squadra is beginning...'

require_relative 'validate'
require_relative 'github'
require_relative 'mailgun'
require_relative 'team_drive'

puts 'Squadra is finished.'
