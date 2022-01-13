const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')
const erb = require('./loaders/erb')

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
environment.loaders.append('erb', erb)

const config = environment.toWebpackConfig()
config.resolve.alias = {
  vue$: 'vue/dist/vue.esm.js'
}

module.exports = environment
