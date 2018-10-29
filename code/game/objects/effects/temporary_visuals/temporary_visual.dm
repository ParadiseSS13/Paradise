//temporary visual effects
/obj/effect/temp_visual
	anchored = 1
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/duration = 10
	var/randomdir = TRUE

/obj/effect/temp_visual/New()
	if(randomdir)
		setDir(pick(cardinal))

	QDEL_IN(src, duration)

/obj/effect/temp_visual/singularity_act()
	return

/obj/effect/temp_visual/singularity_pull()
	return

/obj/effect/temp_visual/ex_act()
	return

/obj/effect/temp_visual/dir_setting
	randomdir = FALSE

/obj/effect/temp_visual/dir_setting/New(loc, set_dir)
	if(set_dir)
		setDir(set_dir)
	..()