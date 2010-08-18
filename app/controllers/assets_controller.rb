class AssetsController < ApplicationController
  
  def show
    @asset = Asset.find_by_zooniverse_id(params[:id])
    @focus = @asset
    @mentions = Discussion.mentioning(@asset)
    @collections = Collection.with_asset(@asset)
    @comment = Comment.new
    
    if @asset.conversation.nil?
      @comments = []
    else
      @comments = @asset.conversation.comments
    end
  end
end
