{Controller} = require 'spine'
User = require 'zooniverse/lib/models/user'

template = require 'views/app_header'

class AppHeader extends Controller
  tagName: 'header'
  className: 'app-header'

  events:
    'submit form[name="sign-in"]': 'onSignInSubmit'

  elements:
    '.sign-in': 'signInContainer'
    '.error': 'errorContainer'

  constructor: ->
    super
    @html template

    User.bind 'sign-in', @onUserSignIn
    User.bind 'sign-in-error', @onSignInError
    @onUserSignIn() if User.current

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

module.exports = AppHeader
