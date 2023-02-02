/obj/machinery/computer/HolodeckControl
	name = "holodeck control computer"
	desc = "A computer used to control a nearby holodeck."
	icon_keyboard = "tech_key"
	icon_screen = "holocontrol"
	var/area/linkedholodeck = null
	var/area/target = null
	var/active = FALSE
	var/list/holographic_items = list()
	var/last_change = 0

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/HolodeckControl/attack_ai(mob/user as mob)
	return attack_hand(user)


/obj/machinery/computer/HolodeckControl/attack_hand(mob/user as mob)
	if(..())
		return 1

	user.set_machine(src)
	var/dat

	dat += "<B>Holodeck Control System</B><BR>"
	dat += "<HR>Current Loaded Programs:<BR>"

	dat += "<A href='?src=[UID()];emptycourt=1'>((Empty Court)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];boxingcourt=1'>((Boxing Court)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];basketball=1'>((Basketball Court)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];thunderdomecourt=1'>((Thunderdome Court)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];beach=1'>((Beach)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];desert=1'>((Desert)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];space=1'>((Space)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];picnicarea=1'>((Picnic Area)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];snowfield=1'>((Snow Field)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];theatre=1'>((Theatre)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];meetinghall=1'>((Meeting Hall)</font>)</A><BR>"
	dat += "<A href='?src=[UID()];knightarena=1'>((Knight Arena)</font>)</A><BR>"
//		dat += "<A href='?src=[UID()];turnoff=1'>((Shutdown System)</font>)</A><BR>"

	dat += "Please ensure that only holographic weapons are used in the holodeck if a combat simulation has been loaded.<BR>"

	if(emagged)
/*			dat += "<A href='?src=[UID()];burntest=1'>(<font color=red>Begin Atmospheric Burn Simulation</font>)</A><BR>"
		dat += "Ensure the holodeck is empty before testing.<BR>"
		dat += "<BR>"*/
		dat += "<A href='?src=[UID()];wildlifecarp=1'>(<font color=red>Begin Wildlife Simulation</font>)</A><BR>"
		dat += "Ensure the holodeck is empty before testing.<BR>"
		dat += "<BR>"
		if(issilicon(user))
			dat += "<A href='?src=[UID()];AIoverride=1'>(<font color=green>Re-Enable Safety Protocols?</font>)</A><BR>"
		dat += "Safety Protocols are <font color=red> DISABLED </font><BR>"
	else
		if(issilicon(user))
			dat += "<A href='?src=[UID()];AIoverride=1'>(<font color=red>Override Safety Protocols?</font>)</A><BR>"
		dat += "<BR>"
		dat += "Safety Protocols are <font color=green> ENABLED </font><BR>"

	var/datum/browser/popup = new(user, "holodeck_computer", name, 400, 500)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "computer")
	return

/obj/machinery/computer/HolodeckControl/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["emptycourt"])
		target = locate(/area/holodeck/source_emptycourt)
		if(target)
			loadProgram(target)

	else if(href_list["boxingcourt"])
		target = locate(/area/holodeck/source_boxingcourt)
		if(target)
			loadProgram(target)

	else if(href_list["basketball"])
		target = locate(/area/holodeck/source_basketball)
		if(target)
			loadProgram(target)

	else if(href_list["thunderdomecourt"])
		target = locate(/area/holodeck/source_thunderdomecourt)
		if(target)
			loadProgram(target)

	else if(href_list["beach"])
		target = locate(/area/holodeck/source_beach)
		if(target)
			loadProgram(target)

	else if(href_list["desert"])
		target = locate(/area/holodeck/source_desert)
		if(target)
			loadProgram(target)

	else if(href_list["space"])
		target = locate(/area/holodeck/source_space)
		if(target)
			loadProgram(target)

	else if(href_list["picnicarea"])
		target = locate(/area/holodeck/source_picnicarea)
		if(target)
			loadProgram(target)

	else if(href_list["snowfield"])
		target = locate(/area/holodeck/source_snowfield)
		if(target)
			loadProgram(target)

	else if(href_list["theatre"])
		target = locate(/area/holodeck/source_theatre)
		if(target)
			loadProgram(target)

	else if(href_list["meetinghall"])
		target = locate(/area/holodeck/source_meetinghall)
		if(target)
			loadProgram(target)

	else if(href_list["knightarena"])
		target = locate(/area/holodeck/source_knightarena)
		if(target)
			loadProgram(target)

	else if(href_list["turnoff"])
		target = locate(/area/holodeck/source_plating)
		if(target)
			loadProgram(target)
