converter = new Markdown.Converter()

module.exports=
  runEditor: (className, name) ->
    setTimeout(->
      editor = new Markdown.Editor(converter, className)
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
    html = converter.makeHtml content
    $(html).emoticonize().html()
