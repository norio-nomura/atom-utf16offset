GoToUTF16OffserView = require '../lib/go-to-utf16-offset-view'

describe 'GoToUTF16Offset', ->
  [goToUTF16Offset, editor, editorView] = []

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open('sample.js')

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)
      goToUTF16Offset = GoToUTF16OffserView.activate()
      editor.setCursorBufferPosition([1, 0])

  describe "when go-to-utf16-offset:toggle is triggered", ->
    it "adds a modal panel", ->
      expect(goToUTF16Offset.panel.isVisible()).toBeFalsy()
      atom.commands.dispatch editorView, 'go-to-utf16-offset:toggle'
      expect(goToUTF16Offset.panel.isVisible()).toBeTruthy()

  describe "when entering a line number", ->
    it "only allows 0-9 and the comma character to be entered in the mini editor", ->
      expect(goToUTF16Offset.miniEditor.getText()).toBe ''
      goToUTF16Offset.miniEditor.getModel().insertText 'a'
      expect(goToUTF16Offset.miniEditor.getText()).toBe ''
      goToUTF16Offset.miniEditor.getModel().insertText ','
      expect(goToUTF16Offset.miniEditor.getText()).toBe ','
      goToUTF16Offset.miniEditor.getModel().setText ''
      goToUTF16Offset.miniEditor.getModel().insertText '4'
      expect(goToUTF16Offset.miniEditor.getText()).toBe '4'

  describe "when entering a utf16 offset number and length number", ->
    it "selects the text from utf16 offset number to the length specified", ->
      expect(goToUTF16Offset.miniEditor.getText()).toBe ''
      goToUTF16Offset.miniEditor.getModel().insertText '3,14'
      atom.commands.dispatch(goToUTF16Offset.miniEditor.element, 'core:confirm')
      expect(editor.getSelectedBufferRange()).toEqual [[0, 3], [0, 17]]

  describe "when entering a utf16 offset number greater than the number in the buffer", ->
    it "moves the cursor position to the end character of the last line", ->
      atom.commands.dispatch editorView, 'go-to-utf16-offset:toggle'
      expect(goToUTF16Offset.panel.isVisible()).toBeTruthy()
      expect(goToUTF16Offset.miniEditor.getText()).toBe ''
      goToUTF16Offset.miniEditor.getModel().insertText '412'
      atom.commands.dispatch(goToUTF16Offset.miniEditor.element, 'core:confirm')
      expect(goToUTF16Offset.panel.isVisible()).toBeFalsy()
      expect(editor.getCursorBufferPosition()).toEqual [13, 0]

  describe "when entering a length number greater than the number in the buffer", ->
    it "selects from cursor position to the end character of the last line", ->
      atom.commands.dispatch editorView, 'go-to-utf16-offset:toggle'
      expect(goToUTF16Offset.panel.isVisible()).toBeTruthy()
      expect(goToUTF16Offset.miniEditor.getText()).toBe ''
      goToUTF16Offset.miniEditor.getModel().insertText ',412'
      atom.commands.dispatch(goToUTF16Offset.miniEditor.element, 'core:confirm')
      expect(goToUTF16Offset.panel.isVisible()).toBeFalsy()
      expect(editor.getSelectedBufferRange()).toEqual [[1, 0], [13, 0]]

  describe "when core:confirm is triggered", ->
    describe "when a utf16 offset number has been entered", ->
      it "moves the cursor to the utf16 offset character", ->
        goToUTF16Offset.miniEditor.getModel().insertText '3'
        atom.commands.dispatch(goToUTF16Offset.miniEditor.element, 'core:confirm')
        expect(editor.getCursorBufferPosition()).toEqual [0, 3]

  describe "when no utf16 offset number has been entered", ->
    it "closes the view and does not update the cursor position", ->
      atom.commands.dispatch editorView, 'go-to-utf16-offset:toggle'
      expect(goToUTF16Offset.panel.isVisible()).toBeTruthy()
      atom.commands.dispatch(goToUTF16Offset.miniEditor.element, 'core:confirm')
      expect(goToUTF16Offset.panel.isVisible()).toBeFalsy()
      expect(editor.getCursorBufferPosition()).toEqual [1, 0]

  describe "when no utf16 offset number has been entered, but a length number has been entered", ->
    it "selects from the current utf16 offset to the length", ->
      atom.commands.dispatch editorView, 'go-to-utf16-offset:toggle'
      expect(goToUTF16Offset.panel.isVisible()).toBeTruthy()
      goToUTF16Offset.miniEditor.getModel().insertText '111'
      atom.commands.dispatch(goToUTF16Offset.miniEditor.element, 'core:confirm')
      expect(goToUTF16Offset.panel.isVisible()).toBeFalsy()
      expect(editor.getCursorBufferPosition()).toEqual [3, 9]
      atom.commands.dispatch editorView, 'go-to-utf16-offset:toggle'
      expect(goToUTF16Offset.panel.isVisible()).toBeTruthy()
      goToUTF16Offset.miniEditor.getModel().insertText ',19'
      atom.commands.dispatch(goToUTF16Offset.miniEditor.element, 'core:confirm')
      expect(goToUTF16Offset.panel.isVisible()).toBeFalsy()
      expect(editor.getSelectedBufferRange()).toEqual [[3, 9], [3, 28]]

  describe "when core:cancel is triggered", ->
    it "closes the view and does not update the cursor position", ->
      atom.commands.dispatch editorView, 'go-to-utf16-offset:toggle'
      expect(goToUTF16Offset.panel.isVisible()).toBeTruthy()
      atom.commands.dispatch(goToUTF16Offset.miniEditor.element, 'core:cancel')
      expect(goToUTF16Offset.panel.isVisible()).toBeFalsy()
      expect(editor.getCursorBufferPosition()).toEqual [1, 0]
