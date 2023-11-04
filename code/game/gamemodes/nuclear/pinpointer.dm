#define MODE_OFF 0
#define MODE_DISK 1
#define MODE_NUKE 2
#define MODE_ADV 3
#define MODE_SHIP 4
#define MODE_OPERATIVE 5
#define MODE_CREW 6
#define MODE_DET 7
#define MODE_TENDRIL 8
#define SETTING_DISK 0
#define SETTING_LOCATION 1
#define SETTING_OBJECT 2

/obj/item/pinpointer
	name = "pinpointer"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinoff"
	flags = CONDUCT
	slot_flags = SLOT_FLAG_PDA | SLOT_FLAG_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_METAL=500)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/obj/item/disk/nuclear/the_disk = null
	var/obj/machinery/nuclearbomb/the_bomb = null
	var/obj/machinery/nuclearbomb/syndicate/the_s_bomb = null // used by syndicate pinpointers.
	var/cur_index = 1 // Which index the current mode is
	var/mode = MODE_OFF // On which mode the pointer is at
	var/modes = list(MODE_DISK, MODE_NUKE) // Which modes are there
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
	STOP_PROCESSING(SSfastprocess, src)
	GLOB.pinpointer_list -= src
	mode = MODE_OFF
	the_disk = null
	return ..()

/obj/item/pinpointer/process()
	if(mode == MODE_DISK)
		workdisk()
	else if(mode == MODE_NUKE)
		workbomb()

/obj/item/pinpointer/attack_self(mob/user)
	if(mode == MODE_DET)
		return
	cycle(user)

/obj/item/pinpointer/proc/cycle(mob/user)
	if(cur_index > length(modes))
		mode = MODE_OFF
		to_chat(user, "<span class='notice'>You deactivate [src].</span>")
		STOP_PROCESSING(SSfastprocess, src)
		icon_state = icon_off
		cur_index = 1
		return
	if(cur_index == 1)
		START_PROCESSING(SSfastprocess, src)
	mode = modes[cur_index++]
	activate_mode(mode, user)
	to_chat(user, "<span class='notice'>[get_mode_text(mode)]</span>")

/obj/item/pinpointer/proc/get_mode_text(mode)
	switch(mode)
		if(MODE_DISK)
			return "Authentication Disk Locator active."
		if(MODE_NUKE)
			return "Nuclear Device Locator active."
		if(MODE_ADV)
			return "Advanced Pinpointer Online."
		if(MODE_SHIP)
			return "Shuttle Locator active."
		if(MODE_OPERATIVE)
			return "You point the pinpointer to the nearest operative."
		if(MODE_CREW)
			return "You turn on the pinpointer."
		if(MODE_TENDRIL)
			return "High energy scanner active"

/obj/item/pinpointer/proc/activate_mode(mode, mob/user) //for crew pinpointer
	return

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

/obj/item/pinpointer/proc/point_at_target(atom/target)
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

/obj/item/pinpointer/proc/workdisk()
	scandisk()
	point_at_target(the_disk)

/obj/item/pinpointer/proc/workbomb()
	if(!syndicate)
		scanbomb()
		point_at_target(the_bomb)
	else
		scanbomb()
		point_at_target(the_s_bomb)

/obj/item/pinpointer/examine(mob/user)
	. = ..()
	if(shows_nuke_timer)
		for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
			if(bomb.timing)
				. += "Extreme danger.  Arming signal detected.   Time remaining: [bomb.timeleft]"

/obj/item/pinpointer/advpinpointer
	name = "advanced pinpointer"
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal. \n \
			<span class='notice'>Alt-click to toggle mode.</span>"
	modes = list(MODE_ADV)
	var/modelocked = FALSE // If true, user cannot change mode.
	var/turf/location = null
	var/obj/target = null
	var/setting = 0

/obj/item/pinpointer/advpinpointer/process()
	switch(setting)
		if(SETTING_DISK)
			workdisk()
		if(SETTING_LOCATION)
			point_at_target(location)
		if(SETTING_OBJECT)
			point_at_target(target)

/obj/item/pinpointer/advpinpointer/workdisk() //since mode works diffrently for advpinpointer
	scandisk()
	point_at_target(the_disk)

