# Back-Jumpy

An Atom package to return to previous cursor positions.

## How to "back-jump"

1.  Move your cursor somewhere in a text editor.
2.  Move somewhere else.
3.  Enter a hotkey to jump back!
4.  Keep coding!

[ ![Back-Jumpy in Action!][1]](https://raw.githubusercontent.com/DavidLGoldberg/back-jumpy/master/_images/back-jumpy.gif)

[1]: https://raw.githubusercontent.com/DavidLGoldberg/back-jumpy/master/_images/back-jumpy.gif

## Install
On command line:
```
apm install back-jumpy
```

## Notes

*   Works great with or without [Jumpy](https://atom.io/packages/jumpy) or [Jumpy-beacon](https://atom.io/packages/jumpy-beacon).

### 'vim-mode/vim-mode-plus' Users (Strongly Recommended Override)

Put this override in your **'Atom'** -> **'Keymap...'** settings:

    'atom-text-editor:not(.mini).vim-mode:not(.insert-mode), .tree-view':
        'backspace': 'back-jumpy:back'
        'shift-backspace': 'back-jumpy:forward'

or if `vim-mode-plus`:

    'atom-text-editor:not(.mini).vim-mode-plus:not(.insert-mode), .tree-view':
        'backspace': 'back-jumpy:back'
        'shift-backspace': 'back-jumpy:forward'

This will **bind <kbd>backspace</kbd> and <kbd>shift backspace</kbd> to jump back and forward**.

This is not the default because it **changes vim's native behavior**.

## Config Settings

None yet!

## Back-Jumpy Styles

Just override the `.back-jumpy-beacon` class from [beacon.less](https://raw.githubusercontent.com/DavidLGoldberg/back-jumpy/master/styles/beacon.less)

*Note*: Styles can be overridden in **'Atom' -> 'Stylesheet...'**

## My other Atom packages :)

*   [Jumpy](https://atom.io/packages/jumpy)
*   [Jumpy-beacon](https://atom.io/packages/jumpy-beacon)
*   [Qolor](https://atom.io/packages/qolor)

## Keywords

(A little SEO juice)

*   Shortcuts
*   Navigation
*   Productivity
*   Mouseless
*   Plugin
*   Extension
