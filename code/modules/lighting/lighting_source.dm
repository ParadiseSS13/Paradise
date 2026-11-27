// This is where the fun begins.
// These are the main datums that emit light.

/datum/light_source
	/// The atom we're emitting light from (for example a mob if we're from a flashlight that's being held).
	var/atom/top_atom
	/// The atom that we belong to.
	var/atom/source_atom

	/// The turf under the above.
	var/turf/source_turf
	/// The turf the top_atom appears to over.
	var/turf/pixel_turf
	/// Intensity of the emitter light.
	var/light_power
	/// The range of the emitted light.
	var/light_range
	/// The colour of the light, string, decomposed by parse_light_color()
	var/light_color

	// Variables for keeping track of the colour.
	var/lum_r
	var/lum_g
	var/lum_b

	// The lumcount values used to apply the light.
	var/tmp/applied_lum_r
	var/tmp/applied_lum_g
	var/tmp/applied_lum_b

	/// List used to store how much we're affecting corners.
	var/list/datum/lighting_corner/effect_str

	/// Whether we have applied our light yet or not.
	var/applied = FALSE

	/// Whether we are queued for an update.
	var/needs_update = LIGHTING_NO_UPDATE


/datum/light_source/New(atom/owner, atom/top)
	source_atom = owner // Set our new owner.
	LAZYADD(source_atom.light_sources, src)
	if(top.flags_2 & BLOCKS_LIGHT_2) // If the top atom blocks light, then our owner becomes the topmost instead. This still allows atoms that block light to be a light of their own.
		top_atom = source_atom
	else
		top_atom = top
	if(top_atom != source_atom)
		LAZYADD(top_atom.light_sources, src)

	source_turf = top_atom
	pixel_turf = get_turf_pixel(top_atom) || source_turf
	if(!pixel_turf)
		stack_trace("[src] had no pixel turf assigned to it")
		qdel(src)
		return // Get us out of here before we do unneded operations

	light_power = source_atom.light_power
	light_range = source_atom.light_range
	light_color = source_atom.light_color

	PARSE_LIGHT_COLOR(src)

	update()

/datum/light_source/Destroy(force)
	remove_lum()
	if(source_atom)
		source_atom.delete_lights()
		LAZYREMOVE(source_atom.light_sources, src)

	if(top_atom)
		LAZYREMOVE(top_atom.light_sources, src)

	if(needs_update)
		SSlighting.sources_queue -= src

	. = ..()

// Yes this doesn't align correctly on anything other than 4 width tabs.
// If you want it to go switch everybody to elastic tab stops.
// Actually that'd be great if you could!
#define EFFECT_UPDATE(level)                \
	if(needs_update == LIGHTING_NO_UPDATE) \
		SSlighting.sources_queue += src; \
	if(needs_update < level)               \
		needs_update            = level;    \


// This proc will cause the light source to update the top atom, and add itself to the update queue.
/datum/light_source/proc/update(atom/new_top_atom)
	// This top atom is different.
	if(new_top_atom && new_top_atom != top_atom)
		if(top_atom != source_atom && top_atom.light_sources) // Remove ourselves from the light sources of that top atom.
			LAZYREMOVE(top_atom.light_sources, src)

		if(new_top_atom.flags_2 & BLOCKS_LIGHT_2)
			top_atom = source_atom
		else
			top_atom = new_top_atom

		if(top_atom != source_atom)
			LAZYADD(top_atom.light_sources, src) // Add ourselves to the light sources of our new top atom.

	EFFECT_UPDATE(LIGHTING_CHECK_UPDATE)

// Will force an update without checking if it's actually needed.
/datum/light_source/proc/force_update()
	EFFECT_UPDATE(LIGHTING_FORCE_UPDATE)

// Will cause the light source to recalculate turfs that were removed or added to visibility only.
/datum/light_source/proc/vis_update()
	EFFECT_UPDATE(LIGHTING_VIS_UPDATE)

