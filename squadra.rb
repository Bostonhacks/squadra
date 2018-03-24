require 'dotenv/load'

puts 'Validating team.yml...'

require_relative 'validate'

puts 'Initiating team update run'

require_relative 'github'
require_relative 'mailgun'

puts 'Team update run occured, exiting'
