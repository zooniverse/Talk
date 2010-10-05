module AdminHelper
  def list_more(*args)
    options = { :page => 1, :per_page => 10, :format => :js }.update(args.extract_options!)
    [:page, :per_page].each{ |opt| options["#{ args.first }_#{ opt }".to_sym] = options.delete(opt) }
    link_to "More", { :controller => :admin, :action => :index, :more => args.first.to_sym }.merge(options), { :remote => true, :method => :get }
  end
end
