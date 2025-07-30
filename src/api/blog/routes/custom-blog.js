'use strict';

module.exports = {
  routes: [
    {
      method: 'GET',
      path: '/public-blogs',
      handler: 'blog.find',
      config: {
        auth: false, // disables permission checks
      },
    },
  ],
};

