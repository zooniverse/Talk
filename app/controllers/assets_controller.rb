class AssetsController < ApplicationController
  
  def show
    @asset = Asset.find_by_zooniverse_id(params[:id])
    @tags = ["Tag1", "Tag2", "Tag3"]
    
    if @asset.conversation.nil?
      @comments = []
    else
      @comments = @asset.conversation.comments
    end
  
    
  end
  
end
