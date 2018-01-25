{socialDefaults} = require './config'

inline = (string) -> string.replace '\n', '', 'g'

module.exports =
  facebook: (options) ->
    inline """
      https://www.facebook.com/sharer/sharer.php
      ?s=100
      &p[url]=#{encodeURIComponent options.href || socialDefaults.href}
      &p[title]=#{encodeURIComponent options.title || socialDefaults.title}
      &p[summary]=#{encodeURIComponent options.summary || socialDefaults.summary}
      &p[images][0]=#{encodeURIComponent options.image || socialDefaults.image}
    """

  twitter: (options) ->
    inline """
      http://twitter.com/home
      ?status=#{encodeURIComponent options.summary || socialDefaults.summary}
      %20#{encodeURIComponent options.href || socialDefaults.href}
      %20#{encodeURIComponent options.twitterTags || socialDefaults.twitterTags}
    """

  pinterest: (options) ->
    inline """
      http://pinterest.com/pin/create/button/
      ?url=#{encodeURIComponent options.href || socialDefaults.href}
      &media=#{encodeURIComponent options.image || socialDefaults.image}
      &description=#{encodeURIComponent options.summary || socialDefaults.summary}
    """
