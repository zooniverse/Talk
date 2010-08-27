class AssetsController < ApplicationController
  before_filter :check_or_create_zooniverse_user
  
  def show
    @asset = Asset.find_by_zooniverse_id(params[:id])
    @focus = @asset
    @mentions = Discussion.mentioning(@asset)
    @collections = Collection.with_asset(@asset)
    @comment = Comment.new
    
    @discussion = @asset.conversation
  
    if @asset.conversation.nil?
      @comments = []
    else
      @comments = @asset.conversation.comments
    end
  end

end
