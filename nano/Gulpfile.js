/*
 * NanoUI Buildscript v2.0
 * Fuck the old buildscript edition
 */

// Node Dependencies
const child_process = require('child_process')
const fs = require('fs-extra')
const path = require('path')

/* Configuration */
const INPUT = {
  'fonts': path.join(__dirname, 'node_modules', 'font-awesome', 'fonts', '*.{eot,woff2}'),
  'images': path.join(__dirname, 'images'),
  'styles': {
    '_dir': path.join(__dirname, 'styles'),
    'nano': path.join(__dirname, 'styles', 'nanoui.less'),
    'fa': path.join(__dirname, 'node_modules', 'font-awesome', 'less', 'font-awesome.less'),
  },
  'scripts': {
    'lib': path.join(__dirname, 'scripts', 'libraries', '*.js'),
    'main': path.join(__dirname, 'scripts', 'nano', '*.js'),
    'es5shim': path.join(__dirname, 'node_modules', 'es5-shim', 'es5-shim.js'),
    'domurl': path.join(__dirname, 'node_modules', 'domurl', 'url.js'),
  },
  'layouts': path.join(__dirname, 'layouts'),
  'templates': path.join(__dirname, 'templates'),
  // The story here is: Fucking shitty ass libraries
  'watch': [
    'images/**/*',
    'scripts/**/*',
    'styles/**/*',
    'layouts/**/*',
    'templates/**/*'
  ]
}

const OUTPUT = {
	'_dir': path.join(__dirname, 'assets'),
  'scripts': {
    'lib': 'libraries.min.js',
    'main': 'nano.js'
  }
}

/*** Gulp Dependencies ***/
const gulp = require('gulp')
const concat = require('gulp-concat')
const cleancss = require('gulp-clean-css')
const order = require('gulp-order')
const replace = require('gulp-replace')
const postcss = require('gulp-postcss')
const postcssFilters = {
  gradient: require('postcss-filter-gradient'),
  opacity: require('postcss-opacity'),
  rgba: require('postcss-color-rgba-fallback'),
  plsfilters:   require("pleeease-filters")
}
const sourcemaps = require('gulp-sourcemaps')
const uglify = require('gulp-uglify')
const merge = require('merge-stream')

const less = require('gulp-less')
var autoprefix = new (require('less-plugin-autoprefix'))({ browsers: ['IE 8-11'] })

/*** Tasks ***/

/* Task: Clean
 * Type: Build-Dep
 * This empties the output directory to prepare for new files. By default, this is nano/assets/.
 */
function clean(cb) {
	fs.emptyDir(OUTPUT._dir, function (err) {
		if (err)
			return console.error(err)
		cb()
	})
}

/* Task: CSS
 * Type: Build-Step
 * This compiles all of the LESS styles we require and runs a few IE-friendly CSS filters over the output.
 */
function css() {
  // Get both of our LESS components
  let faLESS = gulp.src(INPUT.styles.fa)
  let nanoLESS = gulp.src(INPUT.styles.nano)

  // Then haphazardly smash them together and hope it works out
  return merge(faLESS, nanoLESS)
    .pipe(sourcemaps.init())
    .pipe(less({
      plugins: [autoprefix],
      paths: [INPUT.images]
    }))
    .pipe(replace('../fonts/', ''))
    .pipe(concat('nanoui.css'))
    .pipe(postcss([ // IE8+ support garbage
      postcssFilters.gradient,
      postcssFilters.opacity,
      postcssFilters.rgba,
      postcssFilters.plsfilters({oldIE: true})
    ]))
    .pipe(cleancss({
      compatibility: 'ie8',
      level: {
        1: {
          all: false,
          cleanupCharsets: true,
          specialComments: 0
        }
      }
    }))
    .pipe(sourcemaps.write()) // Hey look sourcemaps that IE can't use (piece of shit)
    .pipe(gulp.dest(OUTPUT._dir))
}

/* Task: JS
 * Type: Build-Step
 * This builds both our libraries and nano JS files. It uglifies them for performance.
 */
function js() {
  let lib = gulp.src(INPUT.scripts.lib)
  let es5shim = gulp.src(INPUT.scripts.es5shim)
  let domurl = gulp.src(INPUT.scripts.domurl)

  // Combine all of the library scripts into one file
  merge(lib, es5shim, domurl)
    .pipe(order(["jquery.js", "jquery*.js", "*.js"])) // Make sure jQuery is the first damn thing in there
    .pipe(concat(OUTPUT.scripts.lib))
    .pipe(sourcemaps.init())
    .pipe(uglify())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(OUTPUT._dir))

  // Combine all of the nano scripts into one
  return gulp.src(INPUT.scripts.main)
    .pipe(order(["nano_utility.js", "nano_state_manager.js", "*.js"])) // Ensure Nano Util and state manager are always loaded first
    .pipe(concat(OUTPUT.scripts.main))
    .pipe(sourcemaps.init())
    .pipe(uglify())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(OUTPUT._dir))
}

/* Task: Fonts
 * Type: Build-Step
 * This literally just copy-pastes the FontAwesome fonts into the build directory. We need them there.
 * If we ever use any other icon fonts (e.x. Material Icons), copy their asses here too.
 */
function fonts() {
  return gulp.src(INPUT.fonts)
    .pipe(gulp.dest(OUTPUT._dir))
}

/* Task: Reload
 * Type: Main
 * This injects all the changed files directly into the client cache.
 */
function reload(cb) {
  child_process.exec("reload.bat", function (err, stdout) {
    if (err)
      throw err
    var byond_cache = path.join(stdout.trim(), "BYOND", "cache")
    var files = fs.readdirSync(byond_cache)
    for (let file of files) {
      let filepath = path.join(byond_cache, file)
      let stats = fs.statSync(filepath)
      if (file.startsWith("tmp") && stats.isDirectory()) {
        var tmpFiles = fs.readdirSync(filepath)
        if (tmpFiles.includes(OUTPUT.scripts.main)) {
          setTimeout(function () {transfer_files(filepath)}, 500)
        }
      }
    }
    cb()
  })
}

function transfer_files(target) {
  let transfer = [INPUT.images, INPUT.layouts, INPUT.templates, OUTPUT._dir]
  for (let trf of transfer) {
    let files = fs.readdirSync(trf)
    for (let file of files) {
      let fileData = fs.statSync(path.join(trf, file))
      if (fileData.isFile())
        transfer_file(path.join(trf, file), path.join(target, file))
    }
  }
}
function transfer_file(input, target) {
  fs.createReadStream(input).pipe(fs.createWriteStream(target))
}

/* Task: Watch
 * Type: Main
 * This is just an alias to trigger all the gulp watch shit
 */
function watch(cb) {
  // Alright, so here's some fucking stupid bullshit we have to work around:
  // Gulp 4.0 uses an updated version of chokidar for watching files.
  // This version of chokidar doesn't fucking support windows path seperators.
  // So, we have to only use relative paths with forward slashes.
  let watchTask = gulp.series(exports.default, reload)
  // Watch files.
  gulp.watch(INPUT.watch, watchTask)
  cb()
}

/* This shit is a Gulp v4 design. You use exports to define tasks now, instead of gulp.tasks. */
exports.default = gulp.series(clean, gulp.parallel(css, js, fonts))
exports.watch = watch