/*
	else if(href_list["burntest"])
		if(!emagged)	return
		target = locate(/area/holodeck/source_burntest)
		if(target)
			loadProgram(target)
*/
	else if(href_list["wildlifecarp"])
		if(!emagged)	return
		target = locate(/area/holodeck/source_wildlife)
		if(target)
			loadProgram(target)

	else if(href_list["AIoverride"])
		if(!issilicon(usr))	return
		emagged = !emagged
		if(emagged)
			message_admins("[key_name_admin(usr)] overrode the holodeck's safeties")
			log_game("[key_name(usr)] overrode the holodeck's safeties")
		else
			message_admins("[key_name_admin(usr)] restored the holodeck's safeties")
			log_game("[key_name(usr)] restored the holodeck's safeties")

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/HolodeckControl/attackby(obj/item/D as obj, mob/user as mob, params)
	return

/obj/machinery/computer/HolodeckControl/emag_act(user as mob)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = TRUE
		to_chat(user, "<span class='notice'>You vastly increase projector power and override the safety and security protocols.</span>")
		to_chat(user, "Warning.  Automatic shutoff and derezing protocols have been corrupted.  Please call Nanotrasen maintenance and do not use the simulator.")
		log_game("[key_name(usr)] emagged the Holodeck Control Computer")
		src.updateUsrDialog()

/obj/machinery/computer/HolodeckControl/Initialize(mapload)
	. = ..()
	linkedholodeck = locate(/area/holodeck/alphadeck)
	//if(linkedholodeck)
	//	target = locate(/area/holodeck/source_emptycourt)
	//	if(target)
	//		loadProgram(target)

//This could all be done better, but it works for now.
/obj/machinery/computer/HolodeckControl/Destroy()
	emergencyShutdown()
	return ..()

/obj/machinery/computer/HolodeckControl/emp_act(severity)
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/ex_act(severity)
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/blob_act(obj/structure/blob/B)
	emergencyShutdown()
	return ..()

/obj/machinery/computer/HolodeckControl/process()
	for(var/item in holographic_items) // do this first, to make sure people don't take items out when power is down.
		if(!(get_turf(item) in linkedholodeck))
			derez(item, 0)

	if(!..())
		return

	if(active)
		if(!checkInteg(linkedholodeck))
			target = locate(/area/holodeck/source_plating)
			if(target)
				loadProgram(target)
			active = FALSE
			for(var/mob/M in range(10,src))
				M.show_message("The holodeck overloads!")


			for(var/turf/T in linkedholodeck)
				if(prob(30))
					do_sparks(2, 1, T)
				T.ex_act(3)
				T.hotspot_expose(1000,500,1)

/obj/machinery/computer/HolodeckControl/proc/derez(obj/obj , silent = 1)
	holographic_items.Remove(obj)

	if(obj == null)
		return

	if(isobj(obj))
		var/mob/M = obj.loc
		if(ismob(M))
			M.unEquip(obj, 1) //Holoweapons should always drop.

	if(!silent)
		var/obj/oldobj = obj
		visible_message("[oldobj] fades away!")
	qdel(obj)

/obj/machinery/computer/HolodeckControl/proc/checkInteg(area/A)
	for(var/turf/T in A)
		if(isspaceturf(T))
			return 0

	return 1

/obj/machinery/computer/HolodeckControl/proc/togglePower(toggleOn = 0)

	if(toggleOn)
		var/area/targetsource = locate(/area/holodeck/source_emptycourt)
		holographic_items = targetsource.copy_contents_to(linkedholodeck)

