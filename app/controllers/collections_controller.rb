class CollectionsController < ApplicationController
  def show
    @collection = Collection.find_by_zooniverse_id(params[:id])
    @focus = @collection
    @mentions = Discussion.mentioning(@collection)
    @comment = Comment.new
    @comments = @collection.conversation.comments
    
    @tags = ["Tag1", "Tag2", "Tag3"]
  end
end
