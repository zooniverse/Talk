# Helpers for Home
module HomeHelper
  # Switches between recent and trending
  # @param *args [Array] The link text
  # @option *args [String] :showing ('recent') The results to show
  # @option *args [Fixnum] :page The page of results to find
  # @option *args [Fixnum] :per_page The number of results per page
  def link_to_more(*args)
    options = { :showing => 'recent', :format => :js }.update(args.extract_options!)
    link_to args.first, { :controller => :home, :action => :more }.merge(options), { :remote => true, :method => :post, :class => 'page-loader' }
  end
  
  # Link to more results
  # @option *args [Array] :collection The paginated results
  # @option *args [String] :type ('page') The type of results to show
  # @option *args [Fixnum] :per_page The number of results per page
  def page_listing(*args)
    opts = { :collection => nil, :type => 'page', :per_page => 10 }.update(args.extract_options!)
    return "" unless opts[:collection] && opts[:collection].any?
    
    if opts[:type] == 'trending'
      first = opts[:per_page] * (opts[:collection].current_page - 1) + 1
      last = opts[:per_page] * opts[:collection].current_page
      
      "#{ number_with_delimiter first } to #{ number_with_delimiter last }"
    else
      "Page #{ number_with_delimiter opts[:collection].current_page } of #{ number_with_delimiter opts[:collection].total_pages }"
    end
  end
end
