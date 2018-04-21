module.exports = {
  configureWebpack: {
    output: {
      filename: "[name].js",
      publicPath: "/",
      library: "output",
      libraryTarget: "var",
      libraryExport: 'default'
    }
  },
  css: {
    extract: false
  },
  productionSourceMap: false
}
