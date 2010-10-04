module CommentsHelper
  def list_more_comments(*args)
    options = { :page => 1, :per_page => 10, :format => :js }.update(args.extract_options!)
    link_to args.first, { :controller => :comments, :action => :more }.merge(options), { :remote => true, :method => :post }
  end
end
