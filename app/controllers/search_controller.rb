class SearchController < ApplicationController
  respond_to :html, :js
  
  def index 
    @search = params[:search]
    @page = params[:page] ? params[:page].to_i : 1
    @per_page = params[:per_page] ? params[:per_page].to_i : 10
    
    @comments = Comment.search @search, :limit => 1_000, :per_page => @per_page, :page => @page, :from_mongo => true
    group_by_type(@comments)
  end
  
  def group_by_type(search_results)
    grouped = {}
    
    search_results.each do |result|
      kind = result.focus_type || "Discussion"
      grouped[kind] ||= []
      grouped[kind] << (result.focus || result.discussion)
    end
    
    grouped.each_pair do |kind, list|
      instance_variable_set("@#{kind.underscore.pluralize}", list)
    end
  end
end
