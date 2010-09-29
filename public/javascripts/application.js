// 
// Oxford Communication Tool
// 
//
var OCT = window.OCT || {};

/* 
 * @Namespace Tabs
 */
OCT.tabs = {
  trends      : '#trends-tabs',
  recents      : '#recents-tabs',

  // Initialise bindings for tabs
  init: function () {
    $(OCT.tabs.trends).tabs();
    $(OCT.tabs.recents).tabs();
  }
};

/* 
 * @Namespace Collection Viewing
 */
OCT.collection = {
  large          : '.collection-large',
  thumbnail      : '.collection-thumbnail',

  // Initialise switching behaviour
  init: function () {
    $(OCT.collection.thumbnail).mouseover(function() {
      $(OCT.collection.large).attr("src", $(this).attr("src"));
    });
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


/* 
 * @Namespace Hovering
 */
OCT.hover = {

    item      : '.short-comment, .comment',
    toolbar : '.toolbar',
    
    init: function () {
      $(OCT.hover.item).hover(function() {
        $(OCT.hover.toolbar, this).css('visibility', 'visible');
      }, function() {
        $(OCT.hover.toolbar, this).css('visibility', 'hidden');
      });
    }
};

OCT.textcount = {
  short_text : '#short-text',
  short_counter : "#short-counter",
  short_max : 140,
  
  init: function() {
    $(OCT.textcount.short_text).live('keydown keyup focus input paste', function() {
      var remaining = OCT.textcount.short_max - $(OCT.textcount.short_text).val().length;
      $(OCT.textcount.short_counter).html(Math.max(remaining, 0));
      $(OCT.textcount.short_text).val($(OCT.textcount.short_text).val().substr(0, OCT.textcount.short_max));
    });
    
    $(OCT.textcount.short_counter).html(OCT.textcount.short_max);
    $(OCT.textcount.short_text).attr("maxlength", OCT.textcount.short_max);
  }
};


// --
$(document).ready(function(){
    OCT.tabs.init();
    OCT.collection.init();
    OCT.hover.init();
    OCT.loading.init();
    OCT.textcount.init();
    $(".highlight_keywords").keywordHighlight();
    $('.highlight_annotations').highlightAnnotations();
});


// Utility
function clear_input(a){
  myfield = document.getElementById(arguments[0]);
  myfield.value = "";
}

function replace_input(a,b){
  myfield = document.getElementById(arguments[0]);
  if (myfield.value == "") {
   myfield.value = arguments[1];
  }
}

function clear_this(element){
  element.value = "";
}

function replace_this(element){
  if (element.value == ""){
    element.value = "Add a keyword";
  } 
}

/* 
 * @Reply to link helpers
 */

function reply_to(comment_id, author){
  $('#comment-form-title').html('Reply to '+ author)
  $('#comment_response_to_id').val(comment_id);
  $('html,body').animate({ scrollTop: $('#new_comment').offset().top }, { duration: 'medium', easing: 'swing'});
}

// Collection/live collection form JS

function check_collection_type(){
  if ($('#collection_kind_id').val() == "Live Collection"){
    $('#live_collection_form').show();
  } else if ($('#collection_kind_id').val() == "Collection"){
    $('#live_collection_form').hide();
  }
}

function remove_keyword_field(field_id){
  $('#'+field_id + '_wrapper').remove();
}

function add_keyword_field(){
  var last = get_keyword_count();
  count = last + 1;
  $("#keyword_" + last + "_wrapper").after("<div id='keyword_"+count+"_wrapper'><input class='keyword' id='keyword_"+ count + "' name='keyword["+count+"]' size='30' type='text' value='Add a keyword' onfocus='clear_this(this);' onblur='replace_this(this);' /> <a href='#' onclick='add_keyword_field();'><img alt='Add' height='13' src='/images/add.png' width='13' /></a>" + " <a href='#' onclick=\"remove_keyword_field('keyword_"+count+"');\"><img alt='Cancel' height='13' src='/images/cancel.png' width='13' /></div>");
}

function get_keyword_count(){
  return $('.keyword').length;
}

function update_live_collection_results(){
  var keywords = new Array();
  $('.keyword').each(function(){
    keywords.push($(this).val());
  });
  
  $.ajax({
     type: "POST",
     url: "/search/live_collection_results",
     data: "keywords="+keywords.join(',')
   });
}
