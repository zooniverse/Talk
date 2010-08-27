class LiveCollectionsController < ApplicationController
  def show
    @focus = @collection = LiveCollection.find_by_zooniverse_id(params[:id])
    @discussion = @collection.conversation
    @mentions = Discussion.mentioning(@collection)
    @comment = Comment.new
    @comments = @collection.conversation.comments
    
    @tags = @collection.tags
  end
  
  def edit
    @collection = LiveCollection.find_by_zooniverse_id(params[:id])
  end
  
  def update
    @collection = LiveCollection.find(params[:id])
    @collection.tags = params[:keyword].values
    
    if @collection.update_attributes(params[:live_collection])
      flash[:notice] = I18n.t 'controllers.collections.flash_updated'
      redirect_to live_collection_path(@collection.zooniverse_id)
    else
      render :action => 'edit'
    end
  end
end