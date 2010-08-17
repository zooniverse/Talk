class CollectionsController < ApplicationController
  
  def show
    @collection = Collection.find_by_zooniverse_id(params[:id])
    @tags = ["Tag1", "Tag2", "Tag3"]
  end
  
end
