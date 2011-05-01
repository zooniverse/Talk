# Helpers for the App
module ApplicationHelper
  # Titles the page
  def title_for_page
    title = "Moon Zoo | Talk"
    title += " | #{ @page_title }" if @page_title
    title
  end
  
  # Prettify a date
  # @param datetime [ActiveSupport::TimeWithZone] The datetime
  def long_date(datetime)
    datetime.strftime("%d %B %Y, %I.%M %p")
  end
  
  # A ZooniverseId without the prefix
  # @param focus The Focus to get the Id from
  def short_id_for(focus)
    focus.zooniverse_id.sub /.MZ/, ''
  end
  
  # The User role CSS
  # @param user [User] The User to get the role from
  def name_class_for(user)
    if user.is_scientist?
      return "name scientist"
    elsif user.admin?
      return "name admin"
    elsif user.moderator?
      return "name moderator"
    else
      return "name"
    end
  end
  
  # Handy formatted link to a Discussion
  # @param *args [Array] The Discussion to link to
  # @option *args [Boolean] :focus_prefix (true) Label the Focus type if true
  def title_link_for(*args)
    opts = { :focus_prefix => true }.update(args.extract_options!)
    discussion = args.first
    
    link = ""
    
    if opts[:focus_prefix]
      name = if discussion.board?
        discussion.focus.pretty_title
      else
        discussion.focus_type.sub(/KeywordSet/, 'KeywordSet').sub(/Asset/, 'Object')
      end
      
      link += link_to name.underscore.split('_').map(&:capitalize).join(" "), discussion.parent_path, :class => "parent-link"
      link += ": "
    end
    
    subject = discussion.focus_base_type == "AssetSet" ? " #{ discussion.focus.name }: #{ discussion.subject }" : discussion.subject
    link += link_to truncate(subject, :length => 60, :separator => ' '), discussion.path, :class => "discussion-link"
    link.html_safe
  end
end
