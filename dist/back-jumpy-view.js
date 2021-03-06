"use strict";
'use babel';
Object.defineProperty(exports, "__esModule", { value: true });
/* global atom */
const atom_1 = require("atom");
var Direction;
(function (Direction) {
    Direction[Direction["Back"] = 0] = "Back";
    Direction[Direction["Forward"] = 1] = "Forward";
})(Direction || (Direction = {}));
class BackJumpyView {
    constructor(serializedState, stateMachine) {
        this.disposables = new atom_1.CompositeDisposable();
        this.stateMachine = stateMachine;
        // subscriptions:
        this.stateMachine.ports.backJumped.subscribe((position) => {
            this.jump(position, Direction.Back);
        });
        this.stateMachine.ports.forwardJumped.subscribe((position) => {
            this.jump(position, Direction.Forward);
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
            const path = textEditor.getURI();
            if (path) {
                this.disposables.add(textEditor.onDidChangeCursorPosition((event) => {
                    const newPosition = {
                        row: event.newBufferPosition.row,
                        column: event.newBufferPosition.column,
                        path: path
                    };
                    this.stateMachine.ports.requestRegisterPosition.send(newPosition);
                }));
            }
        }));
    }
    jump(position, direction) {
        const textEditor = atom.workspace.getActiveTextEditor();
        if (textEditor.getURI() == position.path) {
            this._jump(position, textEditor, direction);
        }
        else {
            atom.workspace.open(position.path, { searchAllPanes: true })
                .then((textEditor) => {
                this._jump(position, textEditor, direction);
            });
        }
    }
    _jump(position, textEditor, direction) {
        textEditor.setCursorBufferPosition([position.row, position.column]);
        this.animateBeacon(position, textEditor, direction); // have it so send it
    }
    animateBeacon(position, textEditor, direction) {
        const pos = [position.row, position.column];
        const range = atom_1.Range(pos, pos);
        const marker = textEditor.markScreenRange(range, { invalidate: 'never' });
        const beacon = document.createElement('span');
        beacon.classList.add(direction === Direction.Forward
            ? 'back-jumpy-beacon-forward'
            : 'back-jumpy-beacon-back'); // For styling and tests
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