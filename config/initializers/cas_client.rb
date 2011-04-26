require 'casclient'
require 'casclient/frameworks/rails/filter'

config = YAML.load_file("#{ Rails.root }/config/cas_client.yml")
CASClient::Frameworks::Rails::Filter.configure(config.to_options)
