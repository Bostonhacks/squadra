require 'yaml'
config = YAML.load_file('team.yml')

puts "~~~ Validating team.yml ~~~"

members = config['members']
routes = config['routes']
routes.map! { |route| route['name'] }

members.each do |member|
	raise "User is missing name" if member['name'].nil?
  raise "Missing status for user: #{member['name']}" if member['status'].nil?
	
  # TODO: make sure github user actually exists
  raise "Missing github entry for user: #{member['name']}" if member['github'].nil?
  raise "Missing github username for user: #{member['name']}" if member['github']['username'].nil?
  raise "Invalid github role for user: #{member['name']}" unless %w[admin member].include?(member['github']['role'])

  raise "Missing sendgrid entry for user: #{member['name']}" if member['sendgrid'].nil?
  raise "Missing sendgrid email for user: #{member['name']}" if member['sendgrid']['email'].nil?
	raise "Invalid sendgrid email for user: #{member['name']}" unless URI::MailTo::EMAIL_REGEXP.match?(member['sendgrid']['email'])
  raise "No sendgrid routes specified for user: #{member['name']}" unless member['sendgrid']['routes'].any?
	raise "Invalid sendgrid routes for user: #{member['name']}" unless (member['sendgrid']['routes'] - routes).empty?
	raise "Alum has invalid sendgrid routes: #{member['name']}" unless member['status'] != 'alum' || 
																																		(member['sendgrid']['routes'].length() == 1 && 
																																		 member['sendgrid']['routes'][0] == 'alumni@bostonhacks.io')
end

puts "~~~ Finished validating team.yml ~~~"
