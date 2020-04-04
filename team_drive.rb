# Note: Use DriveV2 since DriveV3 does not return email address
require 'google/apis/drive_v2'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require './drive_token_store.rb'

# team_emails = set of emails to be granted access
config = YAML.load_file('team.yml')
members = config['members']
# members.select! { |member| member['status'] == 'active' }

team_emails = Set.new
members.each do |member|
  email = member["sendgrid"]["email"]
  team_emails.add(email)
end

# prepare for authentication
user_id = ENV['USERNAME']

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
scope = 'https://www.googleapis.com/auth/drive'
client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRETS'])
# can't use FileTokenStore because CircleCI doesn't store files, implemented our own
# token_store = Google::Auth::Stores::FileTokenStore.new(
#   :file => './tokens.yaml')
token_store = DriveTokenStore.new()

authorizer = Google::Auth::UserAuthorizer.new(client_id, scope, token_store)

credentials = authorizer.get_credentials(user_id)

# prepare credentials if not already available
if credentials.nil?
  url = authorizer.get_authorization_url(base_url: OOB_URI )
  puts "Open #{url} in your browser and enter the resulting code:"
  code = gets
  credentials = authorizer.get_and_store_credentials_from_code(
    user_id: user_id, code: code, base_url: OOB_URI)
end

# get a new access token
credentials.fetch_access_token!

drive_service = Google::Apis::DriveV2::DriveService.new
drive_service.authorization = credentials

# list of permission for this team drive
permission_list = drive_service.list_permissions(ENV["DRIVE_ID"], supports_team_drives: true)

puts "Deleting emails no longer in team.yml:"
permission_list.items.each do |permission|
  this_email = permission.email_address
  # if email is not in team's emails set, remove permission
  unless team_emails.include?(this_email)
    puts "deleting #{this_email}"
    if ENV['LOCATION'] == 'PRODUCTION'
      puts "Making API call..."
      drive_service.delete_permission(ENV["DRIVE_ID"], permission.id, supports_team_drives: true)
    end
  else
    team_emails.delete(this_email)
  end
end

# if there's any email left in the set, create new permission
puts "Adding new emails"
unless team_emails.empty?
  team_emails.each do |email|
    permission_detail = {
      email_address: email,
      role: "fileOrganizer",
      type: "user",
      value: email
    }
    puts "Adding #{email}"
    if ENV['LOCATION'] == 'PRODUCTION'
      new_permission = Google::Apis::DriveV2::Permission.new(permission_detail)
      drive_service.insert_permission(ENV["DRIVE_ID"], new_permission, supports_team_drives: true, send_notification_emails: true) do |result, err|
        if err
          puts "Error: #{err}"
        else
          puts "Successfully made API call to add #{result.name} with email #{result.email_address}"
        end
      end
    end
  end
end

# checking and making sure everyone is added
puts "Final result:"
permission_list = drive_service.list_permissions(ENV["DRIVE_ID"], supports_team_drives: true)
permission_list.items.each do |permission|
  puts permission.email_address
end
