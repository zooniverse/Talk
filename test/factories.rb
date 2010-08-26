require 'factory_girl'

Factory.sequence :name do |n|
  "#{n}" 
end

Factory.define :comment do |c|
  c.body                "Monkey AMZ1monkey Monkey #cute #awesome Monkey!"
  c.tags                ["cute", "awesome"]
  c.author              { |author| author.association(:user) }
end

Factory.define :discussion do |d|
  d.subject             "Monkey is an OIII emission"
  d.started_by_id       { |user| user.association(:user).id }
end

Factory.define :asset do |a|
  a.zooniverse_id       { "AHZ#{Factory.next(:name)}" }
  a.location            "http://imageserver.org/assets/1"
  a.thumbnail_location  "http://imageserver.org/assets/thumbs/1"
  a.tags                [ "monkey" ]
end

Factory.define :user do |u|
  u.zooniverse_user_id  { "#{Factory.next(:name)}" }
  u.name                { "User #{Factory.next(:name)}"}
end

Factory.define :collection do |c|
  c.zooniverse_id       { "AHZ#{Factory.next(:name)}" }
  c.name                { "#{ Factory.next(:name) }" }
  c.description         { "This is collection" }
  c.user                { |user| user.association(:user) }
end

Factory.define :live_collection do |c|
  c.zooniverse_id       { "AHZ#{Factory.next(:name)}" }
  c.name                { "#{ Factory.next(:name) }" }
  c.description         { "This is a live collection" }
  c.tags                [ "tag2", "tag4" ]
  c.user                { |user| user.association(:user) }
end

Factory.define :message do |m|
  m.title               { "#{ Factory.next(:name) }" }
  m.body                { "Body of the message" }
  m.sender              { |sender| sender.association(:user) }
  m.recipient           { |recipient| recipient.association(:user) }
end

Factory.define :board do |m|
  m.title               { "#{ Factory.next(:name) }" }
  m.description         { "Board description" }
end

Factory.define :conversation, :class => Discussion do |c|
  c.subject             "Monkey is an OIII emission"
  c.slug                "monkey-is-an-oiii-emission"
end

