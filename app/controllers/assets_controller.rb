class AssetsController < ApplicationController
  before_filter :check_or_create_zooniverse_user
  
  def show
    @asset = Asset.find_by_zooniverse_id(params[:id])
    @focus = @asset
    @mentions = Discussion.mentioning(@asset)
    @collections = Collection.with_asset(@asset)
    @comment = Comment.new
    
    @discussion_id = @asset.conversation_id
    @comments = Comment.sort(:created_at.desc).where(:discussion_id => @discussion_id).paginate(:page => 1, :per_page => 10)
    @page = 1
  end
end