// Macros that apply light to corners.
// They are macros in the interest of speed, yet not having to copy paste them.
// If you're wondering what's with the backslashes, the backslashes cause BYOND to not automatically end the line.
// As such this all gets counted as a single line.
// The braces and semicolons are there to be able to do this on a single line.

/// Copies the vars ADD_CORNER_LUM() needs into locals, since reading a local is faster than reading src's vars for every corner. For procs that only remove light.
#define SETUP_CORNERS_REMOVAL_CACHE \
	var/_applied_lum_r = applied_lum_r; \
	var/_applied_lum_g = applied_lum_g; \
	var/_applied_lum_b = applied_lum_b; \
	var/list/_corners_queue = SSlighting.corners_queue;

/// Copies the vars LUM_FALLOFF() and ADD_CORNER_LUM() need into locals. Has to come before either of them is used.
#define SETUP_CORNERS_CACHE \
	SETUP_CORNERS_REMOVAL_CACHE \
	var/_pixel_x = pixel_turf.x; \
	var/_pixel_y = pixel_turf.y; \
	var/_range_divisor = max(1, light_range); \
	var/_light_power = light_power; \
	var/_lum_r = lum_r; \
	var/_lum_g = lum_g; \
	var/_lum_b = lum_b;

/// This is the define used to calculate falloff.
#define LUM_FALLOFF(C) (1 - CLAMP01(sqrt((C.x - _pixel_x) ** 2 + (C.y - _pixel_y) ** 2 + LIGHTING_HEIGHT) / _range_divisor))

/// Adds the given amount of light to a corner, and queues the corner for an update if it changed.
#define ADD_CORNER_LUM(C, DELTA_R, DELTA_G, DELTA_B) \
	if(DELTA_R || DELTA_G || DELTA_B) { \
		C.lum_r += DELTA_R; \
		C.lum_g += DELTA_G; \
		C.lum_b += DELTA_B; \
		if(!C.needs_update) { \
			C.needs_update = TRUE; \
			_corners_queue += C; \
		} \
	}

/// Adds a corner to the `corners` list, unless it's already been added this update.
#define GATHER_CORNER(C) \
	if(C.update_stamp != stamp) { \
		C.update_stamp = stamp; \
		corners += C; \
	}

/// Removes our light from every corner we're lighting.
/datum/light_source/proc/remove_lum()
	applied = FALSE
	SETUP_CORNERS_REMOVAL_CACHE
	for(var/datum/lighting_corner/corner as anything in effect_str)
		var/strength = effect_str[corner]
		var/delta_r = -strength * _applied_lum_r
		var/delta_g = -strength * _applied_lum_g
		var/delta_b = -strength * _applied_lum_b
		ADD_CORNER_LUM(corner, delta_r, delta_g, delta_b)
		LAZYREMOVE(corner.affecting, src)

	effect_str = null

/datum/light_source/proc/recalc_corner(datum/lighting_corner/corner)
	SETUP_CORNERS_CACHE
	LAZYINITLIST(effect_str)
	var/old_strength = effect_str[corner] || 0
	var/strength = LUM_FALLOFF(corner) * _light_power
	effect_str[corner] = strength
	var/delta_r = (strength * _lum_r) - (old_strength * _applied_lum_r)
	var/delta_g = (strength * _lum_g) - (old_strength * _applied_lum_g)
	var/delta_b = (strength * _lum_b) - (old_strength * _applied_lum_b)
	ADD_CORNER_LUM(corner, delta_r, delta_g, delta_b)

