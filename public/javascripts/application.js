// 
// Oxford Communication Tool
// 
//
var OCT = window.OCT || {};

OCT.tabs = {
  trends      : '#trends-tabs',
  recents      : '#recents-tabs',
  
  init: function () {
    $('#home-tabs').tabs();
    $('#boards-tabs').tabs({ cache: true });
    $(OCT.tabs.trends).tabs({ cache: true });
    $(OCT.tabs.recents).tabs({ cache: true });
  }
};

OCT.collection_hover = {
  init: function() {
    $('.collection-thumbnail').mouseover(function() {
      $('.collection-large').attr("src", $(this).attr("src"));
      $('.collection-thumbnail').removeClass('current');
      $(this).addClass('current');
    });
  }
};

OCT.annotater = {
  annotations : {},
  
  init: function(form, annotation, width, height) {
    if($(annotation).length == 0) {
      $(form + ' .annotate-button').hide();
    }
    else {
      $(form + ' .annotate-button').bind('click', function() {
        OCT.annotater.create_annotation(form, annotation, width, height);
      });
    }
  },
  
  create_annotation: function(form, annotation, width, height) {
    var dialog = $(annotation);
    
    if(dialog.length == 1) {
      if(dialog.hasClass('initialized')) {
        OCT.annotater.annotations[annotation].addAnnotations(form + ' .comment_body');
        dialog.dialog('open');
      }
      else {
        dialog.dialog({
          title: "Add an annotation",
          width: width + 35,
          height: height + 105,
          show: 'fade',
          hide: 'fade',
          modal: false,
          draggable: true,
          resizable: true
        });
        
        OCT.annotater.annotations[annotation] = $(annotation + ' .comment-focus').annotateImage({
          editable: true,
          useAjax: false,
          markupField: form + ' .comment_body'
        });
        
       OCT.annotater.annotations[annotation].addAnnotations(form + ' .comment_body');
        
        dialog.bind('dialogclose', function() {
          $('.image-annotate-edit-close').click();
        });
        
        $('.image-annotate-view').show();
        
        dialog.addClass('initialized');
      }
      
      $('.image-annotate-view').show();
    }
  }
};

OCT.collection_lightbox = {
  init: function() {
    $('.collection-large').css('cursor', 'pointer')
    $("a[rel='lightbox']").colorbox({ title: function() {
        var url = $('.collection-thumbnail.current').parent().attr('href');
        return '<a href="' + url + '">' + $(this).attr('title') + '</a>';
      }
    });
    
    $('.collection-large').click(function() {
      $('.collection-thumbnail.current').parent().next().trigger('click');
    });
    
    $('.collection-thumbnail:first').addClass('current');
  }
};

OCT.paginated_collection = {
  init: function() {
    $(".collection-info").each(function() {
      OCT.paginated_collection.list($(this));
    });
  },
  
  list: function(container) {
    if($(".col", container).length > 0) {
      var new_width = $('.col', container).length * $('.col', container).width();
      $('.container', container).css("width", new_width + "px");
    }
    
    $('.nav', container).html('');
    if($(".col", container).length > 1) {
      // Create dots
      var page = 0;
      $(".col", container).each(function() {
        $('.nav', container).append('<a href="#" id="p-' + page + '"></a>');
        page++;
      });
      
      $('.nav a', container).first().addClass("current");
      // Dot nav
      
      $(".nav a", container).live("click", function() {
        $(".nav a", container).removeClass("current");
        var dot = $(this);
        var leftPosition = 0 - (parseInt($(dot).attr("id").split("-")[1]) * $(".col", container).width()) + "px";
        
        $(".container", container).animate({
          left: leftPosition
        }, function() {
          $(dot).addClass("current");
        });
        
        return false;
      });
      
      OCT.paginated_collection.keybind(container);
    }
  },
  
  keybind: function(container) {
    $('*').keyup(function(e) {
      if($('#colorbox :visible').length > 0 || document.activeElement != document.body) {
        return;
      }
      
      // Next
      if (e.keyCode == 39 || e.which == 39) {
        var page_id = $(".nav a.current", container).attr("id");
        
        if(page_id) {
          var current = parseInt(page_id.split("-")[1]);
          var next = current + 1;
          OCT.paginated_collection.page(next, container);
        }
      }
      
      // Prev
      if (e.keyCode == 37 || e.which == 37) {
        var page_id = $(".nav a.current", container).attr("id");
        
        if(page_id) {
          var current = parseInt(page_id.split("-")[1]);
          var previous = current - 1;
          OCT.paginated_collection.page(previous, container);
        }
      }
    });
  },
  
  page: function(page, container) {
    if (page >= 0 && page < $(".col", container).length) {
      $(".nav a", container).removeClass("current");
      var leftPosition = 0 - (page * $(".col", container).width()) + "px";
      
      $(".container", container).animate({
        left: leftPosition
      }, function() {
        $("#p-" + page, container).addClass("current");
      });
    }
  }
};


