module.exports = (config, { strapi }) => {
  return async (ctx, next) => {
    // Temporarily bypass permissions for development
    ctx.state.user = { id: 0, role: 'public' };
    await next();
  };
};

