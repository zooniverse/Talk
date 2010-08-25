class CollectionsController < ApplicationController
  respond_to :js, :only => :add
  
  def show
    @collection = Collection.find_by_zooniverse_id(params[:id])
    @focus = @collection
    @mentions = Discussion.mentioning(@collection)
    @comment = Comment.new
    @comments = @collection.conversation.comments
    
    @tags = @collection.tags
  end
  
  def new
    @collection = Collection.new
  end
  
  def edit
    @collection = Collection.find_by_zooniverse_id(params[:id])
  end
  
  def create
    @collection = Collection.new(params[:collection])
    @collection.user = current_zooniverse_user
    
    if @collection.save
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
      redirect_to root_url
    end
    
    if @collection.asset_ids.include? @asset
      flash[:notice] = I18n.t 'controllers.collections.already_added'
    else
      @collection.asset_ids << @asset.id
      flash[:notice] = I18n.t('controllers.collections.added') if @collection.save
    end
  end
end
