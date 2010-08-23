class AdminController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
  before_filter :require_privileged_user, :only => :index
  
  def index
  end
end
