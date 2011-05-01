# Helpers for Admin
module AdminHelper
  # Link to List more Events
  # @option *args [Fixnum] :page (1) The page of Events to find
  # @option *args [Fixnum] :per_page (10) The number of Events per page
  def list_more(*args)
    options = { :page => 1, :per_page => 10, :format => :js }.update(args.extract_options!)
    [:page, :per_page].each{ |opt| options["#{ args.first }_#{ opt }".to_sym] = options.delete(opt) }
    link_to "More", { :controller => :admin, :action => :index, :more => args.first.to_sym }.merge(options), { :remote => true, :method => :get }
  end
end
