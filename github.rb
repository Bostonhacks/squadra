require 'octokit'
require 'yaml'

puts '~~~ Starting github team update ~~~'

# load the team.yml file and get the members from it
config = YAML.load_file('team.yml')
members = config['members']
# members.select! { |member| member['status'] == 'active' }

# get the new permissions for the members from the file
new_permissions = {}
members.each do |member|
  new_permissions[member['github']['username'].downcase] = member['github']['role'].downcase
end

# Rubygem with the github API client
client = Octokit::Client.new(
    :login => ENV['GITHUB_USERNAME'],
    :password => ENV['GITHUB_ACCESS_TOKEN'])

# current members of the github organization
current_members = client.organization_members('bostonhacks')

# iterate through all members of the organization to find:
# 1) who needs a role change, or
# 2) who needs to be deleted from the org
current_members.each do |member|
  member_login = member[:login].downcase
  # get their permission in the squadra repository (admin, read, write, or none)
  # then translate that into either admin (admin) or member (read or write)
  permission = client.permission_level('bostonhacks/squadra', member_login)[:permission]
  if permission == 'read' || permission == 'write'
    permission = 'member'
  elsif permission == 'admin'
  else
    abort('API error, current organization member is neither member nor admin')
  end

  # print their current membership
  # puts "#{member_login} is a #{permission}"

  # see if they need to be removed from the repo
  if new_permissions[member_login].nil?
    puts "*** #{member_login} should be removed from the organization."
    if (ENV['LOCATION'] == "PRODUCTION")
      puts "Calling Github API, removing user: #{member_login}"
      client.remove_organization_member('bostonhacks', member_login)
    end
  # see if they need their permission changed
  elsif new_permissions[member_login] != permission
    puts "*** #{member_login} is #{permission} but should be #{new_permissions[member_login]}."
    if (ENV['LOCATION'] == "PRODUCTION")
      puts "Calling Github API, changing perms for user: #{member_login}"
      client.update_organization_membership(
        'bostonhacks',
        :user => member_login,
        :role => new_permissions[member_login]
      )
    end
    new_permissions.delete(member_login)
  # no need to change their permissions
  else
    puts "#{member_login} is a #{permission}, no change necessary."
    new_permissions.delete(member_login)
  end
end

# go through remaining new_permissions to find who needs to be added to the org
new_permissions.each do |login, permission|
  puts "*** #{login} should be added to the organization as a #{permission}."
  if (ENV['LOCATION'] == "PRODUCTION")
    puts "Calling Github API, updating user: #{login}"
    client.update_organization_membership(
      'bostonhacks',
      :user => login,
      :role => permission
    )
  end
end

puts "~~~ Finished updating github membership ~~~"
