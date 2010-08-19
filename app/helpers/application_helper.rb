module ApplicationHelper
  def long_date(datetime)
    datetime.strftime("%d %B %Y, %I.%M %p")
  end
end