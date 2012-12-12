mentions = require 'lib/mentions'
converter = new Markdown.Converter()

module.exports=
  runEditor: (className, name) ->
    setTimeout(->
      editor = new Markdown.Editor(converter, className)
      editor.hooks.chain 'onPreviewRefresh', ->
        text = $("#wmd-preview#{ className }").html()
        $("#wmd-preview#{ className }").html(mentions(text)) if text
      
      editor.hooks.chain "onPreviewRefresh", ->
        $("#wmd-preview#{ className } *").emoticonize animate: false
      
      editor.run()
      $(".togglePreview").click (ev) ->
        ev.preventDefault()
        el = $(ev.target)
        preview = el.closest('.field').find '.wmd-preview'
        preview.toggle()
        if preview.is(':visible') then el.html("Hide Preview") else el.html("Show Preview")
    , 20)
  
  convert: (content = '') ->
    html = $("<div>#{converter.makeHtml content}</div>")
    html.emoticonize().html()
