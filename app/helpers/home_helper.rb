module HomeHelper
  def link_to_more(*args)
    options = { :showing => 'recent', :format => :js }.update(args.extract_options!)
    link_to args.first, { :controller => :home, :action => :more }.merge(options), { :remote => true, :method => :post, :class => 'page-loader' }
  end
  
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
