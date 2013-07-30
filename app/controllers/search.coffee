Api = require 'zooniverse/lib/api'
{ Controller } = require 'spine'
{ project } = require 'lib/config'
{ equalObjects } = require 'lib/util'
SubStack = require 'lib/sub_stack'
Params = require 'lib/params'

class Index extends Controller
  className: 'page'
  template: require('views/search/index')
  
  elements:
    'form.search': 'searchForm'
    'form.search .text input[name="text"]': 'searchBox'
    'form.search .category :checkbox': 'categoryCheck'
    'form.search .tags .facets .available': 'availableTagFacets'
    'form.search .tags .facets .selected': 'selectedTagFacets'
    '.results': 'results'
  
  events:
    'submit form.search': 'search'
    'click form.search .type :checkbox': 'checkFacets'
    'click form.search .category :checkbox': 'checkFacets'
    'click form.search .tags :checkbox': 'checkTags'
  
  activate: (params) ->
    return unless params
    super
    query = @parseParams()
    query.per_page = 10
    @queryTags = query.tags or { }
    @render()
    @runQuery query
    @lastQuery or=
      text: ''
  
  parseParams: =>
    @params = Params.parse()
    if @params.text or @params.kind or @params.category or @params.tags
      @params
    else
      false
  
  render: =>
    @html @template(@)
  
  paginationLinks: =>
    $('.results .pages', @el).pagination
      cssStyle: 'compact-theme'
      currentPage: @searchResults.page
      items: @searchResults.total
      itemsOnPage: 10
      onPageClick: (page) =>
        query = $.extend true, { }, @lastQuery
        query.page = page
        @runQuery query
  
  search: (ev) =>
    ev?.preventDefault()
    
    query =
      text: "#{ @searchBox.val().trim().replace(/\s+/, ' ') }"
    
    query.kind = @queryType if @queryType
    query.category = @queryCategory if @queryCategory
    query.tags = $.extend true, { }, @queryTags
    
    if @searching
      @pending = query
    else
      @runQuery query
  
  runQuery: (query) =>
    return unless @hasChanged query
    return if @searching
    @searching = true
    @lastQuery = query
    
    retries = 0
    
    Api.get "/projects/#{ project }/talk/search", query, (results) =>
      @searchResults = results
      @results.html require('views/search/results')(results)
      @paginationLinks()
      @setFacetCounts results
      @searching = false
      @runQuery(@pending) if @pending
      @pending = null
    , =>
      @searching = false
      @lastQuery = null
      
      retries += 1
      if retries < 3
        @runQuery @pending or query
        @pending = null
  
  checkFacets: (ev) =>
    target = $(ev.target)
    type = target.closest('section').attr 'class'
      
    if target.is(':checked')
      $(".#{ type } :checkbox:not(:checked)").each -> $(@).attr('disabled', 'disabled')
      @queryCategory = target.val() if type is 'category'
      @queryType = target.val() if type is 'type'
    else
      $(".#{ type } :checkbox:not(:checked)").each -> $(@).removeAttr('disabled')
      @queryCategory = null if type is 'category'
      @queryType = null if type is 'type'
    
    @search()
  
  checkTags: (ev) =>
    target = $(ev.target)
    facet = target.closest('.facet').remove()
    
    if target.is(':checked')
      facet.find('.facet-count').remove()
      @selectedTagFacets.append facet
      @queryTags[target.val()] = true
    else
      delete @queryTags[target.val()]
    
    @search()
  
  setFacetCounts: (results) =>
    @el.find('label .facet-count').attr 'data-count', 0
    
    for key, result of results.facets
      for facet in (result?.terms or [])
        facetEl = $("section.#{ key } .facet[data-facet-type='#{ facet.term }']")
        el = facetEl.find '.facet-count'
        el.attr 'data-count', facet.count
      
      @el.find("section.#{ key } label .facet-count").each (i, el) ->
        input = $(el).closest('.facet').children 'input'
        if $(el).attr('data-count') > 0
          input.removeAttr 'disabled'
        else if key is 'tags' and input.is(':checked')
          input.attr 'disabled', 'disabled'
        else if input.is(':checked')
          input.removeAttr 'checked'
          input.attr 'disabled', 'disabled'
        else
          input.attr 'disabled', 'disabled'
    
    @buildTagsFrom results
  
  buildTagsFrom: (results) =>
    facets = results.facets.tags?.terms or []
    @availableTagFacets.html ''
    
    for facet in facets
      continue if @queryTags[facet.term]
      @availableTagFacets.append require('views/search/facet') term: facet.term, label: facet.term, count: facet.count
  
  hasChanged: (query) =>
    return false unless query
    return true unless @lastQuery
    not equalObjects query, @lastQuery


class Search extends SubStack
  controllers:
    index: Index
  
  routes:
    '/search*query': 'index'
  
  default: 'index'
  className: 'stack search'


module.exports = Search
