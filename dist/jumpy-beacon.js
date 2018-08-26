"use strict";
'use babel';
Object.defineProperty(exports, "__esModule", { value: true });
const back_jumpy_view_1 = require("./back-jumpy-view");
module.exports = {
    backJumpyView: null,
    activate(state) {
        this.backJumpyView = new back_jumpy_view_1.default(state.backJumpyViewState);
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
//# sourceMappingURL=jumpy-beacon.js.map