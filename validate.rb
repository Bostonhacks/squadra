require 'yaml'
config = YAML.load_file('team.yml')

puts "~~~ Validating team.yml ~~~"

members = config['members']
routes = config['mailgun']['routes']
routes.map! { |route| route['name'] }

members.each do |member|
	raise "User is missing name" if member['name'].nil?
  raise "Missing status for user: #{member['name']}" if member['status'].nil?
	
  # TODO: make sure github user actually exists
  raise "Missing github entry for user: #{member['name']}" if member['github'].nil?
  raise "Missing github username for user: #{member['name']}" if member['github']['username'].nil?
  raise "Invalid github role for user: #{member['name']}" unless %w[admin member].include?(member['github']['role'])

  raise "Missing mailgun entry for user: #{member['name']}" if member['mailgun'].nil?
  raise "Missing mailgun email for user: #{member['name']}" if member['mailgun']['email'].nil?
	raise "Invalid mailgun email for user: #{member['name']}" unless URI::MailTo::EMAIL_REGEXP.match?(member['mailgun']['email'])
  raise "No mailgun routes specified for user: #{member['name']}" unless member['mailgun']['routes'].any?
	raise "Invalid mailgun routes for user: #{member['name']}" unless (member['mailgun']['routes'] - routes).empty?
	raise "Alum has invalid mailgun routes: #{member['name']}" unless member['status'] != 'alum' || 
																																		(member['mailgun']['routes'].length() == 1 && 
																																		 member['mailgun']['routes'][0] == 'alumni@bostonhacks.io')
end

puts "~~~ Finished validating team.yml ~~~"
