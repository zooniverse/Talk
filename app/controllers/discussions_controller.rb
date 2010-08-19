class DiscussionsController < ApplicationController
  
  def show
    @discussion = Discussion.find_by_zooniverse_id(params[:id]) 
    @comment = Comment.new
    
    if (@discussion.live_collection?) 
      
    end
  end
  
end
