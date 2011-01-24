var Talk = window.Talk || {};

Talk.collection_hover = {
  init: function() {
    $('.collection-thumbnail').mouseover(function() {
      $('.collection-large').attr("src", $(this).attr("src"));
      $('.collection-thumbnail').removeClass('current');
      $(this).addClass('current');
    });
  }
};

Talk.annotater = {
  annotations : {},
  
  init: function(form, annotation, width, height) {
    if($(annotation).length == 0) {
      $(form + ' .annotate-button').hide();
    }
    else {
      $(form + ' .annotate-button').bind('click', function() {
        Talk.annotater.create_annotation(form, annotation, width, height);
      });
    }
  },
  
  create_annotation: function(form, annotation, width, height) {
    var dialog = $(annotation);
    
    if(dialog.length == 1) {
      if(dialog.hasClass('initialized')) {
        Talk.annotater.annotations[annotation].addAnnotations(form + ' .comment_body');
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
        
        Talk.annotater.annotations[annotation] = $(annotation + ' .comment-focus').annotateImage({
          editable: true,
          useAjax: false,
          markupField: form + ' .comment_body'
        });
        
       Talk.annotater.annotations[annotation].addAnnotations(form + ' .comment_body');
        
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

Talk.collection_lightbox = {
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

Talk.paginated_collection = {
  init: function() {
    $(".collection-info.paginatable_collection").each(function() {
      Talk.paginated_collection.list($(this));
      $(this).removeClass('paginatable_collection');
      $(this).addClass('paginated_collection');
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
      
      Talk.paginated_collection.keybind();
    }
  },
  
  keybind: function() {
    if($('*').data('events') && $('*').data('events').keyup != 'undefined') {
      $('*').unbind('keyup');
    }
    
    $('*').keyup(function(e) {
      if(!(e.keyCode == 37 || e.which == 37 || e.keyCode == 39 || e.which == 39)) {
        return;
      }
      else if($('#colorbox :visible').length > 0 || document.activeElement != document.body) {
        return;
      }
      
      jQuery.each($('.collection-info.paginated_collection:has(.nav a)'), function() {
        var container = $(this);
        
        // Next
        if(e.keyCode == 39 || e.which == 39) {
          var page_id = $(".nav a.current", container).attr("id");
          
          if(page_id) {
            var current = parseInt(page_id.split("-")[1]);
            var next = current + 1;
            Talk.paginated_collection.page(next, container);
          }
        }
        
        // Prev
        if(e.keyCode == 37 || e.which == 37) {
          var page_id = $(".nav a.current", container).attr("id");
          
          if(page_id) {
            var current = parseInt(page_id.split("-")[1]);
            var previous = current - 1;
            Talk.paginated_collection.page(previous, container);
          }
        }
      });
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

Talk.button_press = {
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

Talk.hover = {
    // container : '.short-comment, .comment, .collection-viewer',
    container : '.short-comment, .comment,',
    targets : '.date, .toggle,',
    
    init: function () {
      $(Talk.hover.container).unbind('mouseenter mouseleave');
      
      $(Talk.hover.container).hover(function() {
        $(Talk.hover.targets, this).css('color', '#000000');
        $('.toolbar', this).css('visibility', 'visible');
        $('.name.toggle a', this).css('color', '#990000');
        $('a.comment-edit-link.toggle', this).css('color', '#990000');
        $('a.comment-remove-link.toggle', this).css('color', '#990000');
      }, function() {
        $(Talk.hover.targets, this).css('color', '#999999');
        $('.toolbar', this).css('visibility', 'hidden');
        $('.name.toggle a', this).css('color', '#999999');
        $('a.comment-edit-link.toggle', this).css('color', '#999999');
        $('a.comment-remove-link.toggle', this).css('color', '#999999');
      });
    }
};


Talk.textcount = {
  init: function(editing) {
    var short_text = editing ? '#' + editing + ' .edit-short-text' : '#short-text';
    var short_counter = editing ? '#' + editing + ' .edit-counter' : '#short-counter';
    var short_max = 140;
    
    $(short_text).live('keydown keyup focus input paste', function() {
      var remaining = short_max - $(short_text).val().length;
      $(short_counter).html(Math.max(remaining, 0));
      
      var text = $(short_text).val();
      
      if(text.length > short_max) {
        $(short_text).val(text.substr(0, short_max));
      }
    });
    
    $(short_counter).html(short_max);
    $(short_text).attr("maxlength", short_max);
    $(short_text).trigger('input');
  }
};


Talk.notice = {
  init: function () {
    setTimeout("$('.notice').fadeOut(1000);", 3000);
    setTimeout("$('.alert').fadeOut(1000);", 5000);
  }
};


Talk.browse = {
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

var t;

Talk.menu = {
  init: function() {
    $('.menu').live("mouseover", function() {
      clearTimeout(t);
      $('.menu ul li').css("visibility", "visible");
    });
    
    $('.header').live("mouseout", function() {
      t = setTimeout(function() {
        $('.menu ul li:not(.main_link)').css("visibility", "hidden");
      }, 800);
    });
  }
};

Talk.active_ticker = {
  timer: null,
  is_hovered: false,
  
  init: function() {
    if($('#active-users #users > .user-page').length < 2) {
      return;
    }
    
    $('#active-users').hover(function() {
      $('#active-users .handle').fadeIn();
      Talk.active_ticker.is_hovered = true;
    }, function() {
      $('#active-users .handle').fadeOut();
      Talk.active_ticker.is_hovered = false;
      Talk.active_ticker.init_timer();
    });
    
    $('#active-users #handle-up').click( function(event) {
      Talk.active_ticker.slide('up', true);
      return false;
    });
    
    $('#active-users #handle-down').click( function(event) {
      Talk.active_ticker.slide('down', true);
      return false;
    });
    
    Talk.active_ticker.init_timer();
  },
  
  init_timer: function() {
    clearTimeout(Talk.active_ticker.timer);
    Talk.active_ticker.timer = setTimeout(Talk.active_ticker.slide, 3000);
  },
  
  slide: function(direction, force) {
    if(!Talk.active_ticker.is_hovered || force) {
      var amount = direction == 'down' ? 0 : -20;
      
      if(direction == 'down') {
        var last = $('#users .user-page').last();
        last.css('marginTop', -20);
        $('#users').prepend(last.remove());
      }
      
      var elem = $('#users .user-page').first();
      
      elem.animate({
          marginTop: amount
      },
      300, 'linear', function() {
        if(amount < 0) {
          elem.remove();
          $('#users').append(elem);
          elem.css('marginTop', 0);
        }
      });
      
      if(!force) {
        Talk.active_ticker.init_timer();
      }
    }
  }
};

$(document).ready(function(){
    Talk.hover.init();
    Talk.notice.init();
    Talk.menu.init();
    Talk.button_press.init();
    Talk.active_ticker.init();
    $(".highlight_keywords .body").keywordHighlight();
    $('.highlight_annotations').highlightAnnotations();
});

function markitup_preview() {
  if($('#comment_body').length > 0 || $('#discussion_comments_body').length > 0) {
    $.ajax({
      url: '/comments/markitup_parser',
      data: {
        body: $('#comment_body').val() || $('#discussion_comments_body').val()
      },
      type: 'post'
    });
  }
  else if($('.new-message-body #message_body').length > 0) {
    $.ajax({
      url: '/messages/preview.js',
      data: {
        body: $('#message_body').val(),
        recipient: $('#message_recipient_name').val()
      },
      type: 'post'
    });
  }
}

/* 
 * @Reply to link helpers
 */

function reply_to(comment_id, author, author_id) {
  var reply_text = $('#' + comment_id + ' .raw').text();
  reply_text = reply_text.replace(/([\r\n]+\s*)/ig, "\n> ");
  reply_text = reply_text.replace(/^\s*/, "");
  reply_text = '\n> [' + author + '](' + '/users/' + author_id + ' "' + author + '"):\n> ' + reply_text + "\n\n";
  $('#comment_body').insertAtCaretPos(reply_text);
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

function cancel_discussion_edit() {
  $('.edit_discussion').remove();
  $('.edit-discussion-link').show();
  $('#discussion-subject h1').show();
}

function page_loading(nav) {
  nav.css('background', 'url("/images/icons/loading.gif") no-repeat center center');
  var container = nav.closest('.list').parent();
  
  if(container.attr('id') == "discussions" && container.hasClass('recent')) {
    $('.page-loader', nav).replaceWith($('<div class="more">Older</div>'));
  }
  else if(container.attr('id') == "discussions" && container.hasClass('trending')) {
    $('.page-loader', nav).replaceWith($('<div class="more">Less popular</div>'));
  }
  else {
    $('.page-loader', nav).replaceWith($('<div class="more"></div>'));
  }
}

function page_done_loading(nav) {
  nav.css('background', 'none');
}

function page_more(link) {
  var current_page = $(link).closest('.page');
  var next_page = current_page.prev('.page');
  
  $('.page-nav', current_page).hide();
  
  next_page.animate({
    marginLeft: 0
  }, 600, 'linear', function() {
    $('.page-nav', next_page).show();
  });
}

function page_less(link) {
  var current_page = $(link).closest('.page');
  var previous_page = current_page.next('.page');
  
  $('.page-nav', current_page).hide();
  
  current_page.animate({
    marginLeft: -650
  }, 600, 'linear', function() {
    $('.page-nav', previous_page).show();
  });
}
