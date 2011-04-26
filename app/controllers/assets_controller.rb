class AssetsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => [:show]
  before_filter :check_or_create_zooniverse_user
  respond_to :js, :only => [:browse]
  
  def show
    default_params :page => 1, :per_page => 10
    @asset = Asset.find_by_zooniverse_id(params[:id])
    return not_found unless @asset
    @page_title = @asset.zooniverse_id
    
    @focus = @asset
    @mentions = Discussion.mentioning(@asset)
    @collections = AssetSet.with_asset @asset, :page => 1, :per_page => 20
    @comment = Comment.new
    
    @discussion = @asset.conversation
    @discussion_id = @asset.conversation_id
    @comments = Comment.sort(:created_at.desc).where(:discussion_id => @discussion_id).paginate(:page => @page, :per_page => @per_page)
  end
  
  def browse
    default_params :page => 1, :per_page => 10
    @assets = Asset.trending :page => @page, :per_page => @per_page
    
    respond_with(@assets) do |format|
      format.js { render :partial => "browse" }
    end
  end
end
