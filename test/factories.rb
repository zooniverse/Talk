require 'factory_girl'

Factory.sequence :name do |n|
  "0000000".split('').zip("#{n}".reverse.split('')).reverse.collect{ |a| a[1] || a[0] }.join
end

Factory.define :asset do |a|
  a.zooniverse_id       { "AMZ#{Factory.next(:name)}" }
  a.location            "http://imageserver.org/assets/1"
  a.thumbnail_location  "http://imageserver.org/assets/thumbs/1"
end

Factory.define :group do |g|
  g.zooniverse_id       { "SPH#{Factory.next(:name)}" }
end

Factory.define :user do |u|
  u.zooniverse_user_id  { "#{Factory.next(:name)}" }
  u.name                { "User #{Factory.next(:name)}"}
  u.email               { "#{Factory.next(:name)}@localhost" }
end

Factory.define :asset_set do |c|
  c.name                { "#{ Factory.next(:name) }" }
  c.description         { "This is an asset set" }
  c.user                { |user| user.association(:user) }
end

Factory.define :keyword_set do |c|
  c.name                { "#{ Factory.next(:name) }" }
  c.description         { "This is a keyword set" }
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
  m.pretty_title        { "#{ Factory.next(:name) }" }
  m.title               { "#{ Factory.next(:name) }" }
end

Factory.define :conversation, :class => Discussion do |c|
  c.subject             "Monkey is an OIII emission"
end

