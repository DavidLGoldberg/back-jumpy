"use strict";
'use babel';
Object.defineProperty(exports, "__esModule", { value: true });
/* global atom */
const atom_1 = require("atom");
class BackJumpyView {
    constructor(serializedState, stateMachine) {
        this.disposables = new atom_1.CompositeDisposable();
        this.stateMachine = stateMachine;
        // subscriptions:
        this.stateMachine.ports.backJumped.subscribe((position) => {
            this.jump(position);
        });
        this.stateMachine.ports.forwardJumped.subscribe((position) => {
            this.jump(position);
        });
        // Register commands:
        this.disposables.add(atom.commands.add('atom-workspace', {
            'back-jumpy:back': () => {
                this.stateMachine.ports.requestBack.send(null);
            },
            'back-jumpy:forward': () => {
                this.stateMachine.ports.requestForward.send(null);
            }
        }));
        // Watch for cursor change positions:
        this.disposables.add(atom.workspace.observeTextEditors((textEditor) => {
            this.disposables.add(textEditor.onDidChangeCursorPosition((event) => {
                const newPosition = {
                    row: event.newBufferPosition.row,
                    column: event.newBufferPosition.column,
                    path: textEditor.getURI()
                };
                this.stateMachine.ports.requestRegisterPosition.send(newPosition);
            }));
        }));
    }
    jump(position) {
        atom.workspace.open(position.path, { searchAllPanes: true })
            .then((textEditor) => {
            textEditor.setCursorBufferPosition([position.row, position.column]);
            this.animateBeacon(position, textEditor); // have it so send it
        });
    }
    animateBeacon(position, textEditor) {
        const pos = [position.row, position.column];
        const range = atom_1.Range(pos, pos);
        const marker = textEditor.markScreenRange(range, { invalidate: 'never' });
        const beacon = document.createElement('span');
        beacon.classList.add('back-jumpy-beacon'); // For styling and tests
        textEditor.decorateMarker(marker, {
            item: beacon,
            type: 'overlay'
        });
        setTimeout(function () {
            marker.destroy();
        }, 150);
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
//# sourceMappingURL=back-jumpy-view.js.map