/obj/item/pinpointer/advpinpointer/AltClick(mob/user)
	if(!isliving(user) || !Adjacent(user))
		return ..()
	toggle_mode()

/obj/item/pinpointer/advpinpointer/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in usr

	if(usr.stat || usr.restrained())
		return

	if(modelocked)
		to_chat(usr, "<span class='warning'>[src] is locked. It can only track one specific target.</span>")
		return

	target = null
	location = null

	switch(alert("Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", "Location", "Disk Recovery", "Other Signature"))
		if("Location")
			setting = SETTING_LOCATION

			var/locationx = input(usr, "Please input the x coordinate to search for.", "Location?" , "") as num
			if(!locationx || !(usr in view(1,src)))
				return
			var/locationy = input(usr, "Please input the y coordinate to search for.", "Location?" , "") as num
			if(!locationy || !(usr in view(1,src)))
				return

			var/turf/Z = get_turf(src)

			location = locate(locationx,locationy,Z.z)

			to_chat(usr, "<span class='notice'>You set the pinpointer to locate [locationx],[locationy]</span>")

			toggle_on()

		if("Disk Recovery")
			setting = SETTING_DISK
			toggle_on()

		if("Other Signature")
			setting = SETTING_OBJECT
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

					var/priority
					var/backup
					var/list/target_candidates = get_all_of_type(item_paths[targetitem], subtypes = TRUE)
					for(var/obj/item/candidate in target_candidates)
						var/cand_z = (get_turf(candidate)).z
						if(is_admin_level(cand_z))
							continue
						if(usr.z != cand_z)
							if(!backup)
								backup = candidate
							continue
						// no candidate set yet, or check if there is a closer one
						if(!priority || (get_dist(usr, candidate) < get_dist(usr, priority)))
							priority = candidate

					if(priority)
						target = priority
					else
						target = backup
						if(target)
							to_chat(usr, "<span class='notice'>Unable to find [targetitem] in this sector, falling back to off-sector tracking.</span>")

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

			toggle_on()

/obj/item/pinpointer/advpinpointer/proc/toggle_on()
	if(mode == MODE_OFF)
		cur_index = 1
		cycle(usr)

///////////////////////
//nuke op pinpointers//
///////////////////////
/obj/item/pinpointer/nukeop
	var/obj/docking_port/mobile/home = null
	slot_flags = SLOT_FLAG_BELT | SLOT_FLAG_PDA
	syndicate = TRUE
	modes = list(MODE_DISK, MODE_NUKE)

/obj/item/pinpointer/nukeop/process()
	switch(mode)
		if(MODE_DISK)
			workdisk()
		if(MODE_NUKE)
			workbomb()
		if(MODE_SHIP)
			worklocation()

/obj/item/pinpointer/nukeop/workdisk()
	if(GLOB.bomb_set)	//If the bomb is set, lead to the shuttle
		mode = MODE_SHIP	//Ensures worklocation() continues to work
		modes = list(MODE_SHIP)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		visible_message("Shuttle Locator mode actived.")			//Lets the mob holding it know that the mode has changed
		return		//Get outta here
	scandisk()
	point_at_target(the_disk)

/obj/item/pinpointer/nukeop/workbomb()
	if(GLOB.bomb_set)	//If the bomb is set, lead to the shuttle
		mode = MODE_SHIP	//Ensures worklocation() continues to work
		modes = list(MODE_SHIP)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		visible_message("Shuttle Locator mode actived.")			//Lets the mob holding it know that the mode has changed
		return		//Get outta here
	scanbomb()
	point_at_target(the_s_bomb)

/obj/item/pinpointer/nukeop/proc/worklocation()
	if(!GLOB.bomb_set)
		mode = MODE_DISK
		modes = list(MODE_DISK, MODE_NUKE)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
		visible_message("<span class='notice'>Authentication Disk Locator mode actived.</span>")
		return
	if(!home)
		home = SSshuttle.getShuttle("syndicate")
		if(!home)
			icon_state = icon_null
			return
	if(loc.z != home.z)	//If you are on a different z-level from the shuttle
		icon_state = icon_null
	else
		point_at_target(home)

