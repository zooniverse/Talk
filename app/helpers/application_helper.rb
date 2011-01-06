module ApplicationHelper
  def long_date(datetime)
    datetime.strftime("%d %B %Y, %I.%M %p")
  end
  
  def short_id_for(focus)
    focus.zooniverse_id.sub /.MZ/, ''
  end
  
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
end
