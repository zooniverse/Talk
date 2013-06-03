Controller = require('spine').Controller

class DefaultGroupViewer extends Controller
  @imageIn: (location) -> location?.standard
  @groupTitle: (group) -> "Group #{ group.name }"
  @description: (group) -> group.description
  
  group: null
  className: 'group-viewer'
  template: require('views/groups/viewer')
  
  constructor: ->
    super
    @render()
  
  render: ->
    @buildPages()
    @subjectPage = 1
    @html @template @
    @paginationLinks()
  
  destroy: ->
    @el.off()
  
  buildPages: ->
    subjects = @group.subjects
    @group.subjects = { }
    
    if subjects?.length > 0
      page = 0
      for index in [0 .. subjects.length] by 5
        @group.subjects[page += 1] = subjects.slice index, index + 5
      
      @group.subjectsCount = subjects.length
      @group.subjectPages = page
    else
      @group.subjectsCount = 0
      @group.subjectPages = 0
  
  paginationLinks: =>
    return unless @group.subjectPages > 1
    @el.find('.pages').pagination
      cssStyle: 'compact-theme'
      items: @group.subjectsCount
      itemsOnPage: 5
      onPageClick: @paginateSubjects
  
  paginateSubjects: (page, ev) =>
    ev.preventDefault()
    @el.find('.list').html require('views/collections/subject_list')(subjects: @group.subjects[page])
    @preloadPage number for number in [page - 2 .. page + 2]
  
  preloadPage: (number) =>
    return unless @group.subjects[number]
    for subject in @group.subjects[number]
      img = new Image
      img.src = require('controllers/subject_viewer').imageIn(subject?.location)

module.exports = DefaultGroupViewer
