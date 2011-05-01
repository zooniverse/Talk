# Groups
class GroupsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => [:show]
  
  # Show the Group
  def show
    default_params :page => 1, :per_page => 10
    @focus = @group = Group.find_by_zooniverse_id(params[:id])
    return not_found unless @group
    @page_title = @group.zooniverse_id
    
    @discussion = @group.conversation
    @mentions = Discussion.mentioning(@group)
    @comment = Comment.new
    @tags = @group.keywords
    
    @discussion = @group.conversation
    @discussion_id = @group.conversation_id
    @comments = Comment.sort(:created_at.desc).where(:discussion_id => @discussion_id).paginate(:page => @page, :per_page => @per_page)
  end
end
