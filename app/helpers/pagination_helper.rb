module PaginationHelper
  def page_bar (page_no,no_of_pages)
    
    path = request.path
    s="<ul>"
    (1..no_of_pages).each do |i|
      if(i==page_no)
        s<< "<li class='pagination'> <a href=#{path}?page=#{i}> \<#{i}\> </a> </li>" 
      else
        s<< "<li class='pagination'> <a href=#{path}?page=#{i}>#{i}</a> </li>" 
      end
    end
    s<<"</ul>"
    s.html_safe
  end
end
