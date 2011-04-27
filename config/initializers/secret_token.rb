# Be sure to restart your server when you modify config/secret_token.yml

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Talk::Application.config.secret_token = YAML.load_file("#{ Rails.root }/config/secret_token.yml")['token']