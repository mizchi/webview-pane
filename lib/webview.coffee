{View} = require 'atom-space-pen-views'
module.exports =
class WebView extends View
  @content: (params) ->
    @div class: 'webview-pane', =>
      @div class: 'webview-buttons-container', =>
        @button class: 'webview-reload', 'reload'
        @button class: 'webview-open-devtools', 'devtools'
      @div class:'webview-container', style: 'height: 100%', =>
        @tag 'webview', src: "file://#{params.fpath}"
  constructor: ({@fpath}) ->
    super
  getTitle: -> 'web view:'+@fpath
  attached: ->
    webview =@element.querySelector('webview')
    @on 'click', '.webview-reload', =>
      # webview.reloadIgnoringCache()
      webview.executeJavaScript 'location.reload()'
    @on 'click', '.webview-open-devtools', =>
      webview.openDevTools()
  destroy: ->
    @element.remove()
