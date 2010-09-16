class SearchController < ApplicationController
  respond_to :html, :js
  
  def index 
    @search = params[:search] ? params[:search] : ""
    @page = params[:page] ? params[:page].to_i : 1
    @per_page = params[:per_page] ? params[:per_page].to_i : 10
    @for = params[:for] ? params[:for].underscore.pluralize : "comments"
    @for.sub('live_collections', 'collections')
    
    parse_keywords
    search_terms = @keywords || @search
    
    case @for
    when 'collections'
      selector = { :criteria => { :$or => [{ :focus_type => "Collection" }, { :focus_type => "LiveCollection" }] } }
      selector[:field] = :tags unless @keywords.nil?
      @collections = focus_results(search_terms, selector)
    when 'comments'
      selector = { :per_page => @per_page, :page => @page }
      
      unless @keywords.nil?
        selector[:field] = :tags
        search_terms.join(' ')
      end
      
      @comments = @results = Comment.search(search_terms, selector)
    when 'objects'
      if @keywords.nil?
        @objects = focus_results(search_terms, :focus_type => "Asset")
      else
        @results = @objects = Asset.with_keywords(search_terms, :page => @page, :per_page => @per_page)
      end
    end
  end
  
  def live_collection_results
    @keywords = params[:keywords]
    @assets = Asset.with_keywords(@keywords.split(','), :per_page => 49)
  end
  
  def parse_keywords
    if @search =~ /^keywords:/
      @keywords = @search.gsub(/#|keywords:|,/, ' ').split.collect{ |tag| tag.strip.downcase }
    end
  end
  
  def focus_results(search_terms, options)
    return if search_terms.blank?
    options = { :per_page => @per_page, :page => @page }.merge(options)
    @results = {}
    
    begin
      @page = options[:page]
      @comments = Comment.search search_terms, options
      @comments.each{ |comment| @results[comment.focus] = 1 }
      options[:page] += 1
    end while @results.length < @per_page && @comments.next_page
    
    @results = @results.keys
  end
end
