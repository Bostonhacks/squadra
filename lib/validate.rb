require 'yaml'
config = YAML.load_file('team.yml')

# Shitty validation layer. TODO: make better
members = config['members']

members.each do |member|
  raise 'Missing github entry for user' if member['github'].nil?
  raise 'Missing github username for user' if member['github']['username'].nil?
  raise 'Invalid github role for user' unless %w[admin member].include?(member['github']['role'])

  members.each do |member|
    raise 'Missing mailgun entry for user' if member['mailgun'].nil?
    raise 'Missing mailgun email for user' if member['mailgun']['email'].nil?
    raise 'No mailgun routes specified for user' unless member['mailgun']['routes'].any?
  end
end
