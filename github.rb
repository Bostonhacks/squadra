require 'octokit'
require 'set'
require 'yaml'

puts 'Starting github team update'

config = YAML.load_file('team.yml')
members = Set.new

config['members'].each do |person|
  members.add(person['github'])
end

client = Octokit::Client.new(
    :login => ENV['GITHUB_USERNAME'],
    :password => ENV['GITHUB_ACCESS_TOKEN'])

members.each do |person|
  res = client.update_organization_membership(
    'bostonhacks',
    :user => person['username'],
    :role => person['role']
  )

  if res.state == 'active'
    puts "User #{person['username']} is already part of bostonhacks github" 
  elsif res.state == 'pending'
    puts "User #{person['username']} has been invited to bostonhacks github"
  else
    raise "Error occurred on squadra github run for user #{person['username']}"
  end
end
