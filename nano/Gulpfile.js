/*
 * NanoUI Buildscript v1.0
 * JS Edition
 */

/* Configuration */
const input = {
	cmirror: "codemirror",
	fonts:   "**/*.{eot,woff2}",
	images:  "images",
	layouts: "layouts/",
	scripts: {
		lib:    "scripts/libraries",
		main:   "scripts/nano"
	},
	styles:    "styles",
	templates: "templates/"
};

const output = {
	_dir: "assets",
	css: "nanoui.css",
	scripts: {
		"cmirror": "codemirror-compressed.js",
		"lib":     "libraries.min.js",
		"main":    "nano.js"
	}
};

/* Dependencies */
var bower         = require("main-bower-files");
var child_process = require("child_process");
var del           = require("del");
var gulp          = require("gulp");
var merge         = require("merge-stream");
var util          = require("gulp-util");

/* Gulp Plugins */
var $PLUG = require("gulp-load-plugins")({replaceString: /^gulp(-|\.)|-/g});
var postCSSFilters = {
	autoprefixer: require("autoprefixer"),
	gradient:     require("postcss-filter-gradient"),
	opacity:      require("postcss-opacity"),
	rgba:         require("postcss-color-rgba-fallback"),
	plsfilters:   require("pleeease-filters")
};

/* Helpers */
const glob = function (path) {
	return `${path}/*`;
};

var minify = util.env["min"];

/*------Task Section------*/

/* Task: Default
 * Type: Default/Main
 * Just runs the rest of the compilation tasks.
 */
gulp.task("default", ["fonts", "scripts", "styles"]);

/* Task: Clean
 * Type: Dependency. 
 * Deletes everything inside the output directory to avoid conflicts when building new versions.
 */
gulp.task("clean", function () {
	del(glob(output._dir));
});

/* Task: Watch
 * Type: Main
 * Run when someone uses `gulp watch`. Binds listeners to file events on any of the input files, recompiles on demand.
 */
gulp.task("watch", function () {
	// Watch main scripts.
	gulp.watch([glob(input.scripts.lib)], ["reload"]);
	gulp.watch([glob(input.scripts.main)], ["reload"]);

	// Watch images and CSS.
	gulp.watch([glob(input.images)], ["reload"]);
	gulp.watch([glob(input.styles)], ["reload"]);

	// Watch for template files being changed.
	gulp.watch([glob(input.layouts)], ["reload"]);
	gulp.watch([glob(input.templates)], ["reload"]);
});

/* Task: Reload
 * Type: Dependency
 * Run whenever a file is changed. Recompiles and pushes all changes directly to the local BYOND client cache.
 */
gulp.task("reload", ["default"], function () {
	child_process.exec("reload.bat", function (err, stdout, stderr) {
		if(err)
			return console.log(err);
	});
});

/*---Buildtasks---*/

/* Task: Fonts
 * Type: Build-dep
 * Pipes fonts from bower into the nano cache directory.
 */
gulp.task("fonts", function () {
	gulp.src(bower(input.fonts))
		.pipe(gulp.dest(output._dir));
});

/* Task: Scripts
 * Type: Build-dep
 * Compiles all of the library and nano scripts, minifies them if necessary, and puts them in assets
 */
gulp.task("scripts", ["clean"], function () {
	var lib = gulp.src(glob(input.scripts.lib));
	var etc = gulp.src(bower("**/*.js"));

	// Combine libraries and other js into one file
	merge(lib, etc)
		.pipe($PLUG.order(["jquery.js", "jquery*.js", "*.js"])) // Ensure jQuery is always loaded first
		.pipe($PLUG.concat(output.scripts.lib)) // Concatenate all scripts into one file
		.pipe($PLUG.if(minify, $PLUG.uglify().on("error", util.log))) // Minify if set in command line arguments
		.pipe(gulp.dest(output._dir)); // Write the file

	// Combine all of the nano scripts into one
	gulp.src(glob(input.scripts.main))
		.pipe($PLUG.order(["nano_utility.js", "nano_state_manager.js", "*.js"])) // Ensure Nano Util and state manager are always loaded first
		.pipe($PLUG.concat(output.scripts.main)) // Concatenate all scripts into one file
		.pipe($PLUG.if(minify, $PLUG.uglify().on("error", util.log))) // Minify if set in command line arguments
		.pipe(gulp.dest(output._dir)); // Write the file

	// Copy codemirror to the assets
	gulp.src(glob(input.cmirror) + ".js")
		.pipe($PLUG.concat(output.scripts.cmirror))
		.pipe(gulp.dest(output._dir));
});


/* Task: Styles
 * Type: Build-dep
 * Concatenates all CSS in the project and compiles our Nano LESS templates
 */
gulp.task("styles", ["clean"], function () {
	// Get all of the random bower CSS files into `lib`
	var lib = gulp.src(bower("**/*.css"))
		.pipe($PLUG.replace("../fonts/", ""));

	// Gather all of our actual nanoUI styles, compile the LESS, apply postCSS filters
	var main = gulp.src(glob(input.styles))
		.pipe($PLUG.filter(["*.less", "!_*.less"]))
		.pipe($PLUG.less({paths: [input.images]}))
		.pipe($PLUG.postcss([
			postCSSFilters.autoprefixer({browsers: ["last 2 versions", "ie >= 8"]}),
			postCSSFilters.gradient,
			postCSSFilters.opacity,
			postCSSFilters.rgba({oldie: true}),
			postCSSFilters.plsfilters({oldIE: true})
		]));

	var codemirror = gulp.src(glob(input.cmirror) + ".css");

	// Merge the lib and main nano styles into one file
	merge(codemirror, lib, main)
		.pipe($PLUG.if(minify, $PLUG.cssnano({discardComments: {removeAll: true}}), $PLUG.csscomb())) // Minify if necessary
		.pipe($PLUG.concat(output.css)) // Concatenate all CSS into one file
		.pipe(gulp.dest(output._dir)); // Write the file
});