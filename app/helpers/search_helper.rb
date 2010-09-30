module SearchHelper
  def more_results(*args)
    options = args.extract_options!
    options = { :page => 1, :per_page => 10, :for => "comments", :search => "", :format => :js }.update(options)
    link_to args.first, { :controller => :search, :action => :index }.merge(options), { :remote => true, :method => :post }
  end
end
