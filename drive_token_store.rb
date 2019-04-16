# This overrides the general token store because CircleCI doesn't allow local files.

# Instead, this forces the user to place the token into the .env.

# We use Base64 encoding because there are some strange characters in the token which
# dotenv doesn't know how to handle.

class DriveTokenStore
	class << self
		attr_accessor :default
	end

	def load _id
		# return it if it's in the env
		if ENV["DRIVE_TOKEN_STORE_" + _id]
			return ENV["DRIVE_TOKEN_STORE_" + _id]
		end
	end

	def store _id, _token
		# token either isn't in env
		if !ENV["DRIVE_TOKEN_STORE_" + _id]
			puts "Please save the following line to your .env file:"
			puts "DRIVE_TOKEN_STORE_" + _id + "=" + _token
			raise "Exiting for now, re-run once you change your .env."
		# there's an updated token it would like to store
		# as of right now, just print it
		elsif ENV["DRIVE_TOKEN_STORE_" + _id] != _token
			puts "You may soon need to update your .env token:"
			puts "DRIVE_TOKEN_STORE_" + _id + "=" + _token
		end
	end

	def delete _id
		raise (
			"Please clear your .env of the key " + 
			("DRIVE_TOKEN_STORE_" + _id) +
			" and restart the program.")
	end
end
