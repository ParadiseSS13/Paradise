/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const createBabelConfig = options => {
  const { mode, presets = [], plugins = [] } = options;
  return {
    presets: [
      ['@babel/preset-env', {
        modules: 'commonjs',
        useBuiltIns: 'entry',
        corejs: '3.8',
        spec: false,
        loose: true,
        targets: [],
      }],
      ...presets,
    ],
    plugins: [
      '@babel/plugin-transform-jscript',
      'babel-plugin-inferno',
      'babel-plugin-transform-remove-console',
      'common/string.babel-plugin.cjs',
      ...plugins,
    ],
  };
};

module.exports = (api) => {
  api.cache(true);
  const mode = process.env.NODE_ENV;
  return createBabelConfig({ mode });
};

module.exports.createBabelConfig = createBabelConfig;
