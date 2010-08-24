// 
// Oxford Communication Tool
// 
//
var OCT = window.OCT || {};

/* 
 * @Namespace Tabs
 */
OCT.tabs = {
	trends			: '#trends-tabs',
	recents			: '#recents-tabs',

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
	large					: '.collection-large',	
	thumbnail			: '.collection-thumbnail',

	// Initialise switching behaviour
	init: function () {
		$(OCT.collection.thumbnail).bind('click', function(){			
			$(OCT.collection.large).attr("src", $(this).attr("src"));
		});
	}
};

/* 
 * @Namespace Scrolling
 */
OCT.scroll = {
		init: function () {

		}
};

/* 
 * @Namespace Hovering
 */
OCT.hover = {

		hidden			: '.short-comment',
		vote_controls : '.toolbar',
		
		init: function () {
			$(OCT.hover.hidden).hover(function() {	
				$(OCT.hover.vote_controls, this).css('visibility', 'visible');
			}, function() {
				$(OCT.hover.vote_controls, this).css('visibility', 'hidden');
			});		
		}
};


// --
$(document).ready(function(){
		OCT.tabs.init();
		OCT.collection.init();
		OCT.scroll.init();
		OCT.hover.init();
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

// --
function reply_to(comment_id){
	$('#comment_response_to_id').val(comment_id);
	$('html,body').animate({ scrollTop: $('#new_comment').offset().top }, { duration: 'medium', easing: 'swing'});
}