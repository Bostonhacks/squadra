require 'yaml'
config = YAML.load_file('team.yml')

puts "~~~ Validating team.yml ~~~"

members = config['members']
routes = config['routes']
routes.map! { |route| route.name }

members.each do |member|
  # TODO: make sure github user actually exists
  raise 'Missing github entry for user' if member['github'].nil?
  raise 'Missing github username for user' if member['github']['username'].nil?
  raise 'Invalid github role for user' unless %w[admin member].include?(member['github']['role'])

  raise 'Missing sendgrid entry for user' if member['sendgrid'].nil?
  raise 'Missing sendgrid email for user' if member['sendgrid']['email'].nil?
	raise 'Invalid sendgrid email for user' unless URI::MailTo::EMAIL_REGEXP.match?(member['sendgrid']['email'])
  raise 'No sendgrid routes specified for user' unless member['sendgrid']['routes'].any?
	raise 'Invalid sendgrid routes for user' unless (member['sendgrid']['routes'] - routes).empty?
end

puts "~~~ Finished validating team.yml ~~~"
