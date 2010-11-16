module ApplicationHelper
  def long_date(datetime)
    datetime.strftime("%d %B %Y, %I.%M %p")
  end
  
  def short_id_for(focus)
    focus.zooniverse_id.sub /.MZ/, ''
  end
end
