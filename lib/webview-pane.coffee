{CompositeDisposable} = require 'atom'
url = require 'url'

WebView = require './webview'

module.exports = WebviewPane =
  webviewPaneView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'webview-pane:preview': => @preview()
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

  preview: ->
    @addWebView()

  addWebView: ->
    uri = 'webview://preview'+atom.workspace.getActiveEditor().getPath()
    previousActivePane = atom.workspace.getActivePane()
    atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (view) ->
      previousActivePane.activate()
