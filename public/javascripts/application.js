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
}


// --
$(document).ready(function(){
		OCT.tabs.init();
		OCT.collection.init();
		OCT.scroll.init();
});