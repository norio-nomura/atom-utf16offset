{Range} = require 'atom'
{$, TextEditorView, View}  = require 'atom-space-pen-views'

module.exports =
class GoToUTF16OffsetView extends View
  @activate: -> new GoToUTF16OffsetView

  @content: ->
    @div class: 'go-to-utf16-offset', =>
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'message', outlet: 'message'

  initialize: ->
    @panel = atom.workspace.addModalPanel(item: this, visible: false)

    atom.commands.add 'atom-text-editor', 'go-to-utf16-offset:toggle', =>
      @toggle()
      false

    @miniEditor.on 'blur', => @close()
    atom.commands.add @miniEditor.element, 'core:confirm', => @confirm()
    atom.commands.add @miniEditor.element, 'core:cancel', => @close()

    @miniEditor.getModel().onWillInsertText ({cancel, text}) ->
      cancel() unless text.match(/[0-9,]/)

  toggle: ->
    if @panel.isVisible()
      @close()
    else
      @open()

  close: ->
    return unless @panel.isVisible()

    miniEditorFocused = @miniEditor.hasFocus()
    @miniEditor.setText('')
    @panel.hide()
    @restoreFocus() if miniEditorFocused

  confirm: ->
    lineNumber = @miniEditor.getText()
    editor = atom.workspace.getActiveTextEditor()

    @close()

    return unless editor? and lineNumber.length

    range = editor.getSelectedBufferRange()
    [utf16offset, length] = lineNumber.split(/,+/)
    if utf16offset?.length > 0
      # Offset was specified
      utf16offset = parseInt(utf16offset)
    else
      # UTF16Offset was not specified, so assume we will be at the same utf16offset
      # as where the cursor currently is (no change)
      utf16offset = editor.getBuffer().characterIndexForPosition(range.start)

    if length?.length > 0
      # Length number was specified
      length = parseInt(length)
    else
      length = 0

    start = editor.getBuffer().positionForCharacterIndex(utf16offset)
    end = editor.getBuffer().positionForCharacterIndex(utf16offset + length)
    editor.scrollToBufferPosition(start, center: true)
    range = new Range(start, end)
    editor.setSelectedBufferRange(range)

  restoreFocus: ->
    atom.views.getView(atom.workspace).focus()

  open: ->
    return if @panel.isVisible()

    if editor = atom.workspace.getActiveTextEditor()
      @panel.show()
      @message.text("Enter utf16 based 'offset,length' to go to")
      @miniEditor.focus()
