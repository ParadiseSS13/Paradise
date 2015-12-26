# NanoUI

NanoUI is a user interface library, used for over 100 different interfaces, and rising.
It is more complicated than the other two UI systems in use, the `/datum/browser` and
`browse()` systems, but offers pre-made libraries, JavaScript, and a modified doT
template engine.

This README is not yet complete, but gives a basic rundown of how the folder structure
works. I'll get around to finishing it one day.

## Folder Rundown

### /assets
The assets folder is used by the Gulp compiling system, and stores the minified version of
the NanoUI JavaScript Library and prerequisites. Everything within this folder is sent to
the client as-is.

### /css
This folder is used for the CSS components of NanoUI. Everything within this folder is
sent to the client as-is.

### /images
This folder is used to store any image files. It is sent to the client as-is.

### /js
This folder is for JavaScript which cannot be compiled and put in the assets folder.
Currently, it is only used by the pre-minifed CodeMirror JavaScript. It is sent to the
client as-is.

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

### /templates
This folder is used to store the .tmpl files which are later compiled by the NanoUtility
JavaScript, using a modified version of the doT template engine. It is sent to the client
as-is.

## Compiling
To compile any changes to the NanoUI JavaScript, you must first setup the building
environment.

### Prerequisites
You will first need to install the primary prerequisite of NanoUI, [Node.js](https://nodejs.org).

Node.js is used to obtain all of the remaining prerequisites to compile NanoUI. This is
done by running the following two commands.
 - `npm install -g gulp`
 - `npm install`

### Running Gulp
NanoUI is built using the `gulp` task automation system. This system uses the contents
of the `Gulpfile.js` and `Gulpfile.coffee` files to perform compilation tasks.

In order to build an un-minified version of NanoUI, you may simply run `gulp` in the
`nanoui` directory. However, this should only be used while testing, and you should run
the command `gulp --min` before commiting changes, in order to produce minified
JavaScript.
