$.fn.parseAnnotations = function(editable) {
  editable = editable ? true : false
  var text = $(this).val() || $(this).html();
  var annotations = new Array();
  
  if(!text) {
    return annotations;
  }
  
  var matched = text.match(/\"[^\"]*\"\:\(\d+x\d+@\d+,\d+\)/gm);
  
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

$.fn.stripAnnotations = function() {
  this.each(function() {
    var body = $(this).children('.body');
    body.html(body.html().replace(/\"([^\"]*)\"\:\(\d+x\d+@\d+,\d+\)/gm, '$1'));
  });
};

$.fn.highlightAnnotations = function() {
  this.each(function() {
    var body = $(this).children('.comment .body');
    var comment_id = $(this).attr('id');
    var annotations = body.parseAnnotations();
    
    if(annotations.length > 0) {
      var src = $('#asset-image').attr('src');
      body.after('<div id="' + comment_id + '-annotations" class="annotated-comment" style="display: none;"><img class="annotated-comment-image" src="' + src + '" /></div>');
      body.html(body.html().replace(/\"([^\"]*)\"\:\(\d+x\d+@\d+,\d+\)/gm, '<a title="Annotation" class="annotated-comment-link" href="#">$1</a>'));
      
      $('#' + comment_id + ' .annotated-comment-link').unbind();
      $('#' + comment_id + ' .annotated-comment-link').bind('click', function() {
        var dialog = $('#' + comment_id + '-annotations');
        if(dialog.hasClass('initialized')) {
          try {
            dialog.dialog('open');
          }
          catch(error) {
            dialog.removeClass('initialized');
            $('#' + comment_id + '-annotations .image-annotate-canvas').remove();
          }
        }
        
        if(!dialog.hasClass('initialized')) {
          dialog.dialog({
            title: "Annotations by " + body.children('.name').text(),
            width: Math.min(635, $(window).width()),
            height: Math.min(465, $(window).height()),
            show: 'fade',
            hide: 'fade',
            modal: false,
            draggable: true,
            resizable: true
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
    
    if($this.hasClass('highlight_annotations')) {
      $this.removeClass('highlight_annotations');
    }
    else {
      $this.closest('.highlight_annotations').removeClass('highlight_annotations');
    }
  });
};

$.fn.keywordHighlight = function() {
  return this.each(function(){
      $this = $(this);
      var text = $this.html();
      var result = text.replace(/[^\w]#([-\w\d]{3,40})/g, ' <a title="Keyword $1" class="keyword" href="/search?search=keywords%3A$1">#$1</a>');
      result = result.replace(/[^\/](AMZ\w{7})/g, ' <a title="Object $1" class="keyword" href="/objects/$1">$1</a>');
      result = result.replace(/[^\/](SMZ\w{7})/g, ' <a title="Group $1" class="keyword" href="/groups/$1">$1</a>');
      result = result.replace(/[^\/](CMZL\w{6})/g, ' <a title="Keyword Set $1" class="keyword" href="/collections/$1">$1</a>');
      result = result.replace(/[^\/](CMZS\w{6})/g, ' <a title="Collection $1" class="keyword" href="/collections/$1">$1</a>');
      result = result.replace(/[^\/](DMZ\w{7})/g, ' <a title="Discussion $1" class="keyword" href="/discussions/$1">$1</a>');
      $this.html(result);
      
      if($this.hasClass('highlight_keywords')) {
        $this.removeClass('highlight_keywords');
      }
      else {
        $this.closest('.highlight_keywords').removeClass('highlight_keywords');
      }
      
      return $this;
  });
};
