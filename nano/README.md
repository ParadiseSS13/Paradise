# NanoUI

NanoUI is a user interface library, used for over 100 different interfaces, and rising.
It is more complicated than the other two UI systems in use, the `/datum/browser` and
`browse()` systems, but offers pre-made libraries, JavaScript, and a modified doT
template engine.

This README is not yet complete, but gives a basic rundown of how the folder structure
works. I'll get around to finishing it one day.

## Contributors

This section is for listing the contributors to NanoUI.

 - -tg-station/Neersighted
  - Special thanks goes to Neersighted for creating most of the newest and best features
    of NanoUI. Everything between using the Gulp build system to switching to LESS styles
    has been directly adapated and/or copied from his original work for -tg-station and
    their UI system, tgui.

    Systems ported/adapted from -tg-station and Neersighted include, but are not limited
    to:

    - NanoUI's JavaScript controlling the "fancy" borderless window mode.
    - The NanoTrasen.svg logo (Licensed under CC 3.0 BY-SA).
    - The packages in bower.json and packages.json files were hand-picked by Neersighted
      for usage in compiling NanoUI.
    - A considerable amount of this README is adapated from Neersighted's documentation.
    - The concepts following: Using FontAwesome instead of icon16, Using LESS to expand
      NanoUI's CSS style.

NanoUI is licensed under AGPLv3. This applies to it's serverside `DM` code as well as it's
clientside `JavaScript` and `LESS` code. The file `nano/images/nanotrasen.svg` is licensed
under CC 3.0 BY-SA, and was created by Neersighted. All other image files in the
`nano/images/` directory are subject to the standard image license applied to the Paradise
repository icons.

## Folder Rundown

### /assets
The assets folder is used by the Gulp compiling system, and stores the minified version of
the NanoUI JavaScript Library and prerequisites. Everything within this folder is sent to
the client as-is.

### /codemirror
This folder contains all of the JavaScript and CSS for CodeMirror. It is sent to the
client as-is. CodeMirror only has it's own folder due to the fact that it can't be
directly compiled into the NanoUI files.

### /images
This folder is used to store any image files. It is sent to the client as-is.

### /layouts
This folder is used for the central "layout" template files, which is loaded before the
UI's actual template file. It is sent to the client as-is.

### /scripts
This folder is used for anything that will be compiled by the Gulp compilation system.
Currently, it is split into two folders. The file names must start with a number, as this
is how Gulp decides what order to put the concatenated and possibly minified files in.
Anything within this folder is not sent to the client directly.

#### /scripts/libraries
This folder is used to store the source code of the prerequisites of NanoUI. Currently,
it contains jQuery, jQuery UI, jQuery timers, and the doT template system.

#### /scripts/nano
This folder contains the primary JavaScript for NanoUI.

### /styles
This folder is used for NanoUI's LESS styles. These are compiled via gulp into the file
`nanoui.css`. LESS is a system that expands upon CSS in order to make it better, as well
as less complicated.

Any LESS file that is prefixed with the `_` character will be ignored during compilation.
These files are still included, however, via `@import`, view the file
[`nanoui.less`](http://github.com/ParadiseSS13/Paradise/blob/master/nano/styles/nanoui.less) to see how this works.


### /templates
This folder is used to store the .tmpl files which are later compiled by the NanoUtility
JavaScript, using a modified version of the doT template engine. It is sent to the client
as-is.

## Compiling
To compile any changes to the NanoUI JavaScript, you must first setup the building
environment.

### Prerequisites
You will first need to install the primary prerequisite of NanoUI, [Node.js](https://nodejs.org).

If you don't want to rip out all of your hair and you're on Windows, you should also have some linux-emulating terminal.
The easiest to install, and something you can use for managing this git repo, is [git-scm](https://git-scm.com/)

Node.js is used to obtain all of the remaining prerequisites to compile NanoUI. This is
done by running the following commands.
 - `npm install -g gulp-cli`
 - `npm install`

### Running Gulp
NanoUI is built using the `gulp` task automation system. This system uses the contents
of the `Gulpfile.js` file to perform compilation tasks.

In order to build an un-minified version of NanoUI, you may simply run `gulp` in the
`nanoui` directory. However, this should only be used while testing, and you should run
the command `gulp --min` before commiting changes, in order to produce minified
JavaScript.
