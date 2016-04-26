{Disposable} = require 'atom'

class StatusbarUTF16OffsetView extends HTMLElement
  initialize: ->
    @viewUpdatePending = false

    @classList.add('statusbar-utf16-offset', 'inline-block')
    @goToUTF16OffsetLink = document.createElement('a')
    @goToUTF16OffsetLink.classList.add('inline-block')
    @goToUTF16OffsetLink.href = '#'
    @appendChild(@goToUTF16OffsetLink)

    @formatString = atom.config.get('utf16offset.statusBarFormat') ? '{%O, %L}'
    @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem (activeItem) =>
      @subscribeToActiveTextEditor()

    @subscribeToConfig()
    @subscribeToActiveTextEditor()

    @tooltip = atom.tooltips.add(this, title: ->
      "utf16 offset: #{@utf16offset}, length: #{@length}")

    @handleClick()

  destroy: ->
    @activeItemSubscription.dispose()
    @cursorSubscription?.dispose()
    @selectionSubscription?.dispose()
    @tooltip.dispose()
    @clickSubscription.dispose()
    @updateSubscription?.dispose()

  subscribeToActiveTextEditor: ->
    @cursorSubscription?.dispose()
    @cursorSubscription = @getActiveTextEditor()?.onDidChangeCursorPosition ({cursor}) =>
      return unless cursor is @getActiveTextEditor().getLastCursor()
      @updateUTF16Offset()
    @selectionSubscription?.dispose()
    @selectionSubscription = @getActiveTextEditor()?.onDidChangeSelectionRange ({selection}) =>
      return unless selection is @getActiveTextEditor().getLastSelection()
      @updateUTF16Offset()
    @updateUTF16Offset()

  subscribeToConfig: ->
    @configSubscription?.dispose()
    @configSubscription = atom.config.observe 'utf16offset.statusBarFormat', (value) =>
      @formatString = value ? '{%O, %L}'
      @updateUTF16Offset()

  handleClick: ->
    clickHandler = => atom.commands.dispatch(atom.views.getView(@getActiveTextEditor()), 'go-to-utf16-offset:toggle')
    @addEventListener('click', clickHandler)
    @clickSubscription = new Disposable => @removeEventListener('click', clickHandler)

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  updateUTF16Offset: ->
    return if @viewUpdatePending

    @viewUpdatePending = true
    @updateSubscription?.dispose()
    @updateSubscription = atom.views.updateDocument =>
      @viewUpdatePending = false
      if range = @getActiveTextEditor()?.getSelectedBufferRange()
        buffer = @getActiveTextEditor()?.getBuffer()
        @utf16offset = buffer.characterIndexForPosition(range.start)
        @length = buffer.characterIndexForPosition(range.end) - @utf16offset
        @goToUTF16OffsetLink.textContent = @formatString.replace('%O', @utf16offset).replace('%L', @length)
        @classList.remove('hide')
      else
        @goToUTF16OffsetLink.textContent = ''
        @classList.add('hide')

module.exports = document.registerElement('statusbar-utf16-offset', prototype: StatusbarUTF16OffsetView.prototype, extends: 'div')
