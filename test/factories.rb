require 'factory_girl'

Factory.sequence :name do |n|
  "#{n}" 
end

Factory.define :asset do |a|
  a.zooniverse_id       { "AHZ#{Factory.next(:name)}" }
  a.location            "http://imageserver.org/assets/1"
  a.thumbnail_location  "http://imageserver.org/assets/thumbs/1"
end