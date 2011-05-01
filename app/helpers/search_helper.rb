# Helpers for Search
module SearchHelper
  # Link to more results
  # @param *args [Array] The link text
  # @option *args [Fixnum] :page (1) The page of results to find
  # @option *args [Fixnum] :per_page (10) The number of results per page
  # @option *args [String] :for ('comments') The type of results to search for
  # @option *args [String] :search ('') The search text
  def more_results(*args)
    options = args.extract_options!
    options = { :page => 1, :per_page => 10, :for => "comments", :search => "", :format => :js }.update(options)
    link_to args.first, { :controller => :search, :action => :index }.merge(options), { :remote => true, :method => :post }
  end
end