/obj/item/pinpointer/operative
	name = "operative pinpointer"
	desc = "A pinpointer that leads to the first Syndicate operative detected."
	var/mob/living/carbon/nearest_op = null
	modes = list(MODE_OPERATIVE)

/obj/item/pinpointer/operative/process()
	if(mode == MODE_OPERATIVE)
		workop()
	else
		icon_state = icon_off

/obj/item/pinpointer/operative/proc/scan_for_ops()
	if(mode != MODE_OPERATIVE)
		return
	nearest_op = null //Resets nearest_op every time it scans

	var/closest_distance = 1000
	for(var/datum/mind/Mind in SSticker.mode.syndicates)
		var/mob/M = Mind.current
		if(!ishuman(M))
			continue
		var/current_dist = get_dist(M, get_turf(src))
		if(current_dist < closest_distance)
			nearest_op = M
			closest_distance = current_dist

/obj/item/pinpointer/operative/proc/workop()
	if(mode == MODE_OPERATIVE)
		scan_for_ops()
		point_at_target(nearest_op, FALSE)
	else
		return FALSE

/obj/item/pinpointer/operative/examine(mob/user)
	. = ..()
	if(mode == MODE_OPERATIVE)
		if(nearest_op)
			. += "Nearest operative detected is <i>[nearest_op.real_name].</i>"
		else
			. += "No operatives detected within scanning range."

/obj/item/pinpointer/operative/nad
	desc = "A pinpointer that leads to the first Syndicate operative detected. Also has a mode to point towards the NAD."
	modes = list(MODE_OPERATIVE, MODE_DISK)

/obj/item/pinpointer/operative/nad/process()
	switch(mode)
		if(MODE_DISK)
			workdisk()
		if(MODE_OPERATIVE)
			scan_for_ops()
			point_at_target(nearest_op, FALSE)

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
	modes = list(MODE_CREW)
	var/target = null //for targeting in processing
	var/target_set = FALSE //have we set a target at any point?
	///Var to track the linked detective gun
	var/linked_gun_UID

/obj/item/pinpointer/crew/attackby(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I, /obj/item/gun/energy/detective))
		link_gun(I.UID())

/obj/item/pinpointer/crew/emp_act(severity)
	var/obj/item/gun/energy/detective/D = locateUID(linked_gun_UID)
	if(!D)
		return
	D.unlink()
	atom_say("EMP detected. Connection to revolver tracking system lost.")

/obj/item/pinpointer/crew/proc/link_gun(gun_UID)
	var/obj/item/gun/energy/detective/D = locateUID(gun_UID)
	if(!D)
		return
	if((D.linked_pinpointer_UID && D.linked_pinpointer_UID != UID()) || linked_gun_UID)
		visible_message("<span class='notice'>The pinpointer pings to indicate either it or the gun is already linked.</span>", "<span class='notice'>You hear a pinpointer pinging.</span>")
		return
	D.link_pinpointer(UID())
	linked_gun_UID = gun_UID
	visible_message("<span class='notice'>The pinpointer pings twice to indicate a successful link.</span>", "<span class='notice'>You hear a pinpointer pinging twice.</span>")

/obj/item/pinpointer/crew/proc/start_tracking()
	if(!linked_gun_UID)
		return
	var/obj/item/gun/energy/detective/D = locateUID(linked_gun_UID)
	if(!D)
		return
	var/target_UID = D.tracking_target_UID
	target = locateUID(target_UID)
	target_set = TRUE
	mode = MODE_DET
	visible_message("<span class='notice'>The pinpointer flickers as it begins tracking a target relayed from a detective's revolver.</span>", "<span class='notice'>You hear a pinpointer flickering.</span>")
	addtimer(CALLBACK(src, PROC_REF(stop_tracking)), 1 MINUTES, TIMER_UNIQUE)
	START_PROCESSING(SSfastprocess, src)

/obj/item/pinpointer/crew/proc/stop_tracking()
	visible_message("<span class='notice'>The pinpointer powers down, no longer receiving signals from a detective's revolver.</span>", "<span class='notice'>You hear a pinpointer powering down.</span>")
	target = null
	target_set = FALSE
	mode = MODE_OFF
	icon_state = icon_off
	STOP_PROCESSING(SSfastprocess, src)

