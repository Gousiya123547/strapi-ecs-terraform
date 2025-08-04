'use strict';

module.exports = {
  routes: [
    {
      method: 'GET',
      path: '/ping',
      handler: 'ping.index',
      config: {
        auth: false,
      },
    },
  ],
};

