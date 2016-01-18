### Settings ###
util = require("gulp-util")
s =
  min: util.env.min

# Project Paths
input =
  fonts: "**/*.{eot,woff2}"
  scripts:
    lib: "scripts/libraries"
    main: "scripts/nano"
  styles: "styles"

output =
  dir: "assets"
  scripts:
    lib: "libraries.min.js"
    main: "nano.js"
  css: "nanoui.css"

### Pacakages ###
bower         = require "main-bower-files"
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

gulp.task "fonts", ["clean"], ->
  gulp.src bower input.fonts
    .pipe gulp.dest output.dir

gulp.task "scripts", ["clean"], ->
  lib = gulp.src glob input.scripts.lib
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

  merge lib, main

gulp.task "styles", ["clean"], ->
  lib = gulp.src bower "**/*.css"
    .pipe g.replace("../fonts/", "")

  main = gulp.src glob input.styles
    .pipe g.filter(["*.less", "!_*.less"])
    .pipe g.less()
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