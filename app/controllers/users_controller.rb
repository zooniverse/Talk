class UsersController < ApplicationController
  def show
    @user = User.find_by_zooniverse_user_id(params[:id])
    if (@user.nil?)
      logger.info("// user is nil")
    end
        
    @user = User.all.last
    
  end

end
