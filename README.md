# utf16offset package for [Atom](https://atom.io) [![Build Status](https://travis-ci.org/norio-nomura/atom-utf16offset.svg?branch=master)](https://travis-ci.org/norio-nomura/atom-utf16offset)

Display cursor position as the UTF16 based offset from the beginning of edit buffer in status-bar.

![A screenshot of your package](https://raw.githubusercontent.com/norio-nomura/atom-utf16offset/master/screenshot.gif)

## Plugin installation
```
$ apm install utf16offset
```

## Settings
You can configure UTF16 based Cursor Offset and Selected Length Format by editing ~/.atom/config.cson (choose Open Your Config in Atom menu):
```cson
  utf16offset:
    statusBarFormat: "{%O, %L}"
```

## License
[MIT](LICENSE.md)
