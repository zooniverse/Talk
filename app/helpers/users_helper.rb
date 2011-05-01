# Helpers for Users
module UsersHelper
  # Defines more links for User Comments and Discussions
  [:comments, :discussions].each do |group|
    define_method "more_#{ group }".to_sym do |*args|
      options = args.extract_options!
      options = { :page => 1, :per_page => 10, :format => :js }.update(options)
      link_to args.first, { :controller => :users, :action => group }.merge(options), { :remote => true, :method => :post }
    end
  end
end
