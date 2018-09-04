'use babel';

import * as elmApp from '../dist/elm/StateMachine';
import BackJumpyView from './back-jumpy-view';

module.exports = {

    backJumpyView: null,

    activate(state: any) {
        console.assert(elmApp.Elm.StateMachine);
        const stateMachine = elmApp.Elm.StateMachine.init();
        this.backJumpyView = new BackJumpyView(state.backJumpyViewState, stateMachine);
    },

    deactivate() {
        if (this.backJumpyView) {
            this.backJumpyView.destroy();
        }
        this.backJumpyView = null;
    },

    serialize() {
        return {
            backJumpyViewState: this.backJumpyView.serialize(),
        };
    }
};
