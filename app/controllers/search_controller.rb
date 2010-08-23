class SearchController < ApplicationController
  
  def index 
    @text=params[:text]
    @results= Comment.search @text, :from_mongo=>true if(@text)
    logger.info(params)
    logger.info(@results)
  end
  
end
