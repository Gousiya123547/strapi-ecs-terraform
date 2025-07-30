module.exports = (plugin) => {
  // Override the policy check to always allow
  plugin.policies = {
    ...plugin.policies,
    'isAuthenticated': async (ctx, next) => {
      await next(); // bypass authentication
    },
  };
  return plugin;
};

