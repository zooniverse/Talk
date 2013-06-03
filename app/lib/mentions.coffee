prefix = require('lib/config').prefix

tagMatcher = ///
  (\s|^)#([-\w\d]{3,40})
///g

objectMatcher = ///
  (\s|^)(A#{ prefix }\w{7})
///g

groupMatcher = ///
  (\s|^)(G#{ prefix }\w{7})
///g

collectionMatcher = ///
  (\s|^)(C#{ prefix }[SL]\w{6})
///g

discussionMatcher = ///
  (\s|^)(D#{ prefix }\w{7})
///g

userMatcher = ///
  (\s|^)@([^\s$]+)
///g

parseMentionsIn = (str, pattern, link, parent) ->
  html = $(str)[0]
  text = html.textContent or html.innerText
  
  if html.nodeType is 3 and parent and text.match(pattern)
    parent.replaceChild $("<span>#{ text.replace(pattern, link) }</span>")[0], html
  else if html.nodeType is 1 and html.nodeName isnt 'A'
    parseMentionsIn(child, pattern, link, html) for child in html.childNodes

module.exports = (text) ->
  text = $("<div>#{ text }</div>")
  parseMentionsIn text, tagMatcher, '$1<a title="Tag $2" class="mention" href="#/search?tags[$2]=true">#$2</a>'
  parseMentionsIn text, objectMatcher, '$1<a title="Object $2" class="mention" href="#/subjects/$2">$2</a>'
  # parseMentionsIn text, groupMatcher, '$1<a title="Group $2" class="mention" href="#/groups/$2">$2</a>'
  parseMentionsIn text, collectionMatcher, '$1<a title="Collection $2" class="mention" href="#/collections/$2">$2</a>'
  # parseMentionsIn text, discussionMatcher, '$1<a title="Discussion $2" class="mention" href="#/discussions/$2">$2</a>'
  parseMentionsIn text, userMatcher, (match, leading, user) ->
    """#{ leading }<a title="User #{ user }" class="mention" href="#/users/#{ encodeURIComponent user }">@#{ user }</a>"""
  $(text).html()
