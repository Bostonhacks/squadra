require 'dotenv/load'

puts 'Squadra is beginning...'

require_relative 'validate'
require_relative 'github'
require_relative 'mailgun'

puts 'Squadra is finished.'
