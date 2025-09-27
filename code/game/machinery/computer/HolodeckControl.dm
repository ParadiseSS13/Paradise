/obj/machinery/computer/holodeck_control
	name = "holodeck control computer"
	desc = "A computer used to control a nearby holodeck."
	icon_keyboard = "tech_key"
	icon_screen = "holocontrol"

	/// String name of the currently selected holodeck state
	var/selected_deck = "Empty Court"
	/// The default deck for this holodeck incase of emergency / destruction
	var/area/shutdown_state = /area/holodeck/source_plating
	/// All decks available to the player, will automatically be selectable in the menu if put in this list
	var/list/available_decks = list(
		"Empty Court" = /area/holodeck/source_emptycourt,
		"Boxing Court" = /area/holodeck/source_boxingcourt,
		"Basketball Court" = /area/holodeck/source_basketball,
		"Thunderdome Court" = /area/holodeck/source_thunderdomecourt,
		"Beach" = /area/holodeck/source_beach,
		"Desert" = /area/holodeck/source_desert,
		"Space" = /area/holodeck/source_space,
		"Picnic Area" = /area/holodeck/source_picnicarea,
		"Snow Field" = /area/holodeck/source_snowfield,
		"Theatre" = /area/holodeck/source_theatre,
		"Meeting Hall" = /area/holodeck/source_meetinghall,
		"Knight Arena" = /area/holodeck/source_knightarena,
	)
	var/emag_deck = /area/holodeck/source_wildlife
	var/area/linkedholodeck = null
	var/area/target = null
	var/active = FALSE
	var/list/holographic_items = list()
	var/last_change = 0

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/holodeck_control/Initialize(mapload)
	. = ..()
	linkedholodeck = locate(/area/holodeck/alphadeck)
	RegisterSignal(src, COMSIG_ATTACK_BY, TYPE_PROC_REF(/datum, signal_cancel_attack_by))

/obj/machinery/computer/holodeck_control/Destroy()
	emergency_shutdown()
	return ..()

/obj/machinery/computer/holodeck_control/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/holodeck_control/attack_ghost(mob/user)
	ui_interact(user)
	return ..()

/obj/machinery/computer/holodeck_control/attack_hand(mob/user)
	ui_interact(user)
	return ..()

/obj/machinery/computer/holodeck_control/process()
	for(var/item in holographic_items) // do this first, to make sure people don't take items out when power is down.
		if(!(get_turf(item) in linkedholodeck))
			derez(item, 0)

	if(!..())
		return

	if(active)
		if(!check_deck_integrity(linkedholodeck))
			target = locate(/area/holodeck/source_plating)
			if(target)
				loadProgram(target)
			active = FALSE
			for(var/mob/M in range(10,src))
				M.show_message("The holodeck overloads!")


			for(var/turf/T in linkedholodeck)
				if(prob(30))
					do_sparks(2, 1, T)
				T.ex_act(EXPLODE_LIGHT)
				T.hotspot_expose(1000,500)

/obj/machinery/computer/holodeck_control/proc/loadProgram(area/A)

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
	for(var/mob/living/basic/carp/holocarp/C in linkedholodeck)
		qdel(C)
	holographic_items = A.copy_contents_to(linkedholodeck, platingRequired = TRUE)

	if(emagged)
		for(var/obj/item/holo/H in linkedholodeck)
			H.damtype = BRUTE

	spawn(30)
		for(var/obj/effect/landmark/L in linkedholodeck)
			if(L.name=="Holocarp Spawn")
				new /mob/living/basic/carp/holocarp(L.loc)


/obj/machinery/computer/holodeck_control/proc/emergency_shutdown()
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


/obj/machinery/computer/holodeck_control/proc/derez(obj/obj, silent = TRUE)
	holographic_items.Remove(obj)

	if(!istype(obj))
		return

	var/mob/M = obj.loc
	if(istype(M))
		// Holoweapons should always drop.
		M.drop_item_to_ground(obj, force = TRUE)

	if(!silent)
		var/obj/old_obj = obj
		visible_message("[old_obj] fades away!")
	qdel(obj)

/obj/machinery/computer/holodeck_control/proc/check_deck_integrity(area/A)
	for(var/turf/space/T in A)
		return FALSE
	return TRUE

/obj/machinery/computer/holodeck_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/holodeck_control/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Holodeck", name)
		ui.autoupdate = TRUE
		ui.open()

/obj/machinery/computer/holodeck_control/ui_data(mob/user)
	var/list/data = list()
	data["current_deck"] = selected_deck
	data["emagged"] = emagged
	data["ai_override"] = issilicon(user)
	data["decks"] = list()
	for(var/deck_name in available_decks)
		data["decks"] += deck_name
	return data

