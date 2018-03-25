require 'octokit'
require 'yaml'

puts 'Starting github team update'

config = YAML.load_file('team.yml')
members = config['members']

new_permissions = {}
members.each do |member|
  new_permissions[member['github']['username'].downcase] = member['github']['role'].downcase
end

client = Octokit::Client.new(
    :login => ENV['GITHUB_USERNAME'],
    :password => ENV['GITHUB_ACCESS_TOKEN'])

current_members = client.organization_members('bostonhacks')
current_permissions = {}
# The permissions on this repo are the current permissions
current_members.each do |member|
  permission = client.permission_level('bostonhacks/squadra', member[:login])[:permission]
  permission = 'member' if permission == 'read'
  current_permissions[member[:login].downcase] = permission.downcase
end

current_permissions.each do |username, permission|
  # If nothing changed, delete from hash
  if new_permissions[username] == permission
    puts "Nothing changed for user #{username}. Before: #{current_permissions[username]}, After: #{new_permissions[username]}"
  # If permission is different, delete and update
  elsif !new_permissions[username].nil?
    puts "Update permissions for user #{username} from #{current_permissions[username]} to #{new_permissions[username]}"
    client.remove_organization_member('bostonhacks', username)
    client.update_organization_membership(
      'bostonhacks',
      :user => username,
      :role => new_permissions[username]
    )
  # Otherwise just delete
  else
    puts "Remove user #{username} from bostonhacks"
    client.remove_organization_member('bostonhacks', username)
  end
  current_permissions.delete(username)
  new_permissions.delete(username)
end

# Cleanup: add remaining users
new_permissions.each do |username, permission|
  puts "Adding new member to bostonhacks: #{username}"
  # client.update_organization_membership(
  #   'bostonhacks',
  #   :user => username,
  #   :role => new_permissions[username]
  # )
end
