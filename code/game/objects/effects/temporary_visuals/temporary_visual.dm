//temporary visual effects
/obj/effect/overlay/temp
	anchored = 1
	layer = ABOVE_MOB_LAYER
	mouse_opacity = 0
	var/duration = 10
	var/randomdir = TRUE

/obj/effect/overlay/temp/New()
	if(randomdir)
		setDir(pick(cardinal))

	QDEL_IN(src, duration)

/obj/effect/overlay/temp/singularity_act()
	return

/obj/effect/overlay/temp/singularity_pull()
	return

/obj/effect/overlay/temp/ex_act()
	return

/obj/effect/overlay/temp/dir_setting
	randomdir = FALSE

/obj/effect/overlay/temp/dir_setting/New(loc, set_dir)
	if(set_dir)
		setDir(set_dir)
	..()