/obj/machinery/computer/holodeck_control/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE

	add_fingerprint(ui.user)
	switch(action)
		if("select_deck")
			target = locate(available_decks[params["deck"]])
			selected_deck = params["deck"]
			if(target)
				loadProgram(target)
		if("ai_override")
			if(!issilicon(ui.user))
				return
			emagged = !emagged
			if(emagged)
				message_admins("[key_name_admin(ui.user)] overrode the holodeck's safeties")
				log_game("[key_name(ui.user)] overrode the holodeck's safeties")
				return
			message_admins("[key_name_admin(ui.user)] restored the holodeck's safeties")
			log_game("[key_name(ui.user)] restored the holodeck's safeties")
		if("wildlifecarp")
			if(!emagged)
				return
			target = locate(emag_deck)
			selected_deck = "Wildlife Simulation"
			if(target)
				loadProgram(target)

/obj/machinery/computer/holodeck_control/emag_act(user)
	if(emagged)
		return
	playsound(loc, 'sound/effects/sparks4.ogg', 75, 1)
	emagged = TRUE
	to_chat(user, "<span class='notice'>You vastly increase projector power and override the safety and security protocols.</span>")
	to_chat(user, "Warning! Automatic shutoff and derezing protocols have been corrupted. Please call Nanotrasen maintenance and do not use the simulator.")
	log_game("[key_name(user)] emagged the Holodeck Control Computer")
	return TRUE

/obj/machinery/computer/holodeck_control/emp_act(severity)
	emergency_shutdown()
	..()

/obj/machinery/computer/holodeck_control/ex_act(severity)
	emergency_shutdown()
	..()

/obj/machinery/computer/holodeck_control/blob_act(obj/structure/blob/B)
	emergency_shutdown()
	return ..()


//
// ## HOLODECK ITEMS & OBJECTS
//



// Holographic Items!
/turf/simulated/floor/holofloor
	thermal_conductivity = 0
	icon_state = "plating"

/turf/simulated/floor/holofloor/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATTACK_BY, TYPE_PROC_REF(/datum, signal_cancel_attack_by))

/turf/simulated/floor/holofloor/carpet
	name = "carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF, SMOOTH_GROUP_CARPET)
	canSmoothWith = list(SMOOTH_GROUP_CARPET)
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT

/turf/simulated/floor/holofloor/carpet/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/turf/simulated/floor/holofloor/carpet/update_icon_state()
	if(!..())
		return 0
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)

/turf/simulated/floor/holofloor/carpet/get_broken_states()
	return list("damaged")

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

/obj/structure/holowindow
	name = "reinforced window"
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
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "claymore"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
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

/obj/item/holo/claymore/red
	icon_state = "claymorered"

/obj/item/holo/esword
	name = "holographic energy sword"
	desc = "This looks like a real energy sword!"
	icon = 'icons/obj/weapons/energy_melee.dmi'
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon_state = "sword"
	hitsound = "swing_hit"
	force = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	armor_penetration_percentage = 50
	var/active = FALSE
	/// Color of this e-sword. You can see supported colors in icon file
	var/sword_color

/obj/item/holo/esword/Initialize(mapload)
	. = ..()
	if(!sword_color)
		sword_color = pick("red", "blue", "green", "purple")
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS)

/obj/item/holo/esword/update_icon_state()
	icon_state = "[initial(icon_state)][active ? sword_color : ""]"

/obj/item/holo/esword/green
	sword_color = "green"

/obj/item/holo/esword/red
	sword_color = "red"

/obj/item/holo/esword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return 0

/obj/item/holo/esword/attack_self__legacy__attackchain(mob/living/user as mob)
	active = !active
	if(active)
		force = 30
		hitsound = "sound/weapons/blade1.ogg"
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 20, 1)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = 3
		hitsound = "swing_hit"
		w_class = WEIGHT_CLASS_SMALL
		playsound(user, 'sound/weapons/saberoff.ogg', 20, 1)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	update_icon(UPDATE_ICON_STATE)

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

/obj/machinery/readybutton/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	to_chat(user, "The device is a solid button, there's nothing you can do with it!")
	return ITEM_INTERACT_COMPLETE

/obj/machinery/readybutton/attack_hand(mob/user)
	if(user.stat || stat & (BROKEN))
		to_chat(user, "This device is not functioning.")
		return

	currentarea = get_area(loc)
	if(!currentarea)
		qdel(src)

	if(eventstarted)
		to_chat(user, "The event has already begun!")
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
