require 'mailgun'
require 'set'
require 'yaml'

puts '~~~ Starting mailgun team update ~~~'

config = YAML.load_file('team.yml')
new_routes = config['mailgun']['routes']
members = config['members']

# get all routes
client = Mailgun::Client.new ENV['MAILGUN_API_KEY']
res = client.get("routes").to_h
current_routes = res['items']

# Delete all current routes to maintain state
current_routes.each do |item|
  puts 'Deleting mailgun routes'
  if ENV['LOCATION'] == "PRODUCTION"
    client.delete "routes/#{item['id']}"
  end
end

puts 'Routes flushed, rebuilding'

# Build hash
forward_emails = {}
members.each do |member|
  email = member['mailgun']['email']
  routes = member['mailgun']['routes']

  routes.each do |route|
    forward_emails[route] = '' if forward_emails[route].nil?
    forward_emails[route] = "#{forward_emails[route]}#{email},"
  end
end

# actually add the routes
new_routes.each do |new_route|
  puts "Creating new route with description: #{new_route['description']}"
  if ENV['LOCATION'] == "PRODUCTION"
    res = client.post "routes",  {:priority => new_route['priority'],
                                  :description => new_route['description'],
                                  :expression => "match_recipient(\"#{new_route['name']}\")",
                                  :action => "forward(\"#{forward_emails[new_route['name']]}\")"}
  end
  puts "Added email route #{new_route['name']}, mailgun response: #{res.to_h['message']}"
end

puts "~~~ Finished updating mailgun routes ~~~"