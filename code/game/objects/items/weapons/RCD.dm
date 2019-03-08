/*
CONTAINS:
RCD // no fucking shit sherlock
*/
#define RCD_PAGE_MAIN 1
#define RCD_PAGE_AIRLOCK 2

#define RCD_MODE_TURF		"Turf"
#define RCD_MODE_AIRLOCK	"Airlock"
#define RCD_MODE_DECON		"Deconstruct"
#define RCD_MODE_WINDOW		"Windows"

GLOBAL_LIST_INIT(rcd_door_types, list(
	/obj/machinery/door/airlock = "Standard",					/obj/machinery/door/airlock/glass = "Standard (Glass)",
	/obj/machinery/door/airlock/command = "Command",			/obj/machinery/door/airlock/command/glass = "Command (Glass)",
	/obj/machinery/door/airlock/security = "Security",			/obj/machinery/door/airlock/security/glass = "Security (Glass)",
	/obj/machinery/door/airlock/engineering = "Engineering",	/obj/machinery/door/airlock/engineering/glass = "Engineering (Glass)",
	/obj/machinery/door/airlock/medical = "Medical",			/obj/machinery/door/airlock/medical/glass = "Medical (Glass)",
	/obj/machinery/door/airlock/maintenance = "Maintenance",	/obj/machinery/door/airlock/maintenance/glass = "Maintenance (Glass)",
	/obj/machinery/door/airlock/external = "External",			/obj/machinery/door/airlock/external/glass = "External (Glass)",
	/obj/machinery/door/airlock/maintenance/external = "External Maintenance",
		/obj/machinery/door/airlock/maintenance/external/glass = "External Maintenance (Glass)",
	/obj/machinery/door/airlock/freezer = "Freezer",
	/obj/machinery/door/airlock/mining = "Mining",		/obj/machinery/door/airlock/mining/glass = "Mining (Glass)",
	/obj/machinery/door/airlock/research = "Research",	/obj/machinery/door/airlock/research/glass = "Research (Glass)",
	/obj/machinery/door/airlock/atmos = "Atmospherics",	/obj/machinery/door/airlock/atmos/glass = "Atmospherics (Glass)",
	/obj/machinery/door/airlock/science = "Science",	/obj/machinery/door/airlock/science/glass = "Science (Glass)",
	/obj/machinery/door/airlock/hatch = "Airtight Hatch",
	/obj/machinery/door/airlock/maintenance_hatch = "Maintenance Hatch"
))

/obj/item/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build and deconstruct walls, floors and airlocks."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0
	flags = CONDUCT | NOBLUDGEON
	force = 0
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL = 30000)
	origin_tech = "engineering=4;materials=2"
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'
	flags_2 = NO_MAT_REDEMPTION_2
	req_access = list(access_engine)

	// Important shit
	var/datum/effect_system/spark_spread/spark_system
	var/matter = 0
	var/max_matter = 100
	var/mode = RCD_MODE_TURF
	var/canRwall = 0

	// UI shit
	var/menu = RCD_PAGE_MAIN
	var/locked = TRUE
	var/door_type = /obj/machinery/door/airlock
	var/door_name = "Airlock"
	var/list/door_accesses = list()
	var/list/door_accesses_list = list()
	var/one_access

	// Stupid shit
	var/static/allowed_targets = list(/turf, /obj/structure/grille, /obj/structure/window, /obj/structure/lattice, /obj/machinery/door/airlock)

/obj/item/rcd/Initialize()
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	GLOB.rcd_list += src

	door_accesses_list = list()
	for(var/access in get_all_accesses())
		door_accesses_list[++door_accesses_list.len] = list("name" = get_access_desc(access), "id" = access, "enabled" = (access in door_accesses))

/obj/item/rcd/examine(mob/user)
	. = ..()
	to_chat(user, "MATTER: [matter]/[max_matter] matter-units.")
	to_chat(user, "MODE: [mode].")

/obj/item/rcd/Destroy()
	QDEL_NULL(spark_system)
	GLOB.rcd_list -= src
	return ..()

/obj/item/rcd/proc/get_airlock_image(airlock_type)
	var/obj/machinery/door/airlock/proto = airlock_type
	var/ic = initial(proto.icon)
	var/mutable_appearance/MA = mutable_appearance(ic, "closed")
	if(!initial(proto.glass))
		MA.overlays += "fill_closed"
	// Not scaling these down to button size because they look horrible then, instead just bumping up radius.
	return MA