/*		spawn(30)
			for(var/obj/effect/landmark/L in linkedholodeck)
				if(L.name=="Atmospheric Test Start")
					spawn(20)
						var/turf/T = get_turf(L)
						do_sparks(2, 1, T)
						if(T)
							T.temperature = 5000
							T.hotspot_expose(50000,50000,1)*/

		active = TRUE
	else
		for(var/item in holographic_items)
			derez(item)
		var/area/targetsource = locate(/area/holodeck/source_plating)
		targetsource.copy_contents_to(linkedholodeck , 1)
		active = FALSE


/obj/machinery/computer/HolodeckControl/proc/loadProgram(area/A)

	if(world.time < (last_change + 25))
		if(world.time < (last_change + 15))//To prevent super-spam clicking, reduced process size and annoyance -Sieve
			return
		for(var/mob/M in range(3,src))
			M.show_message("<b>ERROR. Recalibrating projection apparatus.</b>")
			last_change = world.time
			return

	last_change = world.time
	active = TRUE

	for(var/item in holographic_items)
		derez(item)

	for(var/obj/effect/decal/cleanable/blood/B in linkedholodeck)
		qdel(B)

	for(var/mob/living/simple_animal/hostile/carp/C in linkedholodeck)
		qdel(C)

	holographic_items = A.copy_contents_to(linkedholodeck , 1, perfect_copy = FALSE)

	if(emagged)
		for(var/obj/item/holo/H in linkedholodeck)
			H.damtype = BRUTE

	spawn(30)
		for(var/obj/effect/landmark/L in linkedholodeck)
/*			if(L.name=="Atmospheric Test Start")
				spawn(20)
					var/turf/T = get_turf(L)
					do_sparks(2, 1, T)
					if(T)
						T.temperature = 5000
						T.hotspot_expose(50000,50000,1)*/
			if(L.name=="Holocarp Spawn")
				new /mob/living/simple_animal/hostile/carp/holocarp(L.loc)


/obj/machinery/computer/HolodeckControl/proc/emergencyShutdown()
	//Get rid of any items
	for(var/item in holographic_items)
		derez(item)
	//Turn it back to the regular non-holographic room
	target = locate(/area/holodeck/source_plating)
	if(target)
		loadProgram(target)

	var/area/targetsource = locate(/area/holodeck/source_plating)
	targetsource.copy_contents_to(linkedholodeck , 1)
	active = FALSE

// Holographic Items!
/turf/simulated/floor/holofloor/
	thermal_conductivity = 0
	icon_state = "plating"

/turf/simulated/floor/holofloor/carpet
	name = "carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	broken_states = list("damaged")
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET)
	canSmoothWith = list(SMOOTH_GROUP_CARPET)
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/holofloor/carpet/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/turf/simulated/floor/holofloor/carpet/update_icon_state()
	if(!..())
		return 0
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)
/turf/simulated/floor/holofloor/grass
	name = "Lush Grass"
	icon = 'icons/turf/floors/grass.dmi'
	icon_state = "grass-0"
	base_icon_state = "grass"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_GRASS)
	canSmoothWith = list(SMOOTH_GROUP_GRASS, SMOOTH_GROUP_JUNGLE_GRASS)
	pixel_x = -9
	pixel_y = -9
	layer = ABOVE_OPEN_TURF_LAYER
	floor_tile = /obj/item/stack/tile/grass

/turf/simulated/floor/holofloor/attackby(obj/item/W as obj, mob/user as mob, params)
	return
	// HOLOFLOOR DOES NOT GIVE A FUCK

/turf/simulated/floor/holofloor/space
	name = "\proper space"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	plane = PLANE_SPACE

/turf/simulated/floor/holofloor/space/Initialize(mapload)
	icon_state = SPACE_ICON_STATE // so realistic
	. = ..()

/turf/simulated/floor/holofloor/space/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/space.dmi'
	underlay_appearance.icon_state = SPACE_ICON_STATE
	underlay_appearance.plane = PLANE_SPACE
	return TRUE

/obj/structure/table/holotable
	flags = NODECONSTRUCT
	canSmoothWith = list(SMOOTH_GROUP_TABLES)

