# Note: Use DriveV2 since DriveV3 does not return email address
require 'google/apis/drive_v2'
require 'googleauth'
require 'googleauth/stores/file_token_store'

# team_emails = set of emails to be granted access
team_info = YAML.load_file("team.yml")
team_emails = Set.new

team_info["members"].each do |entry|
  email = entry["mailgun"]["email"]
  team_emails.add(email)
end

# prepare for authentication
user_id = ENV['YOUR_ID']

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
scope = 'https://www.googleapis.com/auth/drive'
client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRETS'])
token_store = Google::Auth::Stores::FileTokenStore.new(
  :file => './tokens.yaml')
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

permission_list.items.each do |permission|
  this_email = permission.email_address
  # if email is not in team's emails set, remove permission
  unless team_emails.include?(this_email)
    drive_service.delete_permission(ENV["DRIVE_ID"], permission.id, supports_team_drives: true)
  else
    team_emails.delete(this_email)
  end
end

# if there's any email left in the set, create new permission
unless team_emails.empty?
  team_emails.each do |email|
    permission_detail = {
      email_address: email,
      role: "fileOrganizer",
      type: "user",
      value: email
    }
    new_permission = Google::Apis::DriveV2::Permission.new(permission_detail)
    drive_service.insert_permission(ENV["DRIVE_ID"], new_permission, supports_team_drives: true, send_notification_emails: true) do |result, err|
      if err
        puts "Error: #{err}"
      else
        puts "Successfully adding #{result.name} with email #{result.email_address}"
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

