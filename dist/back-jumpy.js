"use strict";
'use babel';
Object.defineProperty(exports, "__esModule", { value: true });
const elmApp = require("../dist/elm/StateMachine");
const back_jumpy_view_1 = require("./back-jumpy-view");
module.exports = {
    backJumpyView: null,
    activate(state) {
        console.assert(elmApp.Elm.StateMachine);
        const stateMachine = elmApp.Elm.StateMachine.init();
        this.backJumpyView = new back_jumpy_view_1.default(state.backJumpyViewState, stateMachine);
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
//# sourceMappingURL=back-jumpy.js.map