OCT.loading = {  
  init: function() {
      var toggleLoading = function() { $(".loading").toggle() };
      $(".show-more")
        .bind("ajax:loading",  toggleLoading)
        .bind("ajax:complete", toggleLoading);
  }
}

OCT.button_press = {
  init: function() {
    $('.button').live('mousedown', function() {
      $(this).addClass('pressed');
      return false;
    });
    
    $('.button').live('mouseup, mouseout', function() {
      $(this).removeClass('pressed');
    });
  }
};

OCT.hover = {
    // container : '.short-comment, .comment, .collection-viewer',
    container : '.short-comment, .comment,',
    targets : '.date, .toggle,',
    
    init: function () {
      $(OCT.hover.container).unbind('mouseenter mouseleave');
      
      $(OCT.hover.container).hover(function() {
        $(OCT.hover.targets, this).css('color', '#000000');
        $('.toolbar', this).css('visibility', 'visible');
        $('.name.toggle a', this).css('color', '#990000');
        $('a.comment-edit-link.toggle', this).css('color', '#990000');
        $('a.comment-remove-link.toggle', this).css('color', '#990000');
      }, function() {
        $(OCT.hover.targets, this).css('color', '#999999');
        $('.toolbar', this).css('visibility', 'hidden');
        $('.name.toggle a', this).css('color', '#999999');
        $('a.comment-edit-link.toggle', this).css('color', '#999999');
        $('a.comment-remove-link.toggle', this).css('color', '#999999');
      });
    }
};


OCT.textcount = {
  init: function(editing) {
    var short_text = editing ? '#' + editing + ' .edit-short-text' : '#short-text';
    var short_counter = editing ? '#' + editing + ' .edit-counter' : '#short-counter';
    var short_max = 140;
    
    $(short_text).live('keydown keyup focus input paste', function() {
      var remaining = short_max - $(short_text).val().length;
      $(short_counter).html(Math.max(remaining, 0));
      $(short_text).val($(short_text).val().substr(0, short_max));
    });
    
    $(short_counter).html(short_max);
    $(short_text).attr("maxlength", short_max);
    $(short_text).trigger('input');
  }
};


OCT.notice = {
  init: function () {
    setTimeout("$('.notice').fadeOut(1000);", 3000);
    setTimeout("$('.alert').fadeOut(1000);", 5000);
  }
};


