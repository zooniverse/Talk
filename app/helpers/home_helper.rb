module HomeHelper
  def link_to_more(*args)
    options = { :showing => 'recent', :format => :js }.update(args.extract_options!)
    link_to args.first, { :controller => :home, :action => :more }.merge(options), { :remote => true, :method => :post, :class => 'page-loader' }
  end
  
  def title_link_for(discussion)
    name = if discussion.board?
      discussion.focus.title
    else
      discussion.focus_type.sub(/LiveCollection/, 'KeywordSet').sub(/Asset/, 'Object')
    end
    
    link = link_to name.underscore.split('_').map(&:capitalize).join(" "), parent_url_for(discussion), :class => "parent-link"
    link += ": "
    
    subject = discussion.focus_base_type == "Collection" ? " #{ discussion.focus.name }" : discussion.subject
    
    link += link_to truncate(subject, :length => 60, :separator => ' '), discussion_url_for(discussion), :class => "discussion-link"
    link.html_safe
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
