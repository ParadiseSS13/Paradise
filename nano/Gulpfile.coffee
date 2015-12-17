util = require("gulp-util")
s =
  min: util.env.min

input =
  scripts:
    lib: "scripts/lib"
    main: "scripts/nano"
    codemirror: "scripts/lib/codemirror/js"
  styles:
  	codemirror: "scripts/lib/codemirror/css"


output =
  dir: "assets"
  scripts:
    lib: "nanoui.lib.js"
    main: "nanoui.main.js"
    codemirror: "codemirror.js"
  styles:
    codemirror: "codemirror.css"

del           = require "del"
gulp          = require "gulp"

g = require("gulp-load-plugins")({replaceString: /^gulp(-|\.)|-/g})

glob = (path) ->
  "#{path}/*"

subpathglob = (path) ->
  "#{path}/**/*"

gulp.task "default", ["scripts", "styles"]

gulp.task "clean", ->
  del glob output.dir

gulp.task "scripts", ["clean"], ->
  gulp.src glob input.scripts.lib
    .pipe g.concat(output.scripts.lib)
    .pipe g.if(s.min, g.uglify().on('error', g.util.log), g.jsbeautifier())
    .pipe gulp.dest output.dir

  gulp.src glob input.scripts.main
    .pipe g.concat(output.scripts.main)
    .pipe g.if(s.min, g.uglify().on('error', g.util.log), g.jsbeautifier())
    .pipe gulp.dest output.dir

  gulp.src subpathglob input.scripts.codemirror
    .pipe g.concat(output.scripts.codemirror)
    .pipe g.if(s.min, g.uglify().on('error', g.util.log), g.jsbeautifier())
    .pipe gulp.dest output.dir

gulp.task "styles", ["clean"], ->
  gulp.src subpathglob input.styles.codemirror
    .pipe g.concat(output.styles.codemirror)
    .pipe gulp.dest output.dir