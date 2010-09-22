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
