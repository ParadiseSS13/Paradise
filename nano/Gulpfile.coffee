### Settings ###
util = require("gulp-util")
s =
  min: util.env.min

# Project Paths
input =
  fonts:     "**/*.{eot,woff2}"
  images:    "images"
  layouts:   "layouts/"
  scripts:
    lib:    "scripts/libraries"
    main:   "scripts/nano"
  styles: "styles"
  templates: "templates/" 

output =
  dir: "assets"
  scripts:
    lib: "libraries.min.js"
    main: "nano.js"
  css: "nanoui.css"

### Pacakages ###
bower         = require "main-bower-files"
child_process = require "child_process"
del           = require "del"
gulp          = require "gulp"
merge         = require "merge-stream"

### Plugins ###
g = require("gulp-load-plugins")({replaceString: /^gulp(-|\.)|-/g})
p =
  autoprefixer: require "autoprefixer"
  gradient:     require "postcss-filter-gradient"
  opacity:      require "postcss-opacity"
  rgba:         require "postcss-color-rgba-fallback"
  plsfilters:   require "pleeease-filters"


### Helpers ###

glob = (path) ->
  "#{path}/*"

### Tasks ###
gulp.task "default", ["fonts", "scripts", "styles"]

gulp.task "clean", ->
  del glob output.dir

gulp.task "watch", ->
  gulp.watch [glob input.images], ["reload"]
  gulp.watch [glob input.layouts], ["reload"]
  gulp.watch [glob input.scripts.lib], ["reload"]
  gulp.watch [glob input.scripts.main], ["reload"]
  gulp.watch [glob input.styles], ["reload"]
  gulp.watch [glob input.templates], ["reload"]

gulp.task "reload", ["default"], ->
  child_process.exec "reload.bat", (err, stdout, stderr) ->
    return console.log err if err


gulp.task "fonts", ["clean"], ->
  gulp.src bower input.fonts
    .pipe gulp.dest output.dir

gulp.task "scripts", ["clean"], ->
  lib = gulp.src glob input.scripts.lib
  etc = gulp.src bower "**/*.js"

  merged = merge lib, etc
    .pipe g.order(["jquery.js",
                   "jquery*.js",
                   "*.js"])
    .pipe g.concat(output.scripts.lib)
    .pipe g.if(s.min, g.uglify().on('error', util.log))
    .pipe gulp.dest output.dir

  main = gulp.src glob input.scripts.main
    .pipe g.order(["nano_utility.js",
                   "nano_state_manager.js"
                   "*.js"])
    .pipe g.concat(output.scripts.main)
    .pipe g.if(s.min, g.uglify().on('error', util.log))
    .pipe gulp.dest output.dir

gulp.task "styles", ["clean"], ->
  lib = gulp.src bower "**/*.css"
    .pipe g.replace("../fonts/", "")

  main = gulp.src glob input.styles
    .pipe g.filter(["*.less", "!_*.less"])
    .pipe g.less({paths: [input.images]})
    .pipe g.postcss([
      p.autoprefixer({browsers: ["last 2 versions", "ie >= 8"]}),
      p.gradient,
      p.opacity,
      p.rgba({oldie: true}),
      p.plsfilters({oldIE: true})
      ])

  combined = merge lib, main
  combined
    .pipe g.if(s.min, g.cssnano({discardComments: {removeAll: true}}), g.csscomb())
    .pipe g.concat(output.css)
    .pipe gulp.dest output.dir