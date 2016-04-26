StatusbarUTF16OffsetView = require './statusbar-utf16-offset-view'
GoToUTF16OffsetView = require './go-to-utf16-offset-view'
{CompositeDisposable} = require 'atom'

module.exports = StatusbarUTF16Offset =
  config:
    statusBarFormat:
      type: 'string'
      title: 'UTF16 based Cursor Offset and Selected Length Format'
      description: 'Format for the utf16offset status bar element, where %O is the utf16 offset number and %L is the selected length number'
      default: '{%O, %L}'

  statusbarUTF16OffsetView: null
  goToUTF16Offset: null

  activate: ->
    @goToUTF16Offset = GoToUTF16OffsetView.activate()

  deactivate: ->
    @statusbarUTF16OffsetView?.destroy()
    @statusbarUTF16OffsetView = nil

  consumeStatusBar: (statusBar) ->
    @statusbarUTF16OffsetView = new StatusbarUTF16OffsetView
    @statusbarUTF16OffsetView.initialize()
    statusBar.addLeftTile(item: @statusbarUTF16OffsetView, priority: 1)
