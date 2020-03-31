require 'yaml'
config = YAML.load_file('team.yml')

puts "~~~ Validating team.yml ~~~"

members = config['members']
routes = config['routes']
routes.map! { |route| route['name'] }

members.each do |member|
  # TODO: make sure github user actually exists
  raise "Missing github entry for user: #{member['name']}" if member['github'].nil?
  raise "Missing github username for user: #{member['name']}" if member['github']['username'].nil?
  raise "Invalid github role for user: #{member['name']}" unless %w[admin member].include?(member['github']['role'])

  raise "Missing sendgrid entry for user: #{member['name']}" if member['sendgrid'].nil?
  raise "Missing sendgrid email for user: #{member['name']}" if member['sendgrid']['email'].nil?
	raise "Invalid sendgrid email for user: #{member['name']}" unless URI::MailTo::EMAIL_REGEXP.match?(member['sendgrid']['email'])
  raise "No sendgrid routes specified for user: #{member['name']}" unless member['sendgrid']['routes'].any?
	raise "Invalid sendgrid routes for user: #{member['name']}" unless (member['sendgrid']['routes'] - routes).empty?
end

puts "~~~ Finished validating team.yml ~~~"
