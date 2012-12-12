prefix = require('lib/config').prefix

tagMatcher = ///
  (?=[^\w]|^)#([-\w\d]{3,40})
///g

objectMatcher = ///
  (?=[^\/]|^)(A#{ prefix }\w{7})
///g

groupMatcher = ///
  (?=[^\/]|^)(G#{ prefix }\w{7})
///g

collectionMatcher = ///
  (?=[^\/]|^)(C#{ prefix }[SL]\w{6})
///g

discussionMatcher = ///
  (?=[^\/]|^)(D#{ prefix }\w{7})
///g

userMatcher = ///
  (?=[^\w]|^)@([^\s$]+)
///g

module.exports = (text) ->
  text = text.replace tagMatcher, ' <a title="Tag $1" class="mention" href="#/hashtags/$1">#$1</a>'
  text = text.replace objectMatcher, ' <a title="Object $1" class="mention" href="#/subjects/$1">$1</a>'
  text = text.replace groupMatcher, ' <a title="Group $1" class="mention" href="#/groups/$1">$1</a>'
  text = text.replace collectionMatcher, ' <a title="Collection $1" class="mention" href="#/collections/$1">$1</a>'
  text = text.replace discussionMatcher, ' <a title="Discussion $1" class="mention" href="#/discussions/$1">$1</a>'
  text = text.replace userMatcher, (match, user, offset, string) ->
    """ <a title="User #{ user }" class="mention" href="#/users/#{ encodeURIComponent user }">@#{ user }</a>"""
