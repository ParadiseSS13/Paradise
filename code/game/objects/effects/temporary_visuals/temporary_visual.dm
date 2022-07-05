//temporary visual effects
/obj/effect/temp_visual
	icon_state = "nothing"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/duration = 10 //in deciseconds
	var/randomdir = TRUE
	var/timerid

/obj/effect/temp_visual/Initialize(mapload)
	. = ..()
	if(randomdir)
		setDir(pick(GLOB.cardinal))

	timerid = QDEL_IN(src, duration)

/obj/effect/temp_visual/Destroy()
	. = ..()
	deltimer(timerid)

/obj/effect/temp_visual/singularity_act()
	return

/obj/effect/temp_visual/singularity_pull()
	return

/obj/effect/temp_visual/ex_act()
	return

/obj/effect/temp_visual/dir_setting
	randomdir = FALSE

/obj/effect/temp_visual/dir_setting/Initialize(mapload, set_dir)
	if(set_dir)
		setDir(set_dir)
	. = ..()

/obj/effect/temp_visual/target_angled
	randomdir = FALSE

/obj/effect/temp_visual/target_angled/Initialize(mapload, atom/target)
	. = ..()
	if(target)
		var/matrix/M = new
		M.Turn(get_angle(src, target))
		transform = M
