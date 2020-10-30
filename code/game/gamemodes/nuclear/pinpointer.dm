/obj/item/pinpointer
	name = "pinpointer"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinoff"
	flags = CONDUCT
	slot_flags = SLOT_PDA | SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_METAL=500)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/obj/item/disk/nuclear/the_disk = null
	var/obj/machinery/nuclearbomb/the_bomb = null
	var/obj/machinery/nuclearbomb/syndicate/the_s_bomb = null // used by syndicate pinpointers.
	var/active = 0
	var/mode = FALSE // Mode 0 locates disk, mode 1 does something else.
	var/shows_nuke_timer = TRUE
	var/syndicate = FALSE // Indicates pointer is syndicate, and points to the syndicate nuke.
	var/icon_off = "pinoff"
	var/icon_null = "pinonnull"
	var/icon_direct = "pinondirect"
	var/icon_close = "pinonclose"
	var/icon_medium = "pinonmedium"
	var/icon_far = "pinonfar"

/obj/item/pinpointer/New()
	..()
	GLOB.pinpointer_list += src

/obj/item/pinpointer/Destroy()
	GLOB.pinpointer_list -= src
	active = 0
	the_disk = null
	return ..()

/obj/item/pinpointer/attack_self()
	if(active == 0)
		active = 1
		mode = FALSE
		workdisk()
		to_chat(usr, "<span class='notice'>Authentication Disk Locator active.</span>")
	else if(active == 1 && shows_nuke_timer)
		active = 2
		mode = TRUE
		workbomb()
		to_chat(usr, "<span class='notice'>Nuclear Device Locator active.</span>")
	else
		active = 0
		icon_state = icon_off
		to_chat(usr, "<span class='notice'>You deactivate the pinpointer.</span>")

/obj/item/pinpointer/proc/scandisk()
	if(!the_disk)
		the_disk = locate()

/obj/item/pinpointer/proc/scanbomb()
	if(!syndicate)
		if(!the_bomb)
			the_bomb = locate()
	else
		if(!the_s_bomb)
			the_s_bomb = locate()

/obj/item/pinpointer/proc/point_at(atom/target, spawnself = 1)
	if(!active)
		return
	if(!target)
		icon_state = icon_null
		return

	var/turf/T = get_turf(target)
	var/turf/L = get_turf(src)

	if(!(T && L) || (T.z != L.z))
		icon_state = icon_null
	else
		dir = get_dir(L, T)
		switch(get_dist(L, T))
			if(-1)
				icon_state = icon_direct
			if(1 to 8)
				icon_state = icon_close
			if(9 to 16)
				icon_state = icon_medium
			if(16 to INFINITY)
				icon_state = icon_far
	if(spawnself)
		spawn(5)
			.()

/obj/item/pinpointer/proc/workdisk()
	if(!mode)
		scandisk()
		point_at(the_disk, FALSE)
		spawn(5)
			.()

/obj/item/pinpointer/proc/workbomb()
	if(mode)
		if(!syndicate)
			scanbomb()
			point_at(the_bomb, FALSE)
			spawn(5)
				.()
		else
			scanbomb()
			point_at(the_s_bomb, FALSE)
			spawn(5)
				.()

/obj/item/pinpointer/examine(mob/user)
	. = ..()
	if(shows_nuke_timer)
		for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
			if(bomb.timing)
				. += "Extreme danger.  Arming signal detected.   Time remaining: [bomb.timeleft]"

/obj/item/pinpointer/advpinpointer
	name = "advanced pinpointer"
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."
	var/modelocked = FALSE // If true, user cannot change mode.
	var/turf/location = null
	var/obj/target = null

/obj/item/pinpointer/advpinpointer/attack_self()
	if(!active)
		active = 1
		if(mode == 0)
			workdisk()
		if(mode == 1)
			point_at(location)
		if(mode == 2)
			point_at(target)
		to_chat(usr, "<span class='notice'>You activate the pinpointer.</span>")
	else
		active = 0
		icon_state = icon_off
		to_chat(usr, "<span class='notice'>You deactivate the pinpointer.</span>")

/obj/item/pinpointer/advpinpointer/workdisk()
	if(mode == FALSE)
		scandisk()
		point_at(the_disk, FALSE)
		spawn(5)
			.()

