class SearchController < ApplicationController
  respond_to :html, :js
  
  def index 
    @search = params[:search] ? params[:search] : ""
    @page = params[:page] ? params[:page].to_i : 1
    @per_page = params[:per_page] ? params[:per_page].to_i : 10
    
    if @search =~ /^keywords:/i
      tags = @search.sub(/^keywords:/i, '').gsub(/#|,/, ' ').split.collect{ |tag| tag.strip.downcase }.join(' ')
      @comments = Comment.search tags, :field => :tags, :per_page => @per_page, :page => @page
      group_by_type(@comments)
      @assets = Asset.with_keywords tags.split, :page => @page, :per_page => @per_page
    else
      @comments = Comment.search @search, :per_page => @per_page, :page => @page
      group_by_type(@comments)
    end
  end
  
  def group_by_type(search_results)
    grouped = {}
    grouped["Discussion"] = []
    
    search_results.each do |result|
      grouped["Discussion"] << result.discussion
      
      kind = result.focus_type
      if kind
        grouped[kind] ||= []
        grouped[kind] << result.focus
      end
    end
    
    grouped.each_pair do |kind, list|
      instance_variable_set("@#{kind.underscore.pluralize}", list.uniq)
    end
  end
  
  def live_collection_results
    @keywords = params[:keywords]
    @assets = Asset.with_keywords(@keywords.split(','), :per_page => 49)
  end
end