/obj/item/pinpointer/crew/proc/trackable(mob/living/carbon/human/H)
	if(mode == MODE_DET) // Sensors? Where we're going, we dont need sensors!
		var/turf/here = get_turf(src)
		var/turf/there = get_turf(H)
		return istype(there) && istype(here) && there.z == here.z
	if(H && istype(H.w_uniform, /obj/item/clothing/under))
		var/turf/here = get_turf(src)
		var/obj/item/clothing/under/U = H.w_uniform
		// Suit sensors must be on maximum.
		if(!U.has_sensor || U.sensor_mode < 3)
			return FALSE
		var/turf/there = get_turf(U)
		return istype(there) && there.z == here.z
	return FALSE

/obj/item/pinpointer/crew/process()
	if(mode != MODE_OFF && target_set)
		point_at_target(target)

/obj/item/pinpointer/crew/point_at_target(atom/target)
	if(!target || !trackable(target))
		icon_state = icon_null
		return

	..(target)

/obj/item/pinpointer/crew/activate_mode(mode, mob/user)
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
			name = "[name] ([name_counts[name]])"
		names[name] = H
		name_counts[name] = 1

	if(!names.len)
		user.visible_message("<span class='notice'>[user]'s pinpointer fails to detect a signal.</span>", "<span class='notice'>Your pinpointer fails to detect a signal.</span>")
		return

	var/A = input(user, "Person to track", "Pinpoint") in names
	if(!src || !user || (user.get_active_hand() != src) || user.incapacitated() || !A)
		return

	target = names[A]
	target_set = TRUE
	user.visible_message("<span class='notice'>[user] activates [user.p_their()] pinpointer.</span>", "<span class='notice'>You activate your pinpointer.</span>")

/obj/item/pinpointer/crew/centcom
	name = "centcom pinpointer"
	desc = "A handheld tracking device that tracks crew based on remote centcom sensors."

/obj/item/pinpointer/crew/centcom/trackable(mob/living/carbon/human/H)
	var/turf/here = get_turf(src)
	var/turf/there = get_turf(H)
	return istype(there) && istype(here) && there.z == here.z

/obj/item/pinpointer/tendril
	name = "ancient scanning unit"
	desc = "Convenient that the scanning unit for the robot survived. Seems to point to the tendrils around here."
	icon_state = "pinoff_ancient"
	icon_off = "pinoff_ancient"
	icon_null = "pinonnull_ancient"
	icon_direct = "pinondirect_ancient"
	icon_close = "pinonclose_ancient"
	icon_medium = "pinonmedium_ancient"
	icon_far = "pinonfar_ancient"
	modes = list(MODE_TENDRIL)
	var/obj/structure/spawner/lavaland/target

/obj/item/pinpointer/tendril/process()
	if(mode == MODE_TENDRIL)
		worktendril()
		point_at_target(target, FALSE)
	else
		icon_state = icon_off

/obj/item/pinpointer/tendril/proc/worktendril()
	if(mode == MODE_TENDRIL)
		scan_for_tendrils()
		point_at_target(target)
	else
		return FALSE

/obj/item/pinpointer/tendril/proc/scan_for_tendrils()
	if(mode == MODE_TENDRIL)
		target = null //Resets nearest_op every time it scans
		var/closest_distance = 1000
		for(var/obj/structure/spawner/lavaland/T in GLOB.tendrils)
			var/temp_distance = get_dist(T, get_turf(src))
			if(temp_distance < closest_distance)
				target = T
				closest_distance = temp_distance

/obj/item/pinpointer/tendril/examine(mob/user)
	. = ..()
	if(mode == MODE_TENDRIL)
		. += "Number of high energy signatures remaining: [length(GLOB.tendrils)]"


#undef MODE_OFF
#undef MODE_DISK
#undef MODE_NUKE
#undef MODE_ADV
#undef MODE_SHIP
#undef MODE_OPERATIVE
#undef MODE_CREW
#undef MODE_TENDRIL
#undef SETTING_DISK
#undef SETTING_LOCATION
#undef SETTING_OBJECT
