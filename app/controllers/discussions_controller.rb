class DiscussionsController < ApplicationController
  def show
    @discussion = Discussion.find_by_zooniverse_id(params[:id])
  end
end
