'use babel';

/* global atom */
import { CompositeDisposable, Range, Pane, TextEditor } from 'atom';

interface Position {
    row: number;
    column: number;
    path: string;
}

enum Direction {
    Back,
    Forward,
}

export default class BackJumpyView {
    disposables: CompositeDisposable;
    stateMachine: any;

    constructor(serializedState: any, stateMachine: any) {
        this.disposables = new CompositeDisposable();
        this.stateMachine = stateMachine;

        // subscriptions:
        this.stateMachine.ports.backJumped.subscribe((position: Position) => {
            this.jump(position, Direction.Back);
        });
        this.stateMachine.ports.forwardJumped.subscribe((position: Position) => {
            this.jump(position, Direction.Forward);
        });

        // Register commands:
        this.disposables.add(
            atom.commands.add('atom-workspace', {
                'back-jumpy:back': () => {
                    this.stateMachine.ports.requestBack.send(null);
                },
                'back-jumpy:forward': () => {
                    this.stateMachine.ports.requestForward.send(null);
                }
            })
        );

        // Watch for cursor change positions:
        this.disposables.add(
            atom.workspace.observeTextEditors((textEditor: TextEditor) => {
                const path = textEditor.getURI();
                if (path) { // handle path of undefined for new tabs
                    this.disposables.add(
                        textEditor.onDidChangeCursorPosition((event:any) => {
                            const newPosition = {
                                row: event.newBufferPosition.row,
                                column: event.newBufferPosition.column,
                                path: path
                            };
                            this.stateMachine.ports.requestRegisterPosition.send(newPosition);
                        })
                    )
                }
            })
        );
    }

    jump(position:Position, direction:Direction) {
        const textEditor:TextEditor = atom.workspace.getActiveTextEditor();
        if (textEditor.getURI() == position.path) {
            this._jump(position, textEditor, direction);
        } else { // need to open it:
            atom.workspace.open(position.path, {searchAllPanes: true})
            .then((textEditor:TextEditor) => {
                this._jump(position, textEditor, direction);
            });
        }
    }
    _jump(position:Position, textEditor:TextEditor, direction:Direction) {
        textEditor.setCursorBufferPosition([position.row, position.column]);
        this.animateBeacon(position, textEditor, direction); // have it so send it
    }

    animateBeacon(position: Position, textEditor:TextEditor, direction: Direction) {
        const pos = [position.row, position.column];
        const range = Range(pos, pos);
        const marker = textEditor.markScreenRange(range, { invalidate: 'never' });
        const beacon = document.createElement('span');
        beacon.classList.add(
            direction === Direction.Forward
            ? 'back-jumpy-beacon-forward'
            : 'back-jumpy-beacon-back'
        ); // For styling and tests
        textEditor.decorateMarker(marker,
            {
                item: beacon,
                type: 'overlay'
            });
        setTimeout(function() {
            marker.destroy();
        } , 150);
    }

    // Returns an object that can be retrieved when package is activated
    serialize() {}

    // Tear down any state and detach
    destroy() {
        if (this.disposables) {
            this.disposables.dispose();
        }
    }
}
