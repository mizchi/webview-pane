WebviewPane = require '../lib/webview-pane'

describe "WebviewPane", ->
  [workspaceElement, activationPromise] = []
  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('webview-pane')

  describe "when the webview-pane:toggle event is triggered", ->
    it "should show webview"
