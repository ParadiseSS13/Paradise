/**
  * Internal atom that copies an appearance on to the blocker plane
  *
  * This means that the atom in question will block any emissive sprites.
  * This should only be used internally. If you are directly creating more of these,
  * you're almost guaranteed to be doing something wrong.
  */
/atom/movable/emissive_blocker
	name = "emissive blocker"
	plane = EMISSIVE_PLANE
	layer = FLOAT_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = EMISSIVE_APPEARANCE_FLAGS

/atom/movable/emissive_blocker/Initialize(mapload, source)
	. = ..()
	verbs.Cut() //Cargo culting from lighting object, this maybe affects memory usage?

	render_source = source
	color = EM_BLOCK_COLOR

/atom/movable/emissive_blocker/ex_act(severity)
	return FALSE

/atom/movable/emissive_blocker/singularity_act()
	return

/atom/movable/emissive_blocker/singularity_pull()
	return

/atom/movable/emissive_blocker/blob_act()
	return

/atom/movable/emissive_blocker/onTransitZ()
	return

//Prevents people from moving these after creation, because they shouldn't be.
/atom/movable/emissive_blocker/forceMove(atom/destination, no_tp = FALSE, harderforce = FALSE)
	if(harderforce)
		return ..()
