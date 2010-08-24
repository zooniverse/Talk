module ApplicationHelper
  def long_date(datetime)
    datetime.strftime("%d %B %Y, %I.%M %p")
  end
  
  def markdown(text)
    BlueCloth::new(text).to_html
  end
  
end