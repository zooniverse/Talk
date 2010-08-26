class CollectionsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => [:new, :edit, :add]
  respond_to :js, :only => :add
  
  def show
    @focus = @collection = Collection.find_by_zooniverse_id(params[:id])
    @discussion = @collection.conversation
    @mentions = Discussion.mentioning(@collection)
    @comment = Comment.new
    @comments = @collection.conversation.comments
    
    @tags = @collection.tags
  end
  
  def new
    @collection = Collection.new
    @asset = Asset.find_by_zooniverse_id(params[:zooniverse_id]) unless params[:zooniverse_id].nil?
  end
  
  def edit
    @collection = Collection.find_by_zooniverse_id(params[:id])
  end
  
  def create
    @collection = Collection.new(params[:collection])
    @collection.user = current_zooniverse_user
    
    if @collection.save
      @collection.conversation = Discussion.create(:subject => @collection.zooniverse_id)
      @collection.save
      flash[:notice] = I18n.t 'controllers.collections.flash_create'
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end
  
  def add
    @collection = Collection.find_by_zooniverse_id(params[:id])
    @asset = Asset.find_by_zooniverse_id(params[:asset_id])
    
    unless current_zooniverse_user == @collection.user
      flash[:notice] = I18n.t 'controllers.collections.not_yours'
    end
    
    if @collection.asset_ids.include? @asset.id
      flash[:notice] = I18n.t 'controllers.collections.already_added'
    else
      @collection.asset_ids << @asset.id
      
      if @collection.save
        flash[:notice] = I18n.t('controllers.collections.added')
        @success = true
      end
    end
  end
end
