$.fn.parseAnnotations = function(editable) {
  editable = editable ? true : false
  var text = $(this).val() || $(this).html();
  var matched = text.match(/\"[^\"]*\"\:\(\d+x\d+@\d+,\d+\)/gm);
  var annotations = new Array();
  
  if(matched) {
    $.each(matched, function(index, part) {
      var parts = part.match(/\"([^\"]*)\"\:\((\d+x\d+)@(\d+,\d+)\)/m);
      if(parts.length == 4) {
        var annotation = {
          id: annotations.length,
          text: parts[1],
          width: parseInt(parts[2].split('x')[0]),
          height: parseInt(parts[2].split('x')[1]),
          top: parseInt(parts[3].split(',')[0]),
          left: parseInt(parts[3].split(',')[1])
        };
      
        if(editable) {
          annotation['editable'] = true;
        }
      
        annotations.push(annotation);
      }
    });
  }
  
  return annotations;
};

$.fn.addAnnotations = function(elem) {
  $.fn.annotateImage.clear(this);
  var annotations = $(elem).parseAnnotations(true);
  this.notes = annotations;
  $.fn.annotateImage.load(this);
};

$.fn.highlightAnnotations = function() {
  this.each(function() {
    var body = $(this).children('.comment-body');
    var elem = body.children('p');
    var annotations = elem.parseAnnotations();
    if(annotations.length > 0) {
      var src = $('#asset-image').attr('src');
      body.after('<div class="annotated-comment" style="display: none;"><img class="annotated-comment-image" src="' + src + '" /></div>');
      elem.html(elem.html().replace(/\"([^\"]*)\"\:\(\d+x\d+@\d+,\d+\)/gm, '<a class="annotated-comment-link" href="#">$1</a>'));
      
      $('.annotated-comment-link').click(function() {
        var dialog = body.next('.annotated-comment');
        if(dialog.hasClass('initialized')) {
          dialog.dialog('open');
        }
        else {
          dialog.dialog({
            title: "Annotations by " + body.children('.name').text(),
            width: 635,
            height: 465,
            show: 'clip',
            resizable: false
          });
          
          var comment_annotation = dialog.children('.annotated-comment-image').annotateImage({
            editable: false,
            useAjax: false,
          });
          
          comment_annotation.notes = annotations;
          $.fn.annotateImage.load(comment_annotation);
          dialog.addClass('initialized');
        }
        
        $('.image-annotate-view').show();
        
        return false;
      });
    }
  });
};

$.fn.keywordHighlight = function(options) {
  var defaults = {
  
  };
  var opts = $.extend({}, $.fn.keywordHighlight.defaults, options);
  
  return this.each(function(){
      $this = $(this);
      var text = $this.html();
      var result = text.replace(/#([-\w\d]{3,40})/g, "<a class='keyword' href='/search?search=keywords%3A$1'>#$1</a>");
      result = result.replace(/(AMZ\w{7})/g, "<a class='keyword' href='/objects/$1'>$1</a>");
      result = result.replace(/(CMZ\w{7})/g, "<a class='keyword' href='/collections/$1'>$1</a>");
      result = result.replace(/(DMZ\w{7})/g, "<a class='keyword' href='/discussions/$1'>$1</a>");
      $this.html(result);
      return $this;
  });
};
