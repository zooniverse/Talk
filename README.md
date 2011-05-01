# Talk
Zooniverse Talk is a forum replacement

## Object Oriented Discussion
- You can talk about a [Focus](Focus.html)
  - [Asset](Asset.html)s, [Group](Group.html)s, and Collections ([AssetSet](AssetSet.html)s and [KeywordSet](KeywordSet.html)s) are Focii
  - They have one twitter-style Conversation and many in-depth [Discussion](Discussion.html)s.  Both are really just [Discussion](Discussion.html)s
  - Focii and their [Discussion](Discussion.html)s have [ZooniverseId](ZooniverseId.html)s that are unique in the Zooniverse
  - Focii can have [Tag](Tag.html)s, which are created by [User](User.html)s in [Comment](Comment.html)s
- [Discussion](Discussion.html)s are really just containers for [Comment](Comment.html)s
  - Then again they also store lots of other metadata
  - They also get the [Tag](Tag.html)s from their [Comment](Comment.html)s
- If a [User](User.html) doesn't want to talk about a [Focus](Focus.html), they can go to the [Board](Board.html)s
  - A [Board](Board.html) is some category of conversation.  We supply 'help', 'science', and 'chat'
  - Moderators and admins can create [SubBoard](SubBoard.html)s to help [User](User.html)s organize discussion
- An [Asset](Asset.html) is whatever the Zoo is classifying, it's really the primary object of discussion
- A Collection is a [User](User.html) created set of [Asset](Asset.html)s
  - An [AssetSet](AssetSet.html) is a manually curated set of [Asset](Asset.html)s
  - A [KeywordSet](KeywordSet.html) is a dynamic set of [Asset](Asset.html)s based on the [Tag](Tag.html)s specified by the [User](User.html)
- A [Group](Group.html) is a system managed group of [Asset](Asset.html)s
  - Imagine a book with many pages.  The [Asset](Asset.html) is the page, the [Group](Group.html) is the Book
  - Or how about a CD with many songs.  The [Asset](Asset.html) is the song, the [Group](Group.html) is the CD
- A [User](User.html) is... well... a [User](User.html)
  - They can send [Message](Message.html)s to each other too

## Getting started
- Setup [RVM](https://rvm.beginrescueend.com/), probably with some [packages](https://rvm.beginrescueend.com/packages/) depending on your environment
- [Install Ruby 1.9.2](https://rvm.beginrescueend.com/rubies/installing/)
- [Install RubyGems](http://rubygems.org/pages/download)
- [Install MongoDB](http://www.mongodb.org/display/DOCS/Quickstart)
- Make sure [Bundler](http://rubygems.org/gems/bundler) is installed
- Run `bundle` from the app to install the gem dependencies

## Configuring
- Setup config files in Talk/config
  - Examples are show in Talk/config/examples
- Configure mailer settings in Talk/environments/*
- Configure your Capistrano deploy script at Talk/config/deploy.rb
