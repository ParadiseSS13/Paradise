/mob/living/silicon/robot/gib()
	//robots don't die when gibbed. instead they drop their MMI'd brain
	var/atom/movable/overlay/animation = null
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	playsound(src.loc, 'sound/goonstation/effects/robogib.ogg', 50, 1)

	flick("gibbed-r", animation)
	robogibs(loc)

	GLOB.living_mob_list -= src
	GLOB.dead_mob_list -= src
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/silicon/robot/dust()
	death(1)
	var/atom/movable/overlay/animation = null
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	flick("dust-r", animation)
	new /obj/effect/decal/remains/robot(loc)
	if(mmi)		qdel(mmi)	//Delete the MMI first so that it won't go popping out.

	GLOB.dead_mob_list -= src
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)


/mob/living/silicon/robot/death(gibbed)
	if(can_die())
		if(!gibbed)
			emote("deathgasp")

		if(module)
			module.handle_death(gibbed)

	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE

	diag_hud_set_status()
	diag_hud_set_health()
	if(camera)
		camera.status = 0
	update_headlamp(1) //So borg lights are disabled when killed.

	if(in_contents_of(/obj/machinery/recharge_station))//exit the recharge station
		var/obj/machinery/recharge_station/RC = loc
		RC.go_out()

	update_icons()

	sql_report_cyborg_death(src)
