/// each cell in a spatial_grid is this many turfs in length and width (with world.max(x or y) being 255, 15 of these fit on each side of a z level)
#define SPATIAL_GRID_CELLSIZE 17
/// Takes a coordinate, and spits out the spatial grid index (x or y) it's inside
#define GET_SPATIAL_INDEX(coord) ROUND_UP((coord) / SPATIAL_GRID_CELLSIZE)
/// changes the cell_(x or y) vars on /datum/spatial_grid_cell to the x or y coordinate on the map for the LOWER LEFT CORNER of the grid cell.
/// index is from 1 to SPATIAL_GRID_CELLS_PER_SIDE
#define GRID_INDEX_TO_COORDS(index) ((((index) - 1) * SPATIAL_GRID_CELLSIZE) + 1)
/// number of grid cells per x or y side of all z levels. pass in world.maxx or world.maxy
#define SPATIAL_GRID_CELLS_PER_SIDE(world_bounds) GET_SPATIAL_INDEX(world_bounds)

//grid contents channels

///everything that is hearing sensitive is stored in this channel
#define SPATIAL_GRID_CONTENTS_TYPE_HEARING RECURSIVE_CONTENTS_HEARING_SENSITIVE
///every movable that has a client in it is stored in this channel
#define SPATIAL_GRID_CONTENTS_TYPE_CLIENTS RECURSIVE_CONTENTS_CLIENT_MOBS
///all atmos machines are stored in this channel (I'm sorry kyler)
#define SPATIAL_GRID_CONTENTS_TYPE_ATMOS "spatial_grid_contents_type_atmos"

#define ALL_CONTENTS_OF_CELL(cell) (cell.hearing_contents | cell.client_contents | cell.atmos_contents)

///whether movable is itself or containing something which should be in one of the spatial grid channels.
#define HAS_SPATIAL_GRID_CONTENTS(movable) (movable.spatial_grid_key)

// macros meant specifically to add/remove movables from the internal lists of /datum/spatial_grid_cell,
// when empty they become references to a single list in SSspatial_grid and when filled they become their own list
// this is to save memory without making them lazylists as that slows down iteration through them
#define GRID_CELL_ADD(cell_contents_list, movable_or_list) \
	if(!length(cell_contents_list)) { \
		cell_contents_list = list(); \
		cell_contents_list += movable_or_list; \
	} else { \
		cell_contents_list += movable_or_list; \
	};

#define GRID_CELL_SET(cell_contents_list, movable_or_list) \
	if(!length(cell_contents_list)) { \
		cell_contents_list = list(); \
		cell_contents_list += movable_or_list; \
	} else { \
		cell_contents_list |= movable_or_list; \
	};

//dont use these outside of SSspatial_grid's scope use the procs it has for this purpose
#define GRID_CELL_REMOVE(cell_contents_list, movable_or_list) \
	cell_contents_list -= movable_or_list; \
	if(!length(cell_contents_list)) {\
		cell_contents_list = dummy_list; \
	};

///remove from every list
#define GRID_CELL_REMOVE_ALL(cell, movable) \
	GRID_CELL_REMOVE(cell.hearing_contents, movable) \
	GRID_CELL_REMOVE(cell.client_contents, movable) \
	GRID_CELL_REMOVE(cell.atmos_contents, movable)
