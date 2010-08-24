module ApplicationHelper
  def long_date(datetime)
    datetime.strftime("%d %B %Y, %I.%M %p")
  end
  
  def markdown(text)
    output = BlueCloth::new(text).to_html
    
    tags = ["h1","h2","h3","h4","h5","h6"]
    
    tags.each do |tag|
      output.gsub!(/<#{tag}\b[^>]*>(.*?)<\/#{tag}>/in, '\1')
    end
    
    return output
    
  end
  
end