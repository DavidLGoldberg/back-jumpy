'use babel';

/* global atom */
import { CompositeDisposable, Range, Pane, TextEditor } from 'atom';

export default class BackJumpyView {
    disposables: CompositeDisposable;
    stateMachine: any;

    constructor(serializedState: any, stateMachine: any) {
        this.disposables = new CompositeDisposable();
        this.stateMachine = stateMachine;

        // subscriptions:
        this.stateMachine.ports.backJumped.subscribe((position: any) => {
            this.jump(position);
        });
        this.stateMachine.ports.forwardJumped.subscribe((position: any) => {
            this.jump(position);
        });

        // commands
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

        // on did cursor change position
        this.disposables.add(
            atom.workspace.observeTextEditors((textEditor: TextEditor) => {
                this.disposables.add(
                    textEditor.onDidChangeCursorPosition((event:any) => {
                        const newPosition = [
                            event.newBufferPosition.row,
                            event.newBufferPosition.column
                        ];
                        this.stateMachine.ports.requestRegisterPosition.send(newPosition);
                    })
                )
            })
        );
    }

    jump(position: any) {
        const textEditor:TextEditor = atom.workspace.getActiveTextEditor();
        textEditor.setCursorBufferPosition(position);
        this.animateBeacon(textEditor, position);
    }

    animateBeacon(textEditor: TextEditor, position: any) {
        const range = Range(position, position);
        const marker = textEditor.markScreenRange(range, { invalidate: 'never' });
        const beacon = document.createElement('span');
        beacon.classList.add('back-jumpy-beacon'); // For styling and tests
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