/obj/item/rcd/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/rcd/attackby(obj/item/W, mob/user, params)
	..()

	if(istype(W, /obj/item/rcd_ammo))
		var/obj/item/rcd_ammo/R = W
		if((matter + R.ammoamt) > max_matter)
			to_chat(user, "<span class='notice'>The RCD can't hold any more matter-units.</span>")
			return
		matter += R.ammoamt
		if(!user.unEquip(R))
			to_chat(user, "<span class='warning'>[R] is stuck to your hand!</span>")
			return
		qdel(R)
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, "<span class='notice'>The RCD now holds [matter]/[max_matter] matter-units.</span>")
		SSnanoui.update_uis(src)

/obj/item/rcd/proc/radial_menu(mob/user)
	if(!check_menu(user))
		return
	var/list/choices = list(
		RCD_MODE_AIRLOCK = image(icon = 'icons/obj/interface.dmi', icon_state = "airlock"),
		RCD_MODE_DECON = image(icon = 'icons/obj/interface.dmi', icon_state = "delete"),
		RCD_MODE_WINDOW = image(icon = 'icons/obj/interface.dmi', icon_state = "grillewindow"),
		RCD_MODE_TURF = image(icon = 'icons/obj/interface.dmi', icon_state = "wallfloor"),
		"UI" = image(icon = 'icons/obj/interface.dmi', icon_state = "ui_interact")
	)
	if(mode == RCD_MODE_AIRLOCK)
		choices += list(
			"Change Access" = image(icon = 'icons/obj/interface.dmi', icon_state = "access"),
			"Change Airlock Type" = image(icon = 'icons/obj/interface.dmi', icon_state = "airlocktype")
		)
	choices -= mode // Get rid of the current mode, clicking it won't do anything.
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, .proc/check_menu, user))
	if(!check_menu(user))
		return
	switch(choice)
		if(RCD_MODE_AIRLOCK, RCD_MODE_DECON, RCD_MODE_WINDOW, RCD_MODE_TURF)
			mode = choice
		if("UI")
			menu = RCD_PAGE_MAIN
			ui_interact(user)
			return
		if("Change Access", "Change Airlock Type")
			menu = RCD_PAGE_AIRLOCK
			ui_interact(user)
			return
		else
			return
	playsound(src, 'sound/effects/pop.ogg', 50, 0)
	to_chat(user, "<span class='notice'>You change [src]'s mode to '[choice]'.</span>")


/obj/item/rcd/attack_self(mob/user)
	//Change the mode // Oh I thought the UI was just for fucking staring at
	radial_menu(user)

/obj/item/rcd/attack_self_tk(mob/user)
	radial_menu(user)

/obj/item/rcd/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = inventory_state)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "rcd.tmpl", "[name]", 450, 400, state = state)
		ui.open()
		ui.set_auto_update(1)

/obj/item/rcd/ui_data(mob/user, ui_key = "main", datum/topic_state/state = inventory_state)
	var/data[0]
	data["mode"] = mode
	data["door_type"] = door_type
	data["door_name"] = door_name
	data["menu"] = menu
	data["matter"] = matter
	data["max_matter"] = max_matter
	data["one_access"] = one_access
	data["locked"] = locked

	if(menu == RCD_PAGE_AIRLOCK)
		var/list/door_types_list = list()
		for(var/type in GLOB.rcd_door_types)
			door_types_list[++door_types_list.len] = list("name" = GLOB.rcd_door_types[type], "type" = type)
		data["allowed_door_types"] = door_types_list

		data["door_accesses"] = door_accesses_list

	return data

/obj/item/rcd/Topic(href, href_list, nowindow, state)
	if(..())
		return 1

	if(prob(20))
		spark_system.start()

	if(href_list["mode"])
		mode = href_list["mode"]
		. = 1

	if(href_list["door_type"])
		var/new_door_type = text2path(href_list["door_type"])
		if(!(new_door_type in GLOB.rcd_door_types))
			message_admins("RCD Door HREF exploit attempted by [key_name(usr)]!")
			return
		door_type = new_door_type
		. = 1

	if(href_list["menu"])
		menu = text2num(href_list["menu"])
		. = 1

	if(href_list["login"])
		if(allowed(usr))
			locked = FALSE
		. = 1

	if(href_list["logout"])
		locked = TRUE
		. = 1

	if(!locked)
		if(href_list["toggle_one_access"])
			one_access = !one_access
			. = 1

		if(href_list["toggle_access"])
			var/href_access = text2num(href_list["toggle_access"])
			if(href_access in door_accesses)
				door_accesses -= href_access
			else
				door_accesses += href_access
			door_accesses_list = list()
			for(var/access in get_all_accesses())
				door_accesses_list[++door_accesses_list.len] = list("name" = get_access_desc(access), "id" = access, "enabled" = (access in door_accesses))
			. = 1

		if(href_list["choice"])
			var/temp_t = sanitize(copytext(input("Enter a custom Airlock Name.", "Airlock Name"), 1, MAX_MESSAGE_LEN))
			if(temp_t)
				door_name = temp_t

