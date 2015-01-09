{View} = require 'atom-space-pen-views'
{EditorView} = require 'atom'

module.exports =
class WebView extends View
  @content: (params) ->
    @div class: 'webview-pane', =>
      @div class: 'webview-url', =>
        @subview 'editor', new EditorView(mini: true)
      @div class: 'webview-buttons-container', =>
        @button class: 'webview-reload', style: 'border-radius: 0', 'reload'
        @button class: 'webview-open-devtools', style: 'border-radius: 0', 'devtools'
      @div class:'webview-container', style: 'height: 100%', =>
        @tag 'webview'

  constructor: ({@fpath, @protocol}) ->
    super

  getTitle: -> 'webview'

  openUri: ->
    return unless @canOpenUri()

    uri = @protocol + '://' + @fpath
    unless @webview.src
      @webview.src = uri
    else
      if uri is @_lastUri
        @webview.executeJavaScript "location.reload()"
      else
        @webview.executeJavaScript "location.href='#{uri}'"
    @_lastUri = uri

  canOpenUri: ->
    not (@protocol is 'file' and @fpath.indexOf('.html') is -1)

  update: ->
    [@protocol, @fpath] = @editor.getText().split('://')

  attached: ->
    webview = @webview = @element.querySelector('webview')
    @on 'click', '.webview-reload', =>
      @update()
      @openUri()

    @on 'click', '.webview-open-devtools', =>
      webview.openDevTools()

    @on 'core:confirm', =>
      @update()
      @openUri()

    unless @canOpenUri()
      @fpath = 'localhost'
      @protocol = 'http'

    uri = @protocol + '://' + @fpath
    @editor.setText uri
    @openUri()

  open: ->

  destroy: ->
    @element.remove()
