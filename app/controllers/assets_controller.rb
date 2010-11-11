class AssetsController < ApplicationController
  before_filter :check_or_create_zooniverse_user
  respond_to :js, :only => [:list_for_browser]
  
  def show
    default_params :page => 1, :per_page => 10
    @asset = Asset.find_by_zooniverse_id(params[:id])
    @focus = @asset
    @mentions = Discussion.mentioning(@asset)
    @collections = Collection.with_asset @asset, :per_page => 4
    @comment = Comment.new
    
    @discussion = @asset.conversation
    @discussion_id = @asset.conversation_id
    @comments = Comment.sort(:created_at.desc).where(:discussion_id => @discussion_id).paginate(:page => @page, :per_page => @per_page)
  end
  
  def list_for_browser
    @assets = Asset.trending(5)
    respond_with(@assets) do |format|
      format.js { render :partial => "list_for_browser" }
    end
  end
  
end
