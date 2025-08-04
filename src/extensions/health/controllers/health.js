module.exports = {
  async check(ctx) {
    // Responding with a simple healthy status
    ctx.send({
      status: 'healthy',  // You can customize this message
      timestamp: new Date(),
    });
  },
};

