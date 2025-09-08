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

// Macro that applies light to a new corner.
// It is a macro in the interest of speed, yet not having to copy paste it.
// If you're wondering what's with the backslashes, the backslashes cause BYOND to not automatically end the line.
// As such this all gets counted as a single line.
// The braces and semicolons are there to be able to do this on a single line.
#define LUM_FALLOFF(C, T) (1 - CLAMP01(sqrt((C.x - T.x) ** 2 + (C.y - T.y) ** 2 + LIGHTING_HEIGHT) / max(1, light_range)))

#define APPLY_CORNER(C)							\
	. = LUM_FALLOFF(C, pixel_turf);				\
	. *= light_power;							\
	var/OLD = effect_str[C];					\
												\
	C.update_lumcount							\
	(											\
		(. * lum_r) - (OLD * applied_lum_r),	\
		(. * lum_g) - (OLD * applied_lum_g),	\
		(. * lum_b) - (OLD * applied_lum_b)		\
	);											\

#define REMOVE_CORNER(C)						\
	. = -effect_str[C];							\
	C.update_lumcount							\
	(											\
		. * applied_lum_r,						\
		. * applied_lum_g,						\
		. * applied_lum_b						\
	);

/// This is the define used to calculate falloff.
/datum/light_source/proc/remove_lum()
	applied = FALSE
	for(var/datum/lighting_corner/corner as anything in effect_str)
		REMOVE_CORNER(corner)
		LAZYREMOVE(corner.affecting, src)

	effect_str = null

/datum/light_source/proc/recalc_corner(datum/lighting_corner/corner)
	LAZYINITLIST(effect_str)
	if(effect_str[corner]) // Already have one.
		REMOVE_CORNER(corner)
		effect_str[corner] = 0

	APPLY_CORNER(corner)
	effect_str[corner] = .

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

	var/list/datum/lighting_corner/corners = list()
	var/list/turf/turfs = list()
	if(source_turf)
		var/oldlum = source_turf.luminosity
		source_turf.luminosity = CEILING(light_range, 1)
		for(var/turf/T in view(CEILING(light_range, 1), source_turf))
			if(!IS_OPAQUE_TURF(T))
				if(!T.lighting_corners_initialised)
					T.generate_missing_corners()
				corners[T.lighting_corner_NE] = 0
				corners[T.lighting_corner_SE] = 0
				corners[T.lighting_corner_SW] = 0
				corners[T.lighting_corner_NW] = 0
			turfs += T
		source_turf.luminosity = oldlum

	var/list/datum/lighting_corner/new_corners = (corners - effect_str)

	LAZYINITLIST(effect_str)
	if(needs_update == LIGHTING_VIS_UPDATE)
		for(var/datum/lighting_corner/corner as anything in new_corners)
			APPLY_CORNER(corner)
			if(. != 0)
				LAZYADD(corner.affecting, src)
				effect_str[corner] = .
	else
		for(var/datum/lighting_corner/corner as anything in new_corners)
			APPLY_CORNER(corner)
			if(. != 0)
				LAZYADD(corner.affecting, src)
				effect_str[corner] = .

		for(var/datum/lighting_corner/corner as anything in corners - new_corners) // Existing corners
			APPLY_CORNER(corner)
			if(. != 0)
				effect_str[corner] = .
			else
				LAZYREMOVE(corner.affecting, src)
				effect_str -= corner

	var/list/datum/lighting_corner/gone_corners = effect_str - corners
	for(var/datum/lighting_corner/corner as anything in gone_corners)
		REMOVE_CORNER(corner)
		LAZYREMOVE(corner.affecting, src)
	effect_str -= gone_corners

	applied_lum_r = lum_r
	applied_lum_g = lum_g
	applied_lum_b = lum_b

	UNSETEMPTY(effect_str)

#undef EFFECT_UPDATE
#undef LUM_FALLOFF
#undef REMOVE_CORNER
#undef APPLY_CORNER
