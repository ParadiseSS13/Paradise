// routes.js
// Tip: Press Shift+Alt+O in VSCode to organize these imports.

import { DisposalBin } from './interfaces/DisposalBin';

const ROUTES = {
  disposal_bin: {
    component: () => DisposalBin,
    scrollable: false,
  },
};

export const getRoute = state => {
  if (process.env.NODE_ENV !== 'production') {
    // Show a kitchen sink
    if (state.showKitchenSink) {
      const { KitchenSink } = require('./interfaces/KitchenSink');
      return {
        component: () => KitchenSink,
        scrollable: true,
      };
    }
  }
  // Refer to the routing table
  return ROUTES[state.config && state.config.interface];
};
