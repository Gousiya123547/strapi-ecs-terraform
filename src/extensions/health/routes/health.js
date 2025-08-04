module.exports = {
  routes: [
    {
      method: 'GET',
      path: '/health',
      handler: 'health.check',  // Points to the check function in the controller
      config: {
        auth: false, // No authentication required for this route
      },
    },
  ],
};

