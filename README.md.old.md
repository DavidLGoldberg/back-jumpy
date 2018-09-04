# Back-Jumpy

[![Join the chat at https://gitter.im/back-jumpy-atom/Lobby](https://badges.gitter.im/back-jumpy-atom/Lobby.svg)](https://gitter.im/back-jumpy-atom/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
![](https://img.shields.io/apm/dm/back-jumpy.svg)
![](https://img.shields.io/apm/v/back-jumpy.svg)
[![Build Status](https://travis-ci.org/DavidLGoldberg/back-jumpy.svg?branch=master)](https://travis-ci.org/DavidLGoldberg/back-jumpy)

An Atom package that lets you go back to your previous cursor position.

## How to "back-jump"

1.  Move your cursor somewhere in a text editor.
2.  Move somewhere else.
3.  Enter ___ to jump back!
4.  Keep coding!

[ ![Back-Jumpy in Action!][1]](https://raw.githubusercontent.com/DavidLGoldberg/back-jumpy/master/_images/back-jumpy.gif)

[1]: https://raw.githubusercontent.com/DavidLGoldberg/back-jumpy/master/_images/back-jumpy.gif

## Install
On command line:
```
apm install back-jumpy
```
Even better when paired with [Jumpy](https://atom.io/packages/jumpy "Jumpy's Homepage")!

## Key Bindings

### Defaults

*   Jump back
    *   <kbd>?????</kbd>
*   Jump Forward
    *   <kbd>shift</kbd> + <kbd>????</kbd>

## Settings

### Back-Jumpy preferences

( Preferences <kbd>cmd</kbd>+<kbd>,</kbd> ) -> search for 'back-jumpy'

*   **Debounce time**:
Alter the amount of time it takes to register a significant jump point.
*   **Use Homing Beacon Effect On Jumps**:
If left on, will display a homing beacon (usually red) after all jumps.

![Back-Jumpy settings](https://raw.githubusercontent.com/DavidLGoldberg/back-jumpy/master/_images/back-jumpy-settings.png)

### 'vim-mode/vim-mode-plus' Users (Strongly Recommended Override)

Put this override in your **'Atom'** -> **'Keymap...'** settings:

    'atom-text-editor:not(.mini).vim-mode:not(.insert-mode), .tree-view':
        'backspace': 'back-jumpy:jump-back'
        'shift-backspace': 'back-jumpy:jump-back'

or if `vim-mode-plus`:

    'atom-text-editor:not(.mini).vim-mode-plus:not(.insert-mode), .tree-view':
        'backspace': 'back-jumpy:jump-back'
        'shift-backspace': 'back-jumpy:jump-forward'

This will **bind <kbd>backspace</kbd> and <kbd>shift backspace</kbd> to jump back and forward**.

This is not the default because it **changes vim's native behavior**.

## My other Atom packages :)

*   [Qolor](https://atom.io/packages/qolor)
*   [Jumpy](https://atom.io/packages/jumpy)

## Keywords

(A little SEO juice)

*   Shortcuts
*   Navigation
*   Productivity
*   Mouseless
*   Plugin
*   Extension
