'use strict';

module.exports = {
  register({ strapi }) {
    // Register the custom health check route
    strapi.server.use('/health', async (ctx) => {
      ctx.status = 200;
      ctx.body = { status: 'healthy' };
    });
  },

  // Any additional setup or options can go here
};

