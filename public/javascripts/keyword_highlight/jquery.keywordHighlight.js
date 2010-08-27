
$.fn.keywordHighlight = function(options) {
  var defaults = {
  
  };
  // Extend our default options with those provided.

  var opts = $.extend({}, $.fn.keywordHighlight.defaults, options);

  // Our plugin implementation code goes here.

	return this.each(function(){
			$this = $(this);
			var text = $this.html();
		
			
			var result=text.replace(/(^|\s)#(\w+)/g, "$1<a class='keyword'  href='/search?search=keywords%3A$2'>#$2</a>");
			
			$this.html(result);
			return $this;
	});	
	
};
