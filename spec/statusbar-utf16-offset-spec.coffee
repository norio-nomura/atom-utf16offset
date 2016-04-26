describe "StatusbarUTF16Offset", ->
  [statusBar, workspaceElement, dummyView] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    dummyView = document.createElement("div")
    atom.packages.activatePackage('status-bar')
    atom.packages.activatePackage('utf16offset')
    statusBar = null

    runs ->
      statusBar = workspaceElement.querySelector("status-bar")

  describe "statusbarUTF16Offset", ->
    [editor, buffer, statusbarUTF16Offset] = []

    beforeEach ->
      waitsForPromise ->
        atom.workspace.open('sample.js')

      runs ->
        [statusbarUTF16Offset] = statusBar.getLeftTiles()
          .map (tile) -> tile.getItem()
          .filter (item) -> item.getAttribute("is") == 'statusbar-utf16-offset'
        editor = atom.workspace.getActiveTextEditor()
        buffer = editor.getBuffer()

    describe "when associated with an unsaved buffer", ->
      it "displays the buffer utf16offset", ->
        waitsForPromise ->
          atom.workspace.open()

        runs ->
          atom.views.performDocumentUpdate()
          expect(statusbarUTF16Offset.textContent).toBe '{0, 0}'

    describe "when the associated editor's statusbar position changes", ->
      it "updates the utf16offset in the status bar", ->
        jasmine.attachToDOM(workspaceElement)
        editor.setCursorScreenPosition([1, 2])
        atom.views.performDocumentUpdate()
        expect(statusbarUTF16Offset.textContent).toBe '{32, 0}'

    describe "when the associated editor's selection changes", ->
      it "updates the utf16offset and length in the status bar", ->
        jasmine.attachToDOM(workspaceElement)

        editor.setSelectedBufferRange([[0, 0], [0, 0]])
        atom.views.performDocumentUpdate()
        expect(statusbarUTF16Offset.textContent).toBe '{0, 0}'

        editor.setSelectedBufferRange([[0, 0], [0, 2]])
        atom.views.performDocumentUpdate()
        expect(statusbarUTF16Offset.textContent).toBe '{0, 2}'

        editor.setSelectedBufferRange([[0, 0], [1, 30]])
        atom.views.performDocumentUpdate()
        expect(statusbarUTF16Offset.textContent).toBe '{0, 60}'

    describe "when the active pane item does not implement getCursorBufferPosition()", ->
      it "hides the utf16offset view in status bar", ->
        jasmine.attachToDOM(workspaceElement)
        atom.workspace.getActivePane().activateItem(dummyView)
        atom.views.performDocumentUpdate()
        expect(statusbarUTF16Offset).toBeHidden()

    describe 'the utf16 offset tile', ->
      beforeEach ->
        atom.config.set('utf16offset.statusBarFormat', 'foo %O bar %L')

      it 'respects a format string', ->
        jasmine.attachToDOM(workspaceElement)
        editor.setCursorScreenPosition([1, 2])
        atom.views.performDocumentUpdate()
        expect(statusbarUTF16Offset.textContent).toBe 'foo 32 bar 0'

      it 'updates when the configuration changes', ->
        jasmine.attachToDOM(workspaceElement)
        editor.setCursorScreenPosition([1, 2])
        atom.views.performDocumentUpdate()
        expect(statusbarUTF16Offset.textContent).toBe 'foo 32 bar 0'

        atom.config.set('utf16offset.statusBarFormat', 'baz %O quux %L')
        atom.views.performDocumentUpdate()
        expect(statusbarUTF16Offset.textContent).toBe 'baz 32 quux 0'

      describe "when clicked", ->
        it "triggers the go-to-utf16-offset toggle event", ->
          eventHandler = jasmine.createSpy('eventHandler')
          atom.commands.add('atom-text-editor', 'go-to-utf16-offset:toggle', eventHandler)
          statusbarUTF16Offset.click()
          expect(eventHandler).toHaveBeenCalled()
