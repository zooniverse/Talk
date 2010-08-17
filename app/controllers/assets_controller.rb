class AssetsController < ApplicationController
  
  def show
    @asset = Asset.first
  end
  
end
