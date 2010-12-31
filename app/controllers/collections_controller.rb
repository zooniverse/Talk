class CollectionsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => [:show]
  before_filter CASClient::Frameworks::Rails::Filter, :only => [:new, :edit, :add]
  respond_to :js, :only => [:add, :remove, :browse]
  
  def show
    default_params :page => 1, :per_page => 10
    find_collection
    return not_found unless @collection
    
    @discussion = @collection.conversation
    @mentions = Discussion.mentioning(@collection)
    @comment = Comment.new
    @tags = @collection.keywords
    
    @discussion = @collection.conversation
    @discussion_id = @collection.conversation_id
    @comments = Comment.sort(:created_at.desc).where(:discussion_id => @discussion_id).paginate(:page => @page, :per_page => @per_page)
  end
  
  def new
    @collection = Collection.new
    set_options
  end
  
  def edit
    find_collection
    return not_found unless @collection
    return unless moderator_or_owner :can_modify?, @collection
    
    if @collection && @collection._type == "Collection"
      @kind = "Collection"
    elsif @collection && @collection._type == "LiveCollection"
      @kind = "Keyword Set"
      @keywords = @collection.tags
    end
  end
  
  def create
    if params[:collection_kind][:id] == "Keyword Set"
      @collection = LiveCollection.new(params[:collection])
      @collection.tags = params[:keyword].values
    elsif params[:collection_kind][:id] == "Collection"
      @collection = Collection.new(params[:collection])
    end
    
    @collection.user = current_zooniverse_user
    
    if @collection.save
      flash[:notice] = I18n.t 'controllers.collections.flash_create'
      redirect_to collection_path(@collection.zooniverse_id)
    else
      set_options
      flash_model_errors_on(@collection)
      render :action => 'new'
    end
  end
  
  def update
    find_collection
    return not_found unless @collection
    return unless moderator_or_owner :can_modify?, @collection
    
    if @collection.is_a?(LiveCollection)
      @collection.tags = params[:keyword].values
    end
    
    if @collection.update_attributes(params[:collection])
      flash[:notice] = I18n.t 'controllers.collections.flash_updated'
      redirect_to collection_path(@collection.zooniverse_id)
    else
      set_options
      flash_model_errors_on(@collection)
      render :action => 'edit'
    end
  end
  
  def destroy
    find_collection
    return not_found unless @collection
    return unless moderator_or_owner :can_destroy?, @collection
    
    if @collection.destroy
      flash[:notice] = I18n.t 'controllers.collections.flash_destroyed'
    else
      flash_model_errors_on(@collection)
    end
    
    redirect_to user_path(current_zooniverse_user)
  end
  
  def add
    find_collection
    return not_found unless @collection
    return unless moderator_or_owner :can_modify?, @collection
    @asset = Asset.find(params[:asset_id])
    
    if @collection.asset_ids.include? @asset.id
      flash[:alert] = I18n.t 'controllers.collections.already_added'
    else
      @collection.asset_ids << @asset.id
      
      if @collection.save
        flash[:notice] = I18n.t('controllers.collections.added')
        @success = true
      end
    end
  end
  
  def remove
    find_collection
    return not_found unless @collection
    return unless moderator_or_owner :can_modify?, @collection
    @asset = Asset.find_by_zooniverse_id(params[:asset_id])
    @collection.asset_ids.delete_if { |id| id == @asset.id }
    
    if @collection.save
      flash[:notice] = I18n.t('controllers.collections.removed')
    end
  end
  
  def browse
    @collections = Collection.trending(5)
    respond_with(@collections) do |format|
      format.js { render :partial => "browse" }
    end
  end
  
  private
  def find_collection
    if params[:id] =~ /^CMZS/
      @focus = @collection = Collection.find_by_zooniverse_id(params[:id])
    else
      @focus = @collection = LiveCollection.find_by_zooniverse_id(params[:id])
    end
  end
  
  def set_options
    if params[:object_id]
      @asset = Asset.find_by_zooniverse_id(params[:object_id])
      @kind = "Collection"
    elsif params[:keywords]
      @keywords = params[:keywords].is_a?(Array) ? params[:keywords] : params[:keywords].split
      @kind = "Keyword Set"
    elsif @collection && @collection.zooniverse_id
      @kind = (@collection.zooniverse_id =~ /^CMZS/) ? "Collection" : "Keyword Set"
    elsif params[:collection_kind]
      @kind = params[:collection_kind][:id]
      @keywords = params[:keyword].values if params[:keyword].is_a?(Hash)
    end
  end
end