/obj/item/pinpointer/advpinpointer/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in usr

	if(usr.stat || usr.restrained())
		return

	if(modelocked)
		to_chat(usr, "<span class='warning'>[src] is locked. It can only track one specific target.</span>")
		return

	active = 0
	icon_state = icon_off
	target = null
	location = null

	switch(alert("Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", "Location", "Disk Recovery", "Other Signature"))
		if("Location")
			mode = 1

			var/locationx = input(usr, "Please input the x coordinate to search for.", "Location?" , "") as num
			if(!locationx || !(usr in view(1,src)))
				return
			var/locationy = input(usr, "Please input the y coordinate to search for.", "Location?" , "") as num
			if(!locationy || !(usr in view(1,src)))
				return

			var/turf/Z = get_turf(src)

			location = locate(locationx,locationy,Z.z)

			to_chat(usr, "<span class='notice'>You set the pinpointer to locate [locationx],[locationy]</span>")


			return attack_self()

		if("Disk Recovery")
			mode = 0
			return attack_self()

		if("Other Signature")
			mode = 2
			switch(alert("Search for item signature or DNA fragment?" , "Signature Mode Select" , "Item" , "DNA"))
				if("Item")
					var/list/item_names[0]
					var/list/item_paths[0]
					for(var/objective in GLOB.potential_theft_objectives)
						var/datum/theft_objective/T = objective
						var/name = initial(T.name)
						item_names += name
						item_paths[name] = initial(T.typepath)
					var/targetitem = input("Select item to search for.", "Item Mode Select","") as null|anything in item_names
					if(!targetitem)
						return

					var/list/target_candidates = get_all_of_type(item_paths[targetitem], subtypes = TRUE)
					for(var/obj/item/candidate in target_candidates)
						if(!is_admin_level((get_turf(candidate)).z))
							target = candidate
							break

					if(!target)
						to_chat(usr, "<span class='warning'>Failed to locate [targetitem]!</span>")
						return
					to_chat(usr, "<span class='notice'>You set the pinpointer to locate [targetitem].</span>")
				if("DNA")
					var/DNAstring = input("Input DNA string to search for." , "Please Enter String." , "")
					if(!DNAstring)
						return
					for(var/mob/living/carbon/C in GLOB.mob_list)
						if(!C.dna)
							continue
						if(C.dna.unique_enzymes == DNAstring)
							target = C
							break

			return attack_self()

///////////////////////
//nuke op pinpointers//
///////////////////////
/obj/item/pinpointer/nukeop
	var/obj/docking_port/mobile/home = null
	slot_flags = SLOT_BELT | SLOT_PDA
	syndicate = TRUE

/obj/item/pinpointer/nukeop/attack_self(mob/user as mob)
	if(active == 0 && !mode)
		active = 1
		workdisk()
		to_chat(user, "<span class='notice'>Authentication Disk Locator active.</span>")
	else if(active == 1 && !mode)
		active = 2
		workbomb()
		to_chat(user, "<span class='notice'>Nuclear Device Locator active.</span>")
	else if(mode && !active)
		active = 1
		worklocation()
		to_chat(user, "<span class='notice'>Shuttle Locator active.</span>")
	else
		active = 0
		icon_state = icon_off
		to_chat(user, "<span class='notice'>You deactivate the pinpointer.</span>")

/obj/item/pinpointer/nukeop/workdisk()
	if(active != 1)
		return
	if(mode)		//Check in case the mode changes while operating
		worklocation()
		return
	if(GLOB.bomb_set)	//If the bomb is set, lead to the shuttle
		mode = TRUE	//Ensures worklocation() continues to work
		worklocation()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		visible_message("Shuttle Locator mode actived.")			//Lets the mob holding it know that the mode has changed
		active = 1
		return		//Get outta here
	scandisk()
	point_at(the_disk, FALSE)
	spawn(5)
		.()

/obj/item/pinpointer/nukeop/workbomb()
	if(active != 2)
		return
	if(mode)		//Check in case the mode changes while operating
		worklocation()
		return
	if(GLOB.bomb_set)	//If the bomb is set, lead to the shuttle
		mode = TRUE	//Ensures worklocation() continues to work
		worklocation()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		visible_message("Shuttle Locator mode actived.")			//Lets the mob holding it know that the mode has changed
		active = 1
		return		//Get outta here
	scanbomb()
	point_at(the_s_bomb, FALSE)
	spawn(5)
		.()

/obj/item/pinpointer/nukeop/proc/worklocation()
	if(active == 0)
		return
	if(!mode)
		active = 1
		workdisk()
		return
	if(!GLOB.bomb_set)
		mode = FALSE
		workdisk()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
		visible_message("<span class='notice'>Authentication Disk Locator mode actived.</span>")
		active = 1
		return
	if(!home)
		home = SSshuttle.getShuttle("syndicate")
		if(!home)
			icon_state = icon_null
			return
	if(loc.z != home.z)	//If you are on a different z-level from the shuttle
		icon_state = icon_null
	else
		point_at(home, FALSE)
		spawn(5)
			.()

