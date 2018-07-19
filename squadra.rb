require 'dotenv/load'

puts 'Validating team.yml...'

require_relative 'lib/validate'

puts 'Initiating team update run'

require_relative 'lib/github'
require_relative 'lib/mailgun'

puts 'Team update run occured, exiting'
