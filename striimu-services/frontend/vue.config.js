const { defineConfig } = require('@vue/cli-service');

module.exports = defineConfig({
  transpileDependencies: true,
  publicPath: process.env.NODE_ENV === 'production' ? '/' : '/',
  devServer: {
    proxy: {
      '/auth': {
        target: process.env.VUE_APP_BACKEND_URL || 'http://backend:3000',
        changeOrigin: true
      }
    }
  }
});
