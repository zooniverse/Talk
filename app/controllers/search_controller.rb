class SearchController < ApplicationController
  
  def index 
    @text=params[:text]
    
    if(@text)
      @results_comments= Comment.search @text, :from_mongo=>true 
      @results_discussions= (Comment.search @text, :from_mongo=>true, :collapse=>:discussion_id).collect{|d| Discussion.find(d[:discussion_id])}
      @results_assets =@results_discussions.collect{|d| d.focus if d.focus_type=="Asset"}.compact!
    end 
    
  end
  
end
