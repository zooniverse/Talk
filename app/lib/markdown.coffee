mentions = require 'lib/mentions'
Markdown = require 'lib/markdown/converter'
require 'lib/markdown/sanitizer'
converter = new Markdown.Converter()

module.exports =
  runEditor: (className) ->
    setTimeout(->
      editor = new Markdown.Editor(converter, className)
      editor.hooks.chain 'onPreviewRefresh', ->
        text = $("#wmd-preview#{ className }").html()
        preview = $("#wmd-preview#{ className }")
        if preview.is(':visible') and text
          preview.html(mentions(text))
          preview.find('*').emoticonize animate: false
      
      editor.run()
      
      $(".markdown#{ className } .toggle-preview").click (ev) ->
        ev.preventDefault()
        el = $(ev.target)
        preview = el.closest('.field').find '.wmd-preview'
        preview.toggle()
        editor.refreshPreview()
        if preview.is(':visible') then el.html("Hide Preview") else el.html("Show Preview")
    , 20)
  
  convert: (content = '') ->
    html = $("<div>#{ converter.makeHtml content }</div>")
    html.children().emoticonize()
    html.html()
