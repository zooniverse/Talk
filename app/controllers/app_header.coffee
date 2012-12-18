{Controller} = require 'spine'
User = require 'zooniverse/lib/models/user'
{ pluralize } = require 'lib/util'
template = require 'views/app_header'

class AppHeader extends Controller
  tagName: 'header'
  className: 'app-header'

  events:
    'submit form[name="sign-in"]': 'onSignInSubmit'
    'submit form[name="search"]': 'onSubmitSearch'
    'click .search.button': 'onClickSearchButton'
    'click button[name="sign-out"]': 'onClickSignOut'

  elements:
    '.sign-in': 'signInContainer'
    '.message-counter': 'messageCounter'
    '.error': 'errorContainer'
    '.search.button': 'searchButton'
    '.search.dropdown': 'searchDropdown'
    'form[name="search"] input[name="query"]': 'searchQueryInput'

  constructor: ->
    super
    @html template
    
    User.bind 'message-count', @updateMessageCounter
    User.bind 'sign-in', @onUserSignIn
    User.bind 'sign-in-error', @onSignInError
    @onUserSignIn() if User.current

    $(document).on 'click', @onDocumentClick

  onUserSignIn: =>
    signedIn = User.current?
    @html template
    @el.toggleClass 'signed-in', signedIn
    @signInContainer.toggle not signedIn

  onSignInError: (error) =>
    @errorContainer.html error
    @errorContainer.show()

  onSignInSubmit: (e) ->
    e.preventDefault()

    @errorContainer.hide()
    @errorContainer.empty()

    username = @el.find('input[name="username"]').val()
    password = @el.find('input[name="password"]').val()
    User.login {username, password} if username and password

  onClickSearchButton: ->
    @searchDropdown.toggle()

  onSubmitSearch: (e) ->
    e.preventDefault();
    @searchDropdown.hide()
    location.hash = "/search/#{@searchQueryInput.val()}"

  onClickSignOut: ->
    User.logout()

  onDocumentClick: ({target}) =>
    isDropdown = @searchDropdown.is target
    isButton = @searchButton.is target
    inDropdown = @searchDropdown.has(target).length isnt 0
    inButton = @searchButton.has(target).length isnt 0
    @searchDropdown.hide() unless isDropdown or isButton or inButton or inDropdown
  
  updateMessageCounter: (count) =>
    @messageCounter.attr 'data-count', count
    if count > 0
      label = pluralize count, 'new message', 'new messages'
      @messageCounter.attr 'title', "#{ count } #{ label }"
    else
      @messageCounter.attr 'title', 'No new messages'

module.exports = AppHeader
