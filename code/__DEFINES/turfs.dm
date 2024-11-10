/// Turf will be passable if density is 0
#define TURF_PATHING_PASS_DENSITY 0
/// Turf will be passable depending on [CanPathfindPass] return value
#define TURF_PATHING_PASS_PROC 1
/// Turf is never passable
#define TURF_PATHING_PASS_NO 2

/// Returns a list of turfs similar to CORNER_BLOCK but with offsets
#define CORNER_BLOCK_OFFSET(corner, width, height, offset_x, offset_y) (block(corner.x + offset_x, corner.y + offset_y, corner.z, corner.x + (width - 1) + offset_x, corner.y + (height - 1) + offset_y))

/// Returns a list of around us
#define TURF_NEIGHBORS(turf) (CORNER_BLOCK_OFFSET(turf, 3, 3, -1, -1) - turf)

#define MINERAL_PREVENT_DIG	0	//! A mineral turf should not be changed when mined.
#define MINERAL_ALLOW_DIG	1	//! A mineral turf should be dug out when mined.
