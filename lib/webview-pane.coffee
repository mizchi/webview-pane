WebviewPaneView = require './webview-pane-view'
{CompositeDisposable} = require 'atom'
url = require 'url'

{$, $$$, ScrollView, View} = require 'atom-space-pen-views'
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
  getTitle: -> 'webview:'+@fpath
  attached: ->
    webview =@element.querySelector('webview')
    @on 'click', '.webview-reload', =>
      # webview.reloadIgnoringCache()
      webview.executeJavaScript 'location.reload()'
    @on 'click', '.webview-open-devtools', =>
      webview.openDevTools()

module.exports = WebviewPane =
  webviewPaneView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @webviewPaneView = new WebviewPaneView(state.webviewPaneViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @webviewPaneView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'webview-pane:toggle': => @toggle()

    atom.workspace.addOpener (uriToOpen) ->
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        return
      return unless protocol is 'webview:'

      try
        pathname = decodeURI(pathname) if pathname
      catch error
        return
      new WebView fpath: pathname

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @webviewPaneView.destroy()

  serialize: ->
    webviewPaneViewState: @webviewPaneView.serialize()

  toggle: ->
    @addWebView()

  addWebView: ->
    uri = 'webview://preview'+atom.workspace.getActiveEditor().getPath()
    previousActivePane = atom.workspace.getActivePane()
    atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (view) ->
      previousActivePane.activate()
