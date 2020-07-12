const webpack = require('webpack');
const path = require('path');
const BuildNotifierPlugin = require('webpack-build-notifier');
const ExtractCssChunks = require('extract-css-chunks-webpack-plugin');

const createStats = verbose => ({
  assets: verbose,
  builtAt: verbose,
  cached: false,
  children: false,
  chunks: false,
  colors: true,
  hash: false,
  timings: verbose,
  version: verbose,
  modules: false,
});

module.exports = (env = {}, argv) => {
  const config = {
    mode: argv.mode === 'production' ? 'production' : 'development',
    context: __dirname,
    entry: {
      tgui: [
        path.resolve(__dirname, './index.js'),
      ],
    },
    output: {
      path: argv.mode === 'production'
        ? path.resolve(__dirname, './public')
        : path.resolve(__dirname, './public/.tmp'),
      filename: '[name].bundle.js',
      chunkFilename: '[name].chunk.js',
    },
    resolve: {
      extensions: ['.mjs', '.js', '.jsx'],
      alias: {},
    },
    module: {
      rules: [
        {
          test: /\.m?jsx?$/,
          use: [
            {
              loader: 'babel-loader',
              options: {
                presets: [
                  ['@babel/preset-env', {
                    modules: 'commonjs',
                    useBuiltIns: 'entry',
                    corejs: '3',
                    spec: false,
                    loose: true,
                    targets: {
                      ie: '8',
                    },
                  }],
                ],
                plugins: [
                  '@babel/plugin-transform-jscript',
                  'babel-plugin-inferno',
                  'babel-plugin-transform-remove-console',
                  'common/string.babel-plugin.cjs',
                ],
              },
            },
          ],
        },
        {
          test: /\.scss$/,
          use: [
            {
              loader: ExtractCssChunks.loader,
              options: {
                hmr: argv.hot,
              },
            },
            {
              loader: 'css-loader',
              options: {},
            },
            {
              loader: 'sass-loader',
              options: {},
            },
          ],
        },
        {
          test: /\.(png|jpg|svg)$/,
          use: [
            {
              loader: 'url-loader',
              options: {},
            },
          ],
        },
      ],
    },
    optimization: {
      noEmitOnErrors: true,
    },
    performance: {
      hints: false,
    },
    devtool: false,
    stats: createStats(true),
    plugins: [
      new webpack.EnvironmentPlugin({
        NODE_ENV: env.NODE_ENV || argv.mode || 'development',
        WEBPACK_HMR_ENABLED: env.WEBPACK_HMR_ENABLED || argv.hot || false,
        DEV_SERVER_IP: env.DEV_SERVER_IP || null,
      }),
      new ExtractCssChunks({
        filename: '[name].bundle.css',
        chunkFilename: '[name].chunk.css',
        orderWarning: true,
      }),
    ],
  };

  // Add a bundle analyzer to the plugins array
  if (argv.analyze) {
    const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer');
    config.plugins = [
      ...config.plugins,
      new BundleAnalyzerPlugin(),
    ];
  }

  // Production specific options
  if (argv.mode === 'production') {
    const TerserPlugin = require('terser-webpack-plugin');
    const OptimizeCssAssetsPlugin = require('optimize-css-assets-webpack-plugin');
    config.optimization.minimizer = [
      new TerserPlugin({
        extractComments: false,
        terserOptions: {
          ie8: true,
          output: {
            ascii_only: true,
          },
        },
      }),
    ];
    config.plugins = [
      ...config.plugins,
      new OptimizeCssAssetsPlugin({
        assetNameRegExp: /\.css$/g,
        cssProcessor: require('cssnano'),
        cssProcessorPluginOptions: {
          preset: ['default', {
            discardComments: {
              removeAll: true,
            },
          }],
        },
        canPrint: true,
      }),
    ];
  }

  // Development specific options
  if (argv.mode !== 'production') {
    config.plugins = [
      ...config.plugins,
      new BuildNotifierPlugin({
        suppressSuccess: true,
      }),
    ];
    if (argv.hot) {
      config.plugins.push(new webpack.HotModuleReplacementPlugin());
    }
    config.devtool = 'cheap-module-source-map';
    config.devServer = {
      progress: false,
      quiet: false,
      noInfo: false,
      clientLogLevel: 'silent',
      stats: createStats(false),
    };
  }

  return config;
};
