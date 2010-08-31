module PaginationHelper
  def page_bar(current_page, total_pages)
    bar = "<ul>"
    
    1.upto(total_pages) do |page|
      page_name = page == current_page ? "<#{page}>" : "#{page}"
      
      bar += "<li class=\"pagination\">"
      bar += link_to page_name, "#{request.path}?page=#{page}"
      bar += "</li>"
    end
    
    bar += "</ul>"
    bar.html_safe
  end
end
