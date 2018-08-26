"use strict";
'use babel';
Object.defineProperty(exports, "__esModule", { value: true });
/* global atom */
const atom_1 = require("atom");
class BackJumpyView {
    constructor(serializedState) {
        this.disposables = new atom_1.CompositeDisposable();
        // this.disposables.add(
        //     // on did cursor change position
        // );
    }
    animateBeacon(paneItem) {
        if (!atom.workspace.isTextEditor(paneItem)) {
            return;
        }
        // TODO: Should this get the 0,0 exclusion like jumpy-beacon? Probably needs to be excluded from list instead.
        const textEditor = paneItem;
        const position = textEditor.getCursorScreenPosition();
        const range = atom_1.Range(position, position);
        const marker = textEditor.markScreenRange(range, { invalidate: 'never' });
        const beacon = document.createElement('span');
        beacon.classList.add('back-jumpy-beacon'); // For styling and tests
        textEditor.decorateMarker(marker, {
            item: beacon,
            type: 'overlay'
        });
        setTimeout(function () {
            marker.destroy();
        }, 200);
    }
    // Returns an object that can be retrieved when package is activated
    serialize() { }
    // Tear down any state and detach
    destroy() {
        if (this.disposables) {
            this.disposables.dispose();
        }
    }
}
exports.default = BackJumpyView;
//# sourceMappingURL=jumpy-beacon-view.js.map