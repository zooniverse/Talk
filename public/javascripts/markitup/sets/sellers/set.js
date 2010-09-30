// -------------------------------------------------------------------
// markItUp!
// -------------------------------------------------------------------
// Copyright (C) 2008 Jay Salvat
// http://markitup.jaysalvat.com/
// -------------------------------------------------------------------
// MarkDown tags example
// http://en.wikipedia.org/wiki/Markdown
// http://daringfireball.net/projects/markdown/
// -------------------------------------------------------------------
// Feel free to add more tags
// -------------------------------------------------------------------
mySettings = {
  previewParserPath: '/comments/markitup_parser',
  onShiftEnter: {keepDefault:false, openWith:'\n\n'},
  markupSet: [    
    {name:'Bold', key:'B', openWith:'**', closeWith:'**'},
    {name:'Italic', key:'I', openWith:'_', closeWith:'_'},
    {separator:'---------------' },
    {name:'Bulleted List', openWith:'- ' },
    {name:'Quotes', openWith:'> '},
    {separator:'---------------' },
    {name:'Picture', key:'P', replaceWith:'![[![Alternative text]!]]([![Url:!:http://]!] "[![Title]!]")'},
    {name:'Link', key:'L', openWith:'[', closeWith:']([![Url:!:http://]!] "[![Title]!]")', placeHolder:'Your text to link here...' },
    {name:'Annotate', key:'A', className:"annotate-button", call:"new_annotation"},
    {separator:'---------------'},
    {name:'Preview', call:'markitup_preview', className:"preview"}
  ]
}

// mIu nameSpace to avoid conflict.
miu = {
  markdownTitle: function(markItUp, char) {
    heading = '';
    n = $.trim(markItUp.selection||markItUp.placeHolder).length;
    for(i = 0; i < n; i++) {
      heading += char;
    }
    return '\n'+heading;
  }
}