/obj/structure/table/holotable/wood
	name = "wooden table"
	desc = "A square piece of wood standing on four wooden legs. It can not move."
	icon = 'icons/obj/smooth_structures/tables/wood_table.dmi'
	icon_state = "wood_table-0"
	base_icon_state = "wood_table"
	smoothing_groups = list(SMOOTH_GROUP_WOOD_TABLES) //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = list(SMOOTH_GROUP_WOOD_TABLES)

/obj/structure/chair/stool/holostool
	flags = NODECONSTRUCT
	item_chair = null

/obj/item/clothing/gloves/boxing/hologlove
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	item_state = "boxing"

/obj/structure/holowindow
	name = "reinforced window"
	icon = 'icons/obj/structures.dmi'
	icon_state = "rwindow"
	desc = "A window."
	density = TRUE
	layer = 3.2//Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = TRUE
	flags = ON_BORDER

/obj/structure/rack/holorack
	flags = NODECONSTRUCT

/obj/item/holo
	damtype = STAMINA

//override block check, we don't want to block anything that's not a holo object
/obj/item/holo/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby)
	if(!istype(hitby, /obj/item/holo))
		return FALSE
	else
		return ..()

/obj/item/holo/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 40
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/holo/claymore/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS)


/obj/item/holo/claymore/blue
	icon_state = "claymoreblue"
	item_state = "claymoreblue"

/obj/item/holo/claymore/red
	icon_state = "claymorered"
	item_state = "claymorered"

/obj/item/holo/esword
	name = "holographic energy sword"
	desc = "This looks like a real energy sword!"
	icon_state = "sword0"
	hitsound = "swing_hit"
	force = 3.0
	throw_speed = 1
	throw_range = 5
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	armour_penetration_percentage = 50
	var/active = FALSE

/obj/item/holo/esword/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS)

/obj/item/holo/esword/green/New()
	..()
	item_color = "green"

/obj/item/holo/esword/red/New()
	..()
	item_color = "red"

/obj/item/holo/esword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return 0

/obj/item/holo/esword/New()
	..()
	item_color = pick("red","blue","green","purple")

/obj/item/holo/esword/attack_self(mob/living/user as mob)
	active = !active
	if(active)
		force = 30
		icon_state = "sword[item_color]"
		hitsound = "sound/weapons/blade1.ogg"
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 20, 1)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = 3
		icon_state = "sword0"
		hitsound = "swing_hit"
		w_class = WEIGHT_CLASS_SMALL
		playsound(user, 'sound/weapons/saberoff.ogg', 20, 1)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	return

/obj/machinery/readybutton
	name = "Ready Declaration Device"
	desc = "This device is used to declare ready. If all devices in an area are ready, the event will begin!"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	var/ready = FALSE
	var/area/currentarea = null
	var/eventstarted = 0

	anchored = TRUE
	idle_power_consumption = 2
	active_power_consumption = 6
	power_channel = PW_CHANNEL_ENVIRONMENT

/obj/machinery/readybutton/attack_ai(mob/user as mob)
	to_chat(user, "The station AI is not to interact with these devices.")
	return

/obj/machinery/readybutton/attackby(obj/item/W as obj, mob/user as mob, params)
	to_chat(user, "The device is a solid button, there's nothing you can do with it!")

/obj/machinery/readybutton/attack_hand(mob/user as mob)
	if(user.stat || stat & (BROKEN))
		to_chat(user, "This device is not functioning.")
		return

	currentarea = get_area(src.loc)
	if(!currentarea)
		qdel(src)

	if(eventstarted)
		to_chat(usr, "The event has already begun!")
		return

	ready = !ready

	update_icon(UPDATE_ICON_STATE)

	var/numbuttons = 0
	var/numready = 0
	for(var/obj/machinery/readybutton/button in currentarea)
		numbuttons++
		if(button.ready)
			numready++

	if(numbuttons == numready)
		begin_event()

/obj/machinery/readybutton/update_icon_state()
	if(ready)
		icon_state = "auth_on"
	else
		icon_state = "auth_off"

/obj/machinery/readybutton/proc/begin_event()
	eventstarted = 1

	for(var/obj/structure/holowindow/W in currentarea)
		qdel(W)

	for(var/mob/M in currentarea)
		to_chat(M, "FIGHT!")