/datum/light_source/proc/update_corners()
	var/update = FALSE
	var/atom/source_atom = src.source_atom

	if(QDELETED(source_atom))
		qdel(src)
		return

	if(source_atom.light_power != light_power)
		light_power = source_atom.light_power
		update = TRUE

	if(source_atom.light_range != light_range)
		light_range = source_atom.light_range
		update = TRUE

	if(!top_atom)
		top_atom = source_atom
		update = TRUE

	if(!light_range || !light_power)
		qdel(src)
		return

	if(isturf(top_atom))
		if(source_turf != top_atom)
			source_turf = top_atom
			pixel_turf = source_turf
			update = TRUE
	else if(top_atom.loc != source_turf)
		source_turf = top_atom.loc
		pixel_turf = get_turf_pixel(top_atom)
		update = TRUE
	else
		var/pixel_loc = get_turf_pixel(top_atom)
		if(pixel_loc != pixel_turf)
			pixel_turf = pixel_loc
			update = TRUE

	if(!isturf(source_turf))
		if(applied)
			remove_lum()
		return

	if(light_range && light_power && !applied)
		update = TRUE

	if(source_atom.light_color != light_color)
		light_color = source_atom.light_color
		PARSE_LIGHT_COLOR(src)
		update = TRUE

	else if(applied_lum_r != lum_r || applied_lum_g != lum_g || applied_lum_b != lum_b)
		update = TRUE

	if(update)
		needs_update = LIGHTING_CHECK_UPDATE
		applied = TRUE
		if(source_atom)
			source_atom.update_bloom()
	else if(needs_update == LIGHTING_CHECK_UPDATE)
		return //nothing's changed

	// A corner is shared by up to four turfs, so the same corner comes up more than once.
	// Stamping each corner the first time we see it is a lot cheaper than filtering duplicates with an associative list.
	var/stamp = SSlighting.get_update_stamp()
	var/list/datum/lighting_corner/corners = list()
	var/light_reach = CEILING(light_range, 1)
	var/oldlum = source_turf.luminosity
	source_turf.luminosity = light_reach
	for(var/turf/T in view(light_reach, source_turf))
		if(IS_OPAQUE_TURF(T))
			continue
		if(!T.lighting_corners_initialised)
			T.generate_missing_corners()
		GATHER_CORNER(T.lighting_corner_NE)
		GATHER_CORNER(T.lighting_corner_SE)
		GATHER_CORNER(T.lighting_corner_SW)
		GATHER_CORNER(T.lighting_corner_NW)
	source_turf.luminosity = oldlum

	SETUP_CORNERS_CACHE
	LAZYINITLIST(effect_str)
	var/list/datum/lighting_corner/effect = effect_str
	var/vis_update = (needs_update == LIGHTING_VIS_UPDATE)
	var/list/datum/lighting_corner/gone_corners
	for(var/datum/lighting_corner/corner as anything in corners)
		var/old_strength = effect[corner]
		if(isnull(old_strength))
			old_strength = 0
		else if(vis_update) // Visibility update, the corners we already light don't need recalculating
			continue
		var/strength = LUM_FALLOFF(corner) * _light_power
		if(!strength)
			if(old_strength)
				LAZYADD(gone_corners, corner)
			continue
		if(!old_strength)
			LAZYADD(corner.affecting, src)
		effect[corner] = strength
		var/delta_r = (strength * _lum_r) - (old_strength * _applied_lum_r)
		var/delta_g = (strength * _lum_g) - (old_strength * _applied_lum_g)
		var/delta_b = (strength * _lum_b) - (old_strength * _applied_lum_b)
		ADD_CORNER_LUM(corner, delta_r, delta_g, delta_b)

	// Anything we lit last update that didn't get stamped this time is out of view now
	for(var/datum/lighting_corner/corner as anything in effect)
		if(corner.update_stamp != stamp)
			LAZYADD(gone_corners, corner)

	for(var/datum/lighting_corner/corner as anything in gone_corners)
		var/strength = effect[corner]
		var/delta_r = -strength * _applied_lum_r
		var/delta_g = -strength * _applied_lum_g
		var/delta_b = -strength * _applied_lum_b
		ADD_CORNER_LUM(corner, delta_r, delta_g, delta_b)
		LAZYREMOVE(corner.affecting, src)
	if(gone_corners)
		effect -= gone_corners

	applied_lum_r = lum_r
	applied_lum_g = lum_g
	applied_lum_b = lum_b

	UNSETEMPTY(effect_str)

#undef EFFECT_UPDATE
#undef SETUP_CORNERS_REMOVAL_CACHE
#undef SETUP_CORNERS_CACHE
#undef LUM_FALLOFF
#undef ADD_CORNER_LUM
#undef GATHER_CORNER