OCT.browse = {
  init:function() {
    $.ajax({
      url: '/objects/browse',
      dataType: 'js',
      success: function(response) {
        $('.col1').html(response);
      },
      error: function() {
        $('.col1').html('<div class="engraved">There was a problem getting objects</div>');
      }
    });
    
    // Click on Col 1 | Load discussion
    $('.col1 .item').live('click', function() {
      var type = 'object';
      
      if($(this).hasClass('board')) {
        type ='board';
      }
      else if($(this).hasClass('collection')) {
        type ='collection';
      }
      
      $('.col2').html('<div class="engraved">Loading discussions..</div>');
      $('.col3').html('<div class="engraved">Select a discussion</div>');
      
      $.ajax({
        url: '/discussions/browse',
        data: { id: $(this).attr('id') },
        dataType: 'js',
        success: function(response) {
          $('.col2').html(response);
        },
        error: function() {
          $('.col2').html('<div class="engraved">There was a problem getting ' + type + '</div>');
        }
      });
    });
    
    // Click on discussion | Show comments
    $('.col2 .item').live('click', function() {
      $('.col3').html('<div class="engraved">Loading comments..</div>');
      
      $.ajax({
        url: '/comments/browse',
        data: { id: $(this).attr('id') },
        dataType: 'js',
        success: function(response) {
          $('.col3').html(response);
        },
        error: function() {
          $('.col3').html('<div class="engraved">There was a problem getting comments</div>');
        }
      });
    });
    
    //  TYPE toolbar
    $('.type_toolbar .type').live('click', function() {
      var type = $(this).attr('id');
      var singularized_type = type.substr(0, type.length - 1);
      var humanized_type = type[0].toUpperCase() + type.slice(1);
      var message = 'Select ' + (type == 'objects' ? 'an ' : 'a ') + singularized_type;
      
      $('.browse .titles .focus').html('<div class="engraved">' + humanized_type + '</div>');
      $('.col1').html('<div class="engraved">Loading ' + type + '..</div>');
      $('.col2').html('<div class="engraved">' + message + '</div>');
      $('.col3').html('<div class="engraved"></div>');
      
      $('.type').removeClass('current');
      $(this).addClass('current');
      
      $.ajax({
        url: '/' + type + '/browse',
        dataType: 'js',
        success: function(response) {
          $('.col1').html(response);
        },
        error: function() {
          $('.col1').html('<div class="engraved">There was a problem getting ' + type + '</div>');
        }
      });
    });
  }
};

OCT.home = {
  mode : 'trending',
  
  init: function() {    
    $('.mode_switch a').bind("click", function() {
      if(!$(this).hasClass('current')) {
        OCT.home.mode = $(this).attr("id");
        
        if(this.id == 'recent') {
          $('#comments-or-keywords').removeClass('keywords');
          $('#comments-or-keywords').addClass('comments');
        }
        else {
          $('#comments-or-keywords').removeClass('comments');
          $('#comments-or-keywords').addClass('keywords');
        }
        
        OCT.home.load();
        $('.mode_switch a').removeClass('current');
        $(this).addClass('current');
      }
      
      return false;
    });
    
    /* This looks like it's supposed to show a larger version of the collection image but it's not selecting any dom elements.
       
    $('.film img').live("mouseover", function() {
      $('.large', $(this).parent().parent()).attr("src", $(this).attr("src"));
    });
    */
    
    OCT.home.load();
   },
   
   load: function() {
     var kinds = ['objects', 'collections', 'discussions', (OCT.home.mode == 'recent') ? 'comments' : 'keywords'];
      
     $(kinds).each(function(i, kind) {
       var elem = $('.' + kind + ' .list')[0];
       
       $.ajax({
         url: '/home/' + OCT.home.mode + '_' + kind,
         dataType: 'js',
         success: function(response) {
           $('.' + kind + ' h2').html(kind.toUpperCase());
           $(elem).html(response);
         },
         error: function(response) {
           $('.' + kind + ' h2').html(kind.toUpperCase());
           $(elem).html('<div>Unable to retrieve ' + kind + '</div>');
         }
       });
     });
   }
};

var t;

OCT.menu = {
  init: function() {
    $('.menu').live("mouseover", function() {
      clearTimeout(t);
      $('.menu ul li').css("visibility", "visible");      
    })

    $('.header').live("mouseout", function() {
      t = setTimeout(function(){ $('.menu ul li:not(.main_link)').css("visibility", "hidden");}, 800);          
    })

  }
};

$(document).ready(function(){
    OCT.hover.init();
    OCT.loading.init();
    OCT.notice.init();
    OCT.menu.init();
    OCT.button_press.init();
    $(".highlight_keywords .body").keywordHighlight();
    $('.highlight_annotations').highlightAnnotations();
});

function markitup_preview() {
  $.ajax({
    url: '/comments/markitup_parser',
    data: { data: $('#comment_body').val() || $('#discussion_comments_body').val() },
    type: 'post'
  });
}

/* 
 * @Reply to link helpers
 */

