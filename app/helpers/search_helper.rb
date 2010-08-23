module SearchHelper
  def more_results(*args)
    options = args.extract_options!
    options = { :page => @page, :per_page => @per_page, :search => @search, :format => :js }.update(options)
    link_to args.first, { :controller => :search, :action => :index }.merge(options), { :remote => true, :method => :post }
  end
end
