# Buildmode

## Code layout

### Buildmode

Manager for buildmode modes. Contains logic to manage switching between each mode, and presenting a suitable user interface.

### Effects

Special graphics used by buildmode modes for user interface purposes.

### Buildmode Mode

Implementer of buildmode behaviors.

Existing varieties:

+ Basic

	**Description**:

	Allows creation of simple structures consisting of floors, walls, windows, and airlocks.

	**Controls**:

	+ *Left click a turf*:
	
		"Upgrades" the turf based on the following rules below:

		+ Space -> Tiled floor
		+ Simulated floor -> Regular wall
		+ Wall -> Reinforced wall
	
	+ *Right click a turf*:

		"Downgrades" the turf based on the following rules below:

		+ Reinforced wall -> Regular wall
		+ Wall -> Tiled floor
		+ Simulated floor -> Space
	
	+ *Right click an object*:

		Deletes the clicked object.

	+ *Alt+Left click a location*:

		Places an airlock at the clicked location.
	
	+ *Ctrl+Left click a location*:

		Places a window at the clicked location.

+ Advanced

	**Description**:

	Creates an instance of a configurable atom path where you click.

	**Controls**:

	+ *Right click on the mode selector*:

		Choose a path to spawn.
	
	+ *Alt+Left click a turf, object, or mob*:

		Select the type of the object clicked.
	
	+ *Left click a location* (requires chosen path):

		Place an instance of the chosen path at the location.

	+ *Right click an object*:

		Delete the object.

+ Fill

	**Description**:

	Creates an instance of an atom path on every tile in a chosen region.

	With a special control input, instead deletes everything within the region.

	**Controls**:

	+ *Right click on the mode selector*:

		Choose a path to spawn.

	+ *Left click on a region* (requires chosen path):

		Fill the region with the chosen path.

	+ *Alt+Left click on a region*:

		Deletes everything within the region.

	+ *Right click during region selection*:

		Cancel region selection.

+ Atmos

	**Description**:

	Fills a region with configurable atmos. By default, ignores unsimulated turfs, but is able to "overwrite" the atmos of unsimulated turfs with a special control input.

	By default, fills a region with a breathable, standard atmosphere.

	**Controls**:

	+ *Right click on the mode selector icon*:

		Set the following traits:

		+ Total Pressure
		+ Temperature
		+ Partial Pressure Ratio (PPR) Oxygen
		+ PPR Nitrogen
		+ PPR Plasma
		+ PPR CO2
		+ PPR N2O

	+ *Left click a region*:

		Fill the region with the configured atmos.

	+ *Control+Left click a region*:

		As with the regular left click, but also "overwrites" the base atmos of any unsimulated turfs in the region - such as space turfs.
	
	+ *Right click during region selection*:

		Cancel region selection.

+ Copy

	**Description**:
	
	Take an existing object in the world, and place duplicates with identical attributes where you click.

	May not always work nicely - "deep" variables such as lists or datums may malfunction.

	**Controls**:

	+ *Right click an existing object*:

		Select the clicked object as a template.

	+ *Left click a location* (Requires a selected object as template):

		Place a duplicate of the template at the clicked location.

+ Link

	**Description**:

	Form links between door control buttons and either airlocks or pod bay doors.

	The selected button will be highlighted, and visible lines will be drawn between the doors it is linked to and itself.

	**Controls**:

	+ *Left click a door control button*:

		Makes the button active, and show what doors it is linked to.

	+ *Right click an airlock* (requires active button):

		Links the airlock to the active button. Will remove all links from the button first, if the button is linked to pod bay doors.
	
	+ *Right click a pod bay door* (requires active button):

		Links the pod bay door to the active button. Will remove all links from the button first, if the button is linked to regular airlocks.

+ Area Edit

	**Description**:

	Modifies and creates areas.

	The active area will be highlighted in yellow.

	**Controls**:

	+ *Right click the mode selector*:

		Create a new area, and make it active.

	+ *Right click an existing area*:

		Make the clicked area active.

	+ *Left click a turf*:

		When an area is active, adds the turf to the active area.

+ Var Edit

	**Description**:

	Allows for setting and resetting variables of objects with a click.

	If the object does not have the var, will do nothing and print a warning message.

	**Controls**:

	+ *Right click the mode selector*:

		Choose which variable to set, and what to set it to.

	+ *Left click an atom*:

		Change the clicked atom's variables as configured.
	
	+ *Right click an atom*:

		Reset the targeted variable to its original value in the code.

+ Map Generator

	**Description**:

	Fills rectangular regions with algorithmically generated content. Right click during region selection to cancel.

	See the `procedural_mapping` module for the generators themselves.

	**Controls**:

	+ *Right-click on the mode selector*:
	
		Select a map generator from all the generators present in the codebase.
		
	+ *Left click two corners of an area*:

		Use the generator to populate the region.

	+ *Right click during region selection*:

		Cancel region selection.

+ Save

	**Description**:

	Captures a rectangular region in a `.dmm` format, which can be loaded back later using the "Place Map Template" debug verb.

	Keep in mind this feature is somewhat experimental, and may not always work.

	**Controls**:

	+ *Right click on the mode selector*:

		Configure whether to save in either JSON mode or not.
	
	+ *Left click two corners of an area*:

		Save the region to a `.dmm` file. You will be prompted for where to save this - a copy will be saved in the `_maps/quicksave` folder.

	+ *Right click during region selection*:

		Cancel region selection.

+ Throwing

	**Description**:

	Select an object with left click, and right click to throw it towards where you clicked.

	**Controls**:

	+ *Left click on a movable atom*:
		
		Select the atom for throwing.
	
	+ *Right click on a location*:

		Throw the selected atom towards that location.

+ Boom

	**Description**:

	Make explosions where you click.

	**Controls**:

	+ *Right click the mode selector*:
	
		Configure the explosion size.

	+ *Left click a location*:
	
		Cause an explosion where you clicked.