# Info
This document contains all the relevant information for downloading and running your own ParaCode server.

### GETTING THE CODE
The simplest way to obtain the code is using the github .zip feature.

Click [here](https://github.com/ParadiseSS13/Paradise/archive/master.zip) to get the latest code as a .zip file, then unzip it to wherever you want.

The more complicated and easier to update method is using git.
You'll need to download git or some client from [here](http://git-scm.com/).
When that's installed, right click in any folder and click on "Git Bash".
When that opens, type in:

    git clone https://github.com/ParadiseSS13/Paradise.git

(hint: hold down ctrl and press insert to paste into git bash)

This will take a while to download, but it provides an easier method for updating.

### INSTALLATION

First-time installation should be fairly straightforward.
First, you'll need BYOND installed. We're going to assume you already did this

This is a sourcecode-only release, so the next step is to compile the server files.
Open paradise.dme by double-clicking it, open the Build menu, and click compile.
This'll take a little while, and if everything's done right,
you'll get a message like this:

    saving paradise.dmb (DEBUG mode)

    paradise.dmb - 0 errors, 0 warnings

If you see any errors or warnings,
something has gone wrong - possibly a corrupt download or the files extracted wrong,
or a code issue on the main repo.  Ask on Dscord.

Once that's done, open up the config folder.
Firstly, you will want to copy everything from the example folder into the regular config folder.
EG: Move `config/example/config.txt` to `config/config.txt`, and do the same for all the other files.
You'll want to edit config.txt to set your server location,
so that all your players don't get disconnected at the end of each round.
It's recommended you don't turn on the gamemodes with probability 0,
as they have various issues and aren't currently being tested,
so they may have unknown and bizarre bugs.

You'll also want to edit admins.txt to remove the default admins and add your own.
If you are connecting from localhost to your own test server, you should automatically be admin.
"Host" is the highest level of access, and the other recommended admin levels for now are
"Game Admin" and "Moderator".  The format is:

    byondkey - Rank

where the BYOND key must be in lowercase and the admin rank must be properly capitalised.
There are a bunch more admin ranks, but these two should be enough for most servers,
assuming you have trustworthy admins. You can define your own ranks in `admin_ranks.txt`

Finally, to start the server,
run Dream Daemon and enter the path to your compiled paradise.dmb file.
Make sure to set the port to the one you specified in the config.txt,
and set the Security box to 'Trusted'.
Then press GO and the server should start up and be ready to join.

### Installation (Linux)

The code is fully able to run on linux, however windows is the recommended platform. The code requires 2 libraries, with dependencies below

For MySQL, run the following: `apt-get install libmysqlclient-dev:i386`

For RustG please download the latest relase from [https://github.com/ParadiseSS13/rust-g](https://github.com/ParadiseSS13/rust-g), run the following: `apt-get install libssl-dev:i386 pkg-config:i386 zlib1g-dev:i386`.

After installing these packages, these libraries should function as intended. We assume that if you are hosting on linux, you know what you are doing.

---

### UPDATING

If you used the zip method,
you'll need to download the zip file again and unzip it somewhere else,
and then copy the /config and /data folders over.

If you used the git method, you simply need to type this in to git bash:

    git pull

When you have done this, you'll need to recompile the code, but then it should work fine.

---

### SQL Setup

The SQL backend is required for storing character saves, preferences, administrative data, and many other things.
We recommend running a database if your server is going to be used as more than juts a local test server
Your server details go in /config/dbconfig.txt,
and the SQL schema is in /SQL/paradise_schema.sql or /SQL/paradise_schema_prefix.sql,
depending on if you want table prefixes.
More detailed setup instructions are located on our wiki:
https://www.paradisestation.org/wiki/index.php/Setting_up_the_Database
