Api = require 'zooniverse/lib/api'
SubStack = require 'lib/sub_stack'
FocusPage = require 'controllers/focus_page'
template = require 'views/subjects/show'

class Show extends FocusPage
  template: template
  className: "#{FocusPage::className} subject page"
  focusType: 'subjects'
  
  elements:
    '.comment-form': 'commentForm'
    'ul.comments': 'commentList'
    '.focus .collect-this': 'collectThis'
    '.focus .collection-list': 'collectionList'
  
  events:
    'submit .comment-form': 'submitComment'
    'click .new-discussion button': 'startDiscussion'
    'click .focus .collect-this': 'showCollectionList'
    'click .focus .collection-list .collection': 'collectSubject'
  
  showCollectionList: (ev) =>
    ev.preventDefault()

    @collectionList.addClass 'loading'
    @collectionList.toggle()

    Api.get "#{ @rootUrl() }/users/collection_list", (results) =>
      @collectionList.removeClass 'loading'
      @collectionList.html require('views/users/collection_list') subject: @data, collections: results
  
  collectSubject: ({ target }) =>
    id = $(target).data 'id'
    Api.post "#{ @rootUrl() }/collections/#{ id }/add_subject", subject_id: @data.zooniverse_id, (results) =>
      @collectionList.html ''
      @collectionList.hide()
      @collectThis.text 'Collected'


class Subjects extends SubStack
  controllers:
    show: Show
  
  routes:
    '/subjects/:focusId': 'show'


module.exports = Subjects
