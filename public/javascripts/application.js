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


OCT.collection = {
  large          : '.collection-large',
  thumbnail      : '.collection-thumbnail',

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


OCT.hover = {
    container : '.short-comment, .comment, .collection-viewer',
    targets : '.toolbar, .date, .toggle',
    
    init: function () {
      $(OCT.hover.container).hover(function() {
        $(OCT.hover.targets, this).css('visibility', 'visible');
      }, function() {
        $(OCT.hover.targets, this).css('visibility', 'hidden');
      });
      
      $('#asset-as-focus .rounded-panel').hover(function(){
        $('.asset-actions', this).css('visibility', 'visible');
      }, function() {
        $('.asset-actions', this).css('visibility', 'hidden');        
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


OCT.notice = {
  init: function () {
    $('.notice').bind("click", function(){ $(this).hide()});    
    setTimeout("$('.notice').fadeOut(1000);", 3000);
  }
};


OCT.explore = {  
  init:function() {
     $.ajax({
       url: '/assets/list_for_explorer',
       dataType: 'js',
       success: function(response) {
         $('.col1').html(response);
       }, 
       error: function() {
         $('.col1').html("<div class='engraved'>Problem getting Asssets</div>");         
       }
     });
    
     // Click on Col 1 | Load discussion 
     $('.col1 .item').live('click', function() {     
        $('.col2').html("<div class='engraved'>Loading..</div>");    
        $('.col3').html("<div class='engraved'>Comments</div>");    
                  
        var type = "asset";
        if ($(this).hasClass("board")) {
          type ="board";
        }
        if ($(this).hasClass("collection")) {
          type ="collection";
        }
      
       $.ajax({
         url: '/discussions/list_for_'+type,       
         data: {id: $(this).attr('id')},
         dataType: 'js',
         success: function(response) {
           $('.col2').html(response);    
         }, 
         error: function() {
           $('.col2').html("<div class='engraved'>Problem getting "+type+"</div>");         
         }
       });
     }); 
   
     // Click on discussion | Show comments
    $('.col2 .item').live('click', function() {     
      $('.col3').html("<div class='engraved'>Loading..</div>");    
      $.ajax({
        url: '/comments/list_for_discussion',       
        data: {id: $(this).attr('id')},
        dataType: 'js',
        success: function(response) {
          $('.col3').html(response);
        }, 
        error: function() {
          $('.col3').html("<div class='engraved'>Problem getting comments</div>");         
        }
      });
    });

    //  TYPE toolbar
    $('.type_toolbar .type').live('click', function() {     
       $('.col1').html("<div class='engraved'>Loading..</div>");          
       $('.col2').html("<div class='engraved'></div>");    
       $('.col3').html("<div class='engraved'></div>");    

       $('.type').removeClass("current");
       $(this).addClass("current");
       var type = $(this).attr("id");             
        $.ajax({
               url: '/'+type+'/list_for_explorer',
               dataType: 'js',
               success: function(response) {
                 $('.col1').html(response);
               }, 
               error: function() {
                 $('.col1').html("<div class='engraved'>Problem getting type</div>");         
               }
             });                         
     });         
  }
};


OCT.home = {
  mode : 'trending',
  
  init: function() {    
    $('.mode_switch a').bind("click", function() {
      if (!$(this).hasClass('current')) {
        OCT.home.mode = $(this).attr("id");
        OCT.home.load();
        $('.mode_switch a').removeClass("current");
        $(this).addClass('current');
      }
      return false;
    });
    
    $('.film img').live("mouseover", function() {
      $('.large', $(this).parent().parent()).attr("src", $(this).attr("src"));
    });
    
    OCT.home.load();
        
    // Commment user image hover
    $('.home .comment img').live("mouseenter", function() {
      $('.author', $(this).parent()).css("display", "inline");
    });
    
    $('.home .comment').live("mouseleave", function() {
      $('.author', this).css("display", "none");
    });                  
   },
   
   load: function() {
      var types = new Array("collections", "assets", "discussions", "comments");  
       $(types).each(function(i, type){
         $("."+type+" .list").html("<p class='loading'>Loading..</p>")
         $.ajax({
          url: '/home/'+OCT.home.mode+'_'+type,
          dataType: 'js',
          success: function(response) {
            $("."+type+" .list").html(response);
          }, 
          error: function() {
            $("."+type+" .list").html("<div>Problem getting "+type+"</div>");         
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
    OCT.tabs.init();
    OCT.collection.init();
    OCT.hover.init();
    OCT.loading.init();
    OCT.textcount.init();
    OCT.notice.init();    
    OCT.explore.init();  
    OCT.home.init();     
    OCT.menu.init();          
    $('.highlight_annotations').highlightAnnotations();
    $(".highlight_keywords").keywordHighlight();
});

function markitup_preview() {
  $.ajax({
    url: '/comments/markitup_parser',
    data: { data: $('#comment_body').val() || $('#discussion_comments_body').val() },
    type: 'post'
  });
}


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