/obj/item/pinpointer/operative
	name = "operative pinpointer"
	desc = "A pinpointer that leads to the first Syndicate operative detected."
	var/mob/living/carbon/nearest_op = null

/obj/item/pinpointer/operative/attack_self()
	if(!usr.mind || !(usr.mind in SSticker.mode.syndicates))
		to_chat(usr, "<span class='danger'>AUTHENTICATION FAILURE. ACCESS DENIED.</span>")
		return FALSE
	if(!active)
		active = 1
		workop()
		to_chat(usr, "<span class='notice'>You activate the pinpointer.</span>")
	else
		active = 0
		icon_state = icon_off
		to_chat(usr, "<span class='notice'>You deactivate the pinpointer.</span>")

/obj/item/pinpointer/operative/proc/scan_for_ops()
	if(active)
		nearest_op = null //Resets nearest_op every time it scans
		var/closest_distance = 1000
		for(var/mob/living/carbon/M in GLOB.mob_list)
			if(M.mind && (M.mind in SSticker.mode.syndicates))
				if(get_dist(M, get_turf(src)) < closest_distance) //Actually points toward the nearest op, instead of a random one like it used to
					nearest_op = M

/obj/item/pinpointer/operative/proc/workop()
	if(active)
		scan_for_ops()
		point_at(nearest_op, FALSE)
		spawn(5)
			.()
	else
		return FALSE

/obj/item/pinpointer/operative/examine(mob/user)
	. = ..()
	if(active)
		if(nearest_op)
			. += "Nearest operative detected is <i>[nearest_op.real_name].</i>"
		else
			. += "No operatives detected within scanning range."

/obj/item/pinpointer/crew
	name = "crew pinpointer"
	desc = "A handheld tracking device that points to crew suit sensors."
	shows_nuke_timer = FALSE
	icon_state = "pinoff_crew"
	icon_off = "pinoff_crew"
	icon_null = "pinonnull_crew"
	icon_direct = "pinondirect_crew"
	icon_close = "pinonclose_crew"
	icon_medium = "pinonmedium_crew"
	icon_far = "pinonfar_crew"

/obj/item/pinpointer/crew/proc/trackable(mob/living/carbon/human/H)
	var/turf/here = get_turf(src)
	if(istype(H.w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = H.w_uniform

		// Suit sensors must be on maximum.
		if(!U.has_sensor || U.sensor_mode < 3)
			return FALSE

		var/turf/there = get_turf(U)
		return there && there.z == here.z

	return FALSE

/obj/item/pinpointer/crew/attack_self(mob/living/user)
	if(active)
		active = 0
		icon_state = icon_off
		user.visible_message("<span class='notice'>[user] deactivates [user.p_their()] pinpointer.</span>", "<span class='notice'>You deactivate your pinpointer.</span>")
		return

	var/list/name_counts = list()
	var/list/names = list()

	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		if(!trackable(H))
			continue

		var/name = "Unknown"
		if(H.wear_id)
			var/obj/item/card/id/I = H.wear_id.GetID()
			if(I)
				name = I.registered_name

		while(name in name_counts)
			name_counts[name]++
			name = text("[] ([])", name, name_counts[name])
		names[name] = H
		name_counts[name] = 1

	if(!names.len)
		user.visible_message("<span class='notice'>[user]'s pinpointer fails to detect a signal.</span>", "<span class='notice'>Your pinpointer fails to detect a signal.</span>")
		return

	var/A = input(user, "Person to track", "Pinpoint") in names
	if(!src || !user || (user.get_active_hand() != src) || user.incapacitated() || !A)
		return

	var/target = names[A]
	active = 1
	user.visible_message("<span class='notice'>[user] activates [user.p_their()] pinpointer.</span>", "<span class='notice'>You activate your pinpointer.</span>")
	point_at(target)

/obj/item/pinpointer/crew/point_at(atom/target, spawnself = TRUE)
	if(!active)
		return

	if(!trackable(target) || !target)
		icon_state = icon_null
		return

	..(target, spawnself = FALSE)
	if(spawnself)
		spawn(5)
			.()

/obj/item/pinpointer/crew/centcom
	name = "centcom pinpointer"
	desc = "A handheld tracking device that tracks crew based on remote centcom sensors."

/obj/item/pinpointer/crew/centcom/trackable(mob/living/carbon/human/H)
	var/turf/here = get_turf(src)
	var/turf/there = get_turf(H)
	return there && there.z == here.z