function reply_to(comment_id, author){
  $('.comment-form h2').html('Response to '+ author + '<ul id="cancel-response"><li></li></ul>');
  $('#comment_response_to_id').val(comment_id);
  $('html,body').animate({ scrollTop: $('#new_comment').offset().top }, { duration: 'medium', easing: 'swing'});
  
  $('#cancel-response').click(function() {
    $('.comment-form h2').html('Comment');
    $('#comment_response_to_id').val('');
  });
}

// Collection/live collection form JS
function update_keyword_ands() {
  $('.keyword-filter').each(function(i, elem) {
    if(i < 1) {
      $(elem).children('p:first').html('<p class="label">Include objects with keyword</p>')
    }
    else if(!$(elem).children('.keyword-and')[0]) {
      $(elem).children('p:first').html('<p class="label"><strong>AND</strong> keyword</p>')
    }
  });
}

function update_keyword_ids() {
  $('.keyword-filter').each(function(i, elem) {
    var counter = i + 1;
    $(elem).children('input').attr({ id: 'keyword_' + counter, name: 'keyword[' + counter + ']' });
    $(elem).attr('id', 'keyword_' + counter + '_wrapper');
    
    var remove_link = $(elem).children('a:last');
    remove_link.unbind();
    remove_link.bind('click', function() {
      remove_keyword_field('keyword_' + counter + '_wrapper');
      return false;
    });
  });
}

function check_collection_type(){
  var prefix = $('.new_collection')[0] == undefined ? 'Edit' : 'New';
  var kind = $('#collection_kind_id').val();
  
  $('.collection-title').html(prefix + ' ' + kind);
  $('#name-label').html('Name of ' + kind.toLowerCase());
  $('#description-label').html('Description of ' + kind.toLowerCase());
  
  if(kind == "Keyword Set") {
    $('#live_collection_form').show();
    update_live_collection_results();
  }
  else {
    $('#live_collection_form').hide();
  }
  
  update_keyword_ands();
}

function remove_keyword_field(field_id) {
  if(keyword_count() > 1) {
    $('#' + field_id).remove();
    update_live_collection_results();
  }
  
  update_keyword_ids();
  update_keyword_ands();
}

function add_keyword_field(){
  var last = keyword_count();
  count = last + 1;
  var keyword_field = '<div id="keyword_' + count + '_wrapper" class="keyword-filter">' +
                        '<p id="keyword-label" class="label"><strong>AND</strong> keyword</p>' +
                        '<input class="keyword" id="keyword_' + count + '" name="keyword[' + count + ']" size="30" type="text" />' +
                        '&nbsp;<a href="#" onclick="add_keyword_field(); return false;" title="Add another keyword">' +
                          '<img width="13" height="13" src="/images/icons/add.png" alt="Add" />' +
                        '</a>' +
                        '&nbsp;<a href="#" title="Remove this keyword">' +
                          '<img width="13" height="13" src="/images/icons/cancel.png" alt="Cancel" />' +
                        '</a>' +
                      '</div>';
                      
  $('#keyword_' + last + '_wrapper').after(keyword_field);
  update_keyword_ids();
  $('#keyword_' + last + '_wrapper').children('a:last').bind('click', function() {
    remove_keyword_field('keyword_' + count + '_wrapper');
    return false;
  });
  
  update_keyword_ands();
}

function keyword_count() {
  return $('.keyword').length;
}

function update_live_collection_results() {
  var keywords = new Array();
  $('.keyword').each(function() {
    keywords.push($(this).val());
  });
  
  $.ajax({
     type: "POST",
     url: "/search/live_collection_results",
     data: "keywords=" + keywords.join(',')
   });
}

function cancel_comment_edit_on(comment_id, short_display) {
  $('#' + comment_id + ' .edit_comment').remove();
  
  if(short_display) {
    $('#' + comment_id).children().show();
  }
  else {
    var parent = $('#edit_comment_' + comment_id).parent();
    parent.empty();
    
    $('#original_' + comment_id).attr('id', comment_id);
    parent.append($('#edit-in-progress').children());
    $('#edit-in-progress').remove();
    $('.new_comment .comment-preview').addClass('in-use');
  }
}
