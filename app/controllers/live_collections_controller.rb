class LiveCollectionsController < ApplicationController

  
  def new
    @collection = LiveCollection.new
  end
  
end
