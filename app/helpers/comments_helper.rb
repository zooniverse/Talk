# Helpers for Comments
module CommentsHelper
  # Link to more Comments
  # @param *args [Array] The link text
  # @option *args [Fixnum] :page (1) The page of Comments to find
  # @option *args [Fixnum] :per_page (10) The number of Comments per page
  def list_more_comments(*args)
    options = { :page => 1, :per_page => 10, :format => :js }.update(args.extract_options!)
    link_to args.first, { :controller => :comments, :action => :more }.merge(options), { :remote => true, :method => :post }
  end
end
