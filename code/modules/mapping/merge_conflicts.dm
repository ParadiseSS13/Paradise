// Used by mapmerge2 to denote the existence of a merge conflict (or when it has to complete a "best intent" merge where it dumps the movable contents of an old key and a new key on the same tile).
// We define it explicitly here to ensure that it shows up on the highest possible plane (while giving off a verbose icon) to aide mappers in resolving these conflicts.
// DO NOT USE THIS IN NORMAL MAPPING!!! Linters WILL fail.

#define MERGE_CONFLICT_MARKER_NAME "Merge Conflict Marker - DO NOT USE"
#define MERGE_CONFLICT_MARKER_ICON 'icons/effects/mapping_helpers.dmi'
#define MERGE_CONFLICT_MARKER_ICON_STATE "merge_conflict_marker"
#define MERGE_CONFLICT_MARKER_DESC "If you are seeing this in-game, please make an issue report on GitHub or contact a coder immediately."

/// We REALLY do not want un-addressed merge conflicts in maps for an
/// inexhaustible list of reasons. This should help ensure that this will not be
/// missed in case linters fail to catch it for any reason what-so-ever.
/proc/announce_merge_conflict_marker(atom/origin)
	var/msg = "HEY, LISTEN!!! Merge Conflict Marker detected at [AREACOORD(origin)]! Please manually address all potential merge conflicts!!!"
	warning(msg)
	to_chat(world, "<span class='boldannounceooc'>[msg]</span>")

/obj/merge_conflict_marker
	name = MERGE_CONFLICT_MARKER_NAME
	icon = MERGE_CONFLICT_MARKER_ICON
	icon_state = MERGE_CONFLICT_MARKER_ICON_STATE
	desc = MERGE_CONFLICT_MARKER_DESC
	plane = POINT_PLANE

/obj/merge_conflict_marker/Initialize(mapload)
	. = ..()
	announce_merge_conflict_marker(src)

/area/merge_conflict_marker
	name = MERGE_CONFLICT_MARKER_NAME
	icon = MERGE_CONFLICT_MARKER_ICON
	icon_state = MERGE_CONFLICT_MARKER_ICON_STATE
	desc = MERGE_CONFLICT_MARKER_DESC
	plane = POINT_PLANE

/area/merge_conflict_marker/Initialize(mapload)
	. = ..()
	announce_merge_conflict_marker(src)

/turf/merge_conflict_marker
	name = MERGE_CONFLICT_MARKER_NAME
	icon = MERGE_CONFLICT_MARKER_ICON
	icon_state = MERGE_CONFLICT_MARKER_ICON_STATE
	desc = MERGE_CONFLICT_MARKER_DESC
	plane = POINT_PLANE

/turf/merge_conflict_marker/Initialize(mapload)
	. = ..()
	announce_merge_conflict_marker(src)

#undef MERGE_CONFLICT_MARKER_NAME
#undef MERGE_CONFLICT_MARKER_ICON
#undef MERGE_CONFLICT_MARKER_ICON_STATE
#undef MERGE_CONFLICT_MARKER_DESC
