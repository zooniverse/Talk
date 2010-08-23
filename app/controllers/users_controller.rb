class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    
    if (@user.nil?)
      logger.info("// user is nil")
    end
  end
end
