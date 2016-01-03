### Settings ###
util = require("gulp-util")
s =
  min: util.env.min

# Project Paths
input =
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
gulp.task "default", ["scripts", "styles"]

gulp.task "clean", ->
  del glob output.dir

gulp.task "scripts", ["clean"], ->
  lib = gulp.src glob input.scripts.lib
    .pipe g.concat(output.scripts.lib)
    .pipe g.if(s.min, g.uglify().on('error', util.log))
    .pipe gulp.dest output.dir

  main = gulp.src glob input.scripts.main
    .pipe g.concat(output.scripts.main)
    .pipe g.if(s.min, g.uglify().on('error', util.log))
    .pipe gulp.dest output.dir

  merge lib, main

gulp.task "styles", ["clean"], ->
  gulp.src glob input.styles
    .pipe g.filter(["*.less", "!_*.less"])
    .pipe g.less()
    .pipe g.postcss([
      p.autoprefixer({browsers: ["last 2 versions", "ie >= 8"]}),
      p.gradient,
      p.opacity,
      p.rgba({oldie: true}),
      p.plsfilters({oldIE: true})
      ])
    .pipe g.concat(output.css)
    .pipe gulp.dest output.dir