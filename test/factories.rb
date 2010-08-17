require 'factory_girl'

Factory.sequence :name do |n|
  "#{n}" 
end

Factory.define :asset do |a|
  a.zooniverse_id       { "AHZ#{Factory.next(:name)}" }
  a.location            "http://imageserver.org/assets/1"
  a.thumbnail_location  "http://imageserver.org/assets/thumbs/1"
end

Factory.define :user do |u|
  u.zooniverse_user_id  { "#{Factory.next(:name)}" }
  u.name                { "User #{Factory.next(:name)}"}
end