class AssetsController < ApplicationController
  
  def show
    @asset = Asset.find_by_zooniverse_id(params[:id])
    @tags = ["Tag1", "Tag2", "Tag3"]
    
    @comments = @asset.conversation.comments
  end
  
end
