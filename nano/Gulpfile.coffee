### Settings ###
util = require("gulp-util")
s =
  min: util.env.min

# Project Paths
input =
  scripts:
    lib: "scripts/libraries"
    main: "scripts/nano"

output =
  dir: "assets"
  scripts:
    lib: "libraries.min.js"
    main: "nano.js"

### Pacakages ###
del           = require "del"
gulp          = require "gulp"
merge         = require "merge-stream"

### Plugins ###
g = require("gulp-load-plugins")({replaceString: /^gulp(-|\.)|-/g})

### Helpers ###

glob = (path) ->
  "#{path}/*"

### Tasks ###
gulp.task "default", ["scripts"]

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