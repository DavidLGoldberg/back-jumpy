'use babel';

import BackJumpyView from './back-jumpy-view';

module.exports = {

    backJumpyView: null,

    activate(state: any) {
        this.backJumpyView = new BackJumpyView(state.backJumpyViewState);
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
