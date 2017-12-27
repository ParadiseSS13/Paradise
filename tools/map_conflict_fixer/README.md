#Map Conflict Fixer/Helper#
The map conflict fixer is a script that can help you fix map conflicts easier and faster. Here's how it works:

###Before using###
You need git for this, of course.
Make sure your development branch is up to date before starting a map edit to ensure the script outputs a correct fix.

##Dictionary mode##
Dictionary conflicts are the easiest to fix, you simply need to create more models to accommodate your changes and everyone elses.

When you run in this mode, if the script finishes successfuly the map should be ready to be commited.

If the script fails in dictionary mode, you can run it again in full fix mode.

##Full Fix mode##
When you and someone else edit the same coordinate, there is no easy way to fix the conflict. You need to get your hands dirty.

The script will mark every tile with a marker type to help you identify what needs fixing in the map editor.

After you edit and fix a marked map, you should run it through the map merger. The .backup file should be the same you used before.

###Priorities###
In Full Fix mode, the script needs to know which map version has higher priority, yours or someone elses. This important so tiles with multiple area and turf types aren't created.

Your version has priority - In each conflicted coordinate, your floor type and your area type will be used
Their version has priority - In each conflicted coordinate, your floor type and your area type will not be used

##IMPORTANT##
This script is in a testing phase and you should not consider any output to be safe. Always verify the maps this script produced to make sure nothing is out of place.
