class LiveCollectionsController < ApplicationController
  def show
    @focus = @collection = LiveCollection.find_by_zooniverse_id(params[:id])
    @discussion = @collection.conversation
    @mentions = Discussion.mentioning(@collection)
    @comment = Comment.new
    @comments = @collection.conversation.comments
    
    @tags = @collection.tags
  end
end
