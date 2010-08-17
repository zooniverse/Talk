class AssetsController < ApplicationController
  
  def show
    @asset = Asset.find_by_zooniverse_id(params[:id])
  end
  
end