/obj/item/rcd/proc/mode_turf(atom/A, mob/user)
	if(isspaceturf(A) || istype(A, /obj/structure/lattice))
		if(useResource(1, user))
			to_chat(user, "Building Floor...")
			playsound(loc, usesound, 50, 1)
			var/turf/AT = get_turf(A)
			AT.ChangeTurf(/turf/simulated/floor/plating)
			return TRUE
		to_chat(user, "<span class='warning'>ERROR! Not enough matter in unit to construct this floor!</span>")
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		return FALSE

	if(isfloorturf(A))
		if(checkResource(3, user))
			to_chat(user, "Building Wall...")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 20 * toolspeed, target = A))
				if(!useResource(3, user))
					return FALSE
				playsound(loc, usesound, 50, 1)
				var/turf/AT = A
				AT.ChangeTurf(/turf/simulated/wall)
				return TRUE
			return FALSE
		to_chat(user, "<span class='warning'>ERROR! Not enough matter in unit to construct this wall!</span>")
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		return FALSE
	to_chat(user, "<span class='warning'>ERROR! Location unsuitable for wall construction!</span>")
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	return FALSE

/obj/item/rcd/proc/mode_airlock(atom/A, mob/user)
	if(isfloorturf(A))
		if(checkResource(10, user))
			to_chat(user, "Building Airlock...")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 50 * toolspeed, target = A))
				if(locate(/obj/machinery/door/airlock) in A.contents)
					return FALSE
				if(!useResource(10, user))
					return FALSE
				playsound(loc, usesound, 50, 1)
				var/obj/machinery/door/airlock/T = new door_type(A)
				T.name = door_name
				T.autoclose = TRUE
				if(one_access)
					T.req_one_access = door_accesses.Copy()
				else
					T.req_access = door_accesses.Copy()
				return FALSE
			return FALSE
		to_chat(user, "<span class='warning'>ERROR! Not enough matter in unit to construct this airlock!</span>")
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		return FALSE
	to_chat(user, "<span class='warning'>ERROR! Location unsuitable for airlock construction!</span>")
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	return FALSE

/obj/item/rcd/proc/mode_decon(atom/A, mob/user)
	if(iswallturf(A))
		if(istype(A, /turf/simulated/wall/r_wall) && !canRwall)
			return FALSE
		if(checkResource(5, user))
			to_chat(user, "Deconstructing Wall...")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 40 * toolspeed, target = A))
				if(!useResource(5, user))
					return FALSE
				playsound(loc, usesound, 50, 1)
				var/turf/AT = A
				AT.ChangeTurf(/turf/simulated/floor/plating)
				return TRUE
			return FALSE
		to_chat(user, "<span class='warning'>ERROR! Not enough matter in unit to deconstruct this wall!</span>")
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		return FALSE

	if(isfloorturf(A))
		if(checkResource(5, user))
			to_chat(user, "Deconstructing Floor...")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 50 * toolspeed, target = A))
				if(!useResource(5, user))
					return FALSE
				playsound(loc, usesound, 50, 1)
				var/turf/AT = A
				AT.ChangeTurf(/turf/space)
				return TRUE
			return FALSE
		to_chat(user, "<span class='warning'>ERROR! Not enough matter in unit to deconstruct this floor!</span>")
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		return FALSE

	if(istype(A, /obj/machinery/door/airlock))
		if(checkResource(20, user))
			to_chat(user, "Deconstructing Airlock...")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, 50 * toolspeed, target = A))
				if(!useResource(20, user))
					return FALSE
				playsound(loc, usesound, 50, 1)
				qdel(A)
				return TRUE
			return FALSE
		to_chat(user, "<span class='warning'>ERROR! Not enough matter in unit to deconstruct this airlock!</span>")
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		return FALSE

	if(istype(A, /obj/structure/window)) // You mean the grille of course, do you?
		A = locate(/obj/structure/grille) in A.loc
	if(istype(A, /obj/structure/grille))
		if(!checkResource(2, user))
			to_chat(user, "<span class='warning'>ERROR! Not enough matter in unit to deconstruct this window!</span>")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			return 0
		to_chat(user, "Deconstructing window...")
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		if(!do_after(user, 20 * toolspeed, target = A))
			return 0
		if(!useResource(2, user))
			return 0
		playsound(loc, usesound, 50, 1)
		var/turf/T1 = get_turf(A)
		QDEL_NULL(A)
		for(var/obj/structure/window/W in T1.contents)
			qdel(W)
		for(var/cdir in cardinal)
			var/turf/T2 = get_step(T1, cdir)
			if(locate(/obj/structure/window/full/shuttle) in T2)
				continue // Shuttle windows? Nah. We don't need extra windows there.
			if(!(locate(/obj/structure/grille) in T2))
				continue
			for(var/obj/structure/window/W in T2)
				if(W.dir == turn(cdir, 180))
					qdel(W)
			var/obj/structure/window/reinforced/W = new(T2)
			W.dir = turn(cdir, 180)
		return TRUE
	return FALSE

