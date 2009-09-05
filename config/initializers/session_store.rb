# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_store_session',
  :secret      => '25d8edd397b158d3fcdaf73c6bb3dcad09b53b8908efe98ebcc394d278b8a1039b32fd30fe6e95c2ee3254199164acc47893a63dd7f87e1969626f48851b0b21'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
