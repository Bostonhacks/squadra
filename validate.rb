require 'yaml'
config = YAML.load_file('team.yml')

puts "~~~ Validating team.yml ~~~"

# Shitty validation layer. TODO: make better
members = config['members']

members.each do |member|
  # TODO: make sure github user actually exists
  raise 'Missing github entry for user' if member['github'].nil?
  raise 'Missing github username for user' if member['github']['username'].nil?
  raise 'Invalid github role for user' unless %w[admin member].include?(member['github']['role'])

	# TODO: make sure email is formatted correctly
  # TODO: make sure email routes are written correctly
  raise 'Missing sendgrid entry for user' if member['sendgrid'].nil?
  raise 'Missing sendgrid email for user' if member['sendgrid']['email'].nil?
  raise 'No sendgrid routes specified for user' unless member['sendgrid']['routes'].any?
end

puts "~~~ Finished validating team.yml ~~~"