/obj/item/rcd/proc/mode_window(atom/A, mob/user)
	if(isfloorturf(A))
		if(locate(/obj/structure/grille) in A)
			return 0 // We already have window
		if(!checkResource(2, user))
			to_chat(user, "<span class='warning'>ERROR! Not enough matter in unit to construct this window!</span>")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			return 0
		to_chat(user, "Constructing window...")
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		if(!do_after(user, 20 * toolspeed, target = A))
			return 0
		if(locate(/obj/structure/grille) in A)
			return 0 // We already have window
		if(!useResource(2, user))
			return 0
		playsound(loc, usesound, 50, 1)
		new /obj/structure/grille(A)
		for(var/obj/structure/window/W in A)
			qdel(W)
		for(var/cdir in cardinal)
			var/turf/T = get_step(A, cdir)
			if(locate(/obj/structure/grille) in T)
				for(var/obj/structure/window/W in T)
					if(W.dir == turn(cdir, 180))
						qdel(W)
			else // Build a window!
				var/obj/structure/window/reinforced/W = new(A)
				W.dir = cdir
		var/turf/AT = A
		AT.ChangeTurf(/turf/simulated/floor/plating) // Platings go under windows.
		return 1
	to_chat(user, "<span class='warning'>ERROR! Location unsuitable for window construction!</span>")
	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	return 0

/obj/item/rcd/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return FALSE
	if(istype(A, /turf/space/transit))
		return FALSE
	if(!is_type_in_list(A, allowed_targets))
		return FALSE

	switch(mode)
		if(RCD_MODE_TURF)
			. = mode_turf(A, user)
		if(RCD_MODE_AIRLOCK)
			. = mode_airlock(A, user)
		if(RCD_MODE_DECON)
			. = mode_decon(A, user)
		if(RCD_MODE_WINDOW)
			. = mode_window(A, user)
		else
			to_chat(user, "ERROR: RCD in MODE: [mode] attempted use by [user]. Send this text #coderbus or an admin.")
			. = 0

	SSnanoui.update_uis(src)

/obj/item/rcd/proc/useResource(amount, mob/user)
	if(matter < amount)
		return 0
	matter -= amount
	SSnanoui.update_uis(src)
	return 1

/obj/item/rcd/proc/checkResource(amount, mob/user)
	return matter >= amount

/obj/item/rcd/borg
	canRwall = 1
	var/use_multiplier = 160

/obj/item/rcd/borg/syndicate
	use_multiplier = 80

/obj/item/rcd/borg/useResource(amount, mob/user)
	if(!isrobot(user))
		return 0
	var/mob/living/silicon/robot/R = user
	return R.cell.use(amount * use_multiplier)

/obj/item/rcd/borg/checkResource(amount, mob/user)
	if(!isrobot(user))
		return 0
	var/mob/living/silicon/robot/R = user
	return R.cell.charge >= (amount * use_multiplier)

/obj/item/rcd/proc/detonate_pulse()
	audible_message("<span class='danger'><b>[src] begins to vibrate and \
		buzz loudly!</b></span>","<span class='danger'><b>[src] begins \
		vibrating violently!</b></span>")
	// 5 seconds to get rid of it
	addtimer(CALLBACK(src, .proc/detonate_pulse_explode), 50)

/obj/item/rcd/proc/detonate_pulse_explode()
	explosion(src, 0, 0, 3, 1, flame_range = 1)
	qdel(src)

/obj/item/rcd/preloaded
	matter = 100

/obj/item/rcd/combat
	name = "combat RCD"
	max_matter = 500
	matter = 500
	canRwall = 1

/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	origin_tech = "materials=3"
	materials = list(MAT_METAL=16000, MAT_GLASS=8000)
	var/ammoamt = 20

/obj/item/rcd_ammo/large
	ammoamt = 100
