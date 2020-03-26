/*
CONTAINS:
SAFES
FLOOR SAFES
SAFE INTERNALS
SAFE CODES
*/

#define DRILL_SPARK_CHANCE 15
#define DRILL_TIME 300 SECONDS
#define SOUND_CHANCE 10

GLOBAL_LIST_EMPTY(safes)

/**
  * # Safe
  *
  * A locked container that can only be opened by entering a combination through a dial.
  */
/obj/structure/safe
	name = "safe"
	desc = "A huge chunk of metal with a dial embedded in it. Fine print on the dial reads \"Scarborough Arms tumbler safe, guaranteed thermite resistant, explosion resistant, and assistant resistant.\""
	icon = 'icons/obj/structures.dmi'
	icon_state = "safe"
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	// Settings
	/// The maximum combined w_class of stuff in the safe.
	var/maxspace = 24
	/// The amount of tumblers that will be generated.
	var/number_of_tumblers = 3
	// Variables
	/// Whether the safe is open or not.
	var/open = FALSE
	/// Whether the safe is locked or not.
	var/locked = TRUE
	/// The position the dial is pointing to.
	var/dial = 0
	/// The list of tumbler dial positions that need to be hit.
	var/list/tumblers = list()
	/// The index in the tumblers list of the tumbler dial position that needs to be hit.
	var/current_tumbler_index = 1
	/// The combined w_class of everything in the safe.
	var/space = 0
	// Variables (Drill)
	/// The currently placed thermal drill, if any.
	var/obj/item/thermal_drill/drill = null
	/// The [/proc/addtimer] handle for the current thermal drill.
	var/drill_timer
	/// Drill duration of the current thermal drill.
	var/time_to_drill
	/// The world.time at which drilling started.
	var/drill_start_time
	/// The drill overlay image to display during the drilling process.
	var/image/drill_overlay
	/// The progress bar image to display during the drilling process.
	var/image/progress_bar
	/// The X pixel offset for the drilling progress bar.
	var/drill_x_offset = -13
	/// The Y pixel offset for the drilling progress bar.
	var/drill_y_offset = -3
	/// Used by [/obj/item/paper/safe_code] to tell the codes through a paper spawned on map load.
	var/known_by = list()

/obj/structure/safe/Initialize(mapload)
	. = ..()
	GLOB.safes += src
	// Combination generation
	for(var/i in 1 to number_of_tumblers)
		tumblers.Add(rand(0, 99))
	// Put as many items on our turf inside as possible
	for(var/obj/item/I in loc)
		if(space >= maxspace)
			return
		if(I.w_class + space <= maxspace)
			space += I.w_class
			I.forceMove(src)

/obj/structure/safe/Destroy()
	GLOB.safes -= src
	if(drill)
		drill.soundloop.stop()
		drill.forceMove(loc)
		drill = null

	QDEL_NULL(progress_bar)
	QDEL_NULL(drill_overlay)
	return ..()

/obj/structure/safe/process()
	if(!drill_timer)
		return
	cut_overlay(progress_bar)
	progress_bar = image('icons/effects/progessbar.dmi', src, "prog_bar_[round((((world.time - drill_start_time) / time_to_drill) * 100), 5)]", HUD_LAYER)
	add_overlay(progress_bar)
	if(prob(DRILL_SPARK_CHANCE))
		drill.spark_system.start()

/obj/structure/safe/examine(mob/user)
	. = ..()
	. += "This model appears to have [number_of_tumblers] tumblers."
	if(open)
		. += "The inside of the the door has numbers written on it: <b>[get_combination()]</b>"

/obj/structure/safe/blob_act(obj/structure/blob/B)
	return

/obj/structure/safe/ex_act(severity)
	return

/obj/structure/safe/examine_status(mob/user)
	return

/obj/structure/safe/update_icon()
	if(open)
		if(broken)
			icon_state = "[initial(icon_state)]-open-broken"
		else
			icon_state = "[initial(icon_state)]-open"
	else
		if(broken)
			icon_state = "[initial(icon_state)]-broken"
		else
			icon_state = initial(icon_state)

	var/list/overlays_to_cut = list(drill_overlay)
	if(!drill_timer)
		overlays_to_cut += progress_bar

	cut_overlay(overlays_to_cut)

	if(istype(drill, /obj/item/thermal_drill))
		var/drill_icon = istype(drill, /obj/item/thermal_drill/diamond_drill) ? "d" : "h"
		var/state = "[initial(icon_state)]_[drill_icon]-drill-[drill_timer ? "on" : "off"]"
		drill_overlay = image(icon = 'icons/effects/drill.dmi', icon_state = state, pixel_x = drill_x_offset, pixel_y = drill_y_offset)
		add_overlay(drill_overlay)

/obj/structure/safe/attack_ghost(mob/user)
	if(..() || drill)
		return TRUE
	ui_interact(user)

/obj/structure/safe/attack_hand(mob/user)
	if(..())
		return TRUE

	if(drill)
		switch(alert("What would you like to do?", "Thermal Drill", "Turn [drill_timer ? "Off" : "On"]", "Remove Drill", "Cancel"))
			if("Turn On")
				if(do_after(user, 2 SECONDS, target = src))
					drill_timer = addtimer(CALLBACK(src, .proc/drill_open), time_to_drill, TIMER_STOPPABLE)
					drill_start_time = world.time
					drill.soundloop.start()
					update_icon()
					START_PROCESSING(SSobj, src)
			if("Turn Off")
				if(do_after(user, 2 SECONDS, target = src))
					deltimer(drill_timer)
					drill_timer = null
					drill.soundloop.stop()
					update_icon()
					STOP_PROCESSING(SSobj, src)
			if("Remove Drill")
				if(drill_timer)
					to_chat(user, "<span class='warning'>You cannot remove the drill while it's running!</span>")
				else if(do_after(user, 2 SECONDS, target = src))
					user.put_in_hands(drill)
					drill = null
					update_icon()
			if("Cancel")
				return
	else
		ui_interact(user)

/obj/structure/safe/attackby(obj/item/I, mob/user, params)
	if(open)
		if(broken && istype(I, /obj/item/safe_internals) && do_after(user, 2 SECONDS, target = src))
			to_chat(user, "<span class='notice'>You replace the broken mechanism.</span>")
			qdel(I)
			broken = FALSE
			update_icon()
		else if(I.w_class + space <= maxspace)
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>\The [I] is stuck to your hand, you cannot put it in the safe!</span>")
				return
			space += I.w_class
			I.forceMove(src)
			to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
			SStgui.update_uis(src)
		else
			to_chat(user, "<span class='warning'>[I] won't fit in [src].</span>")
	else
		if(istype(I, /obj/item/clothing/accessory/stethoscope))
			attack_hand(user)
			return
		else if(istype(I, /obj/item/thermal_drill))
			if(drill)
				to_chat(user, "<span class='warning'>There is already a drill attached!</span>")
			else if(do_after(user, 2 SECONDS, target = src))
				if(!user.drop_item())
					to_chat(user, "<span class='warning'>[I] is stuck to your hand, you cannot put it in the safe!</span>")
					return
				I.forceMove(src)
				drill = I
				time_to_drill = DRILL_TIME * drill.time_multiplier
				update_icon()
		else
			to_chat(user, "<span class='warning'>You can't put [I] into the safe while it is closed!</span>")
			return

/obj/structure/safe/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.physical_state)
	var/datum/asset/safe_assets = get_asset_datum(/datum/asset/simple/safe)
	safe_assets.send(user)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Safe", name, 600, 750)
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/structure/safe/ui_data(mob/user)
	var/list/data = list()
	data["dial"] = dial
	data["open"] = open
	data["locked"] = locked && !broken

	if(open)
		var/list/contents_names = list()
		data["contents"] = contents_names
		for(var/obj/O in contents)
			contents_names[++contents_names.len] = list("name" = O.name, "sprite" = O.icon_state)
			user << browse_rsc(icon(O.icon, O.icon_state), "[O.icon_state].png")

	return data

/obj/structure/safe/ui_act(action, params)
	if(..())
		return

	if(!usr.IsAdvancedToolUser() && !isobserver(usr))
		to_chat(usr, "<span class='warning'>You are not able to operate the safe.</span>")
		return

	var/canhear = FALSE
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(H.can_hear() && H.is_in_hands(/obj/item/clothing/accessory/stethoscope))
			canhear = TRUE

	. = TRUE
	switch(action)
		if("open")
			if(check_unlocked() || open || broken)
				to_chat(usr, "<span class='notice'>You [open ? "close" : "open"] [src].</span>")
				open = !open
				update_icon()
			else
				to_chat(usr, "<span class='warning'>You cannot open [src], as its lock is engaged!</span>")
		if("turnright")
			if(open)
				return
			if(broken)
				to_chat(usr, "<span class='warning'>The dial will not turn, as the mechanism is destroyed!</span>")
				return
			var/ticks = text2num(params["num"])
			for(var/i = 1 to ticks)
				dial = WRAP(dial - 1, 0, 100)

				var/invalid_turn = current_tumbler_index % 2 == 0 || current_tumbler_index > number_of_tumblers
				if(invalid_turn) // The moment you turn the wrong way or go too far, the tumblers reset
					current_tumbler_index = 1

				if(!invalid_turn && dial == tumblers[current_tumbler_index])
					notify_user(usr, canhear, list("tink", "krink", "plink"), ticks, i)
					current_tumbler_index++
				else
					notify_user(usr, canhear, list("clack", "scrape", "clank"), ticks, i)
			check_unlocked()
		if("turnleft")
			if(open)
				return
			if(broken)
				to_chat(usr, "<span class='warning'>The dial will not turn, as the mechanism is destroyed!</span>")
				return
			var/ticks = text2num(params["num"])
			for(var/i = 1 to ticks)
				dial = WRAP(dial + 1, 0, 100)

				var/invalid_turn = current_tumbler_index % 2 != 0 || current_tumbler_index > number_of_tumblers
				if(invalid_turn) // The moment you turn the wrong way or go too far, the tumblers reset
					current_tumbler_index = 1

				if(!invalid_turn && dial == tumblers[current_tumbler_index])
					notify_user(usr, canhear, list("tonk", "krunk", "plunk"), ticks, i)
					current_tumbler_index++
				else
					notify_user(usr, canhear, list("click", "chink", "clink"), ticks, i)
			check_unlocked()
		if("retrieve")
			if(!open)
				return
			var/index = text2num(params["index"])
			if(!ISINDEXSAFE(contents, index))
				return
			var/obj/item/I = contents[index]
			if(I && in_range(src, usr))
				usr.put_in_hands(I)
				space -= I.w_class
		else
			return FALSE

	add_fingerprint(usr)

/**
  * Called every dial turn to determine whether the safe should unlock or not.
  */
/obj/structure/safe/proc/check_unlocked()
	if(current_tumbler_index > number_of_tumblers)
		locked = FALSE
		visible_message("<span class='boldnotice'>[pick("Spring", "Sprang", "Sproing", "Clunk", "Krunk")]!</span>")
		return TRUE
	locked = TRUE
	return FALSE

/**
  * Called every dial turn to provide feedback if possible.
  */
/obj/structure/safe/proc/notify_user(user, canhear, sounds, total_ticks, current_tick)
	if(!canhear)
		return

	if(current_tick == 2)
		to_chat(user, "<span class='italics'>The sounds from [src] are too fast and blend together.</span>")
	if(total_ticks == 1 || prob(SOUND_CHANCE))
		to_chat(user, "<span class='italics'>You hear a [pick(sounds)] from [src].</span>")

/**
  * Returns the combination to unlock the safe as text.
  */
/obj/structure/safe/proc/get_combination()
	return jointext(tumblers, ", ")

/**
  * Called when the current thermal drill has finished drilling.
  */
/obj/structure/safe/proc/drill_open()
	broken = TRUE
	drill_timer = null
	drill.soundloop.stop()
	update_icon()
	STOP_PROCESSING(SSobj, src)

/**
  * # Floor Safe
  *
  * Like a safe, but without density. Can be hidden with flooring.
  */
/obj/structure/safe/floor
	name = "floor safe"
	icon_state = "floorsafe"
	density = FALSE
	level = 1 //Under the floor
	layer = LOW_OBJ_LAYER
	drill_x_offset = -1
	drill_y_offset = 20

/obj/structure/safe/floor/Initialize()
	. = ..()
	var/turf/T = loc
	hide(T.intact)

/obj/structure/safe/floor/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0

/**
  * # Safe Internals
  *
  * Can be used to replace a safe's broken mechanism.
  */
/obj/item/safe_internals
	name = "safe internals"
	desc = "The mechanism and locking bolts for a Scarborough Arms - 2 tumbler safe."
	icon_state = "safe_internals"

/**
  * # Safe Codes
  *
  * Contains the (generated on map load) codes for all publicly known safes.
  */
/obj/item/paper/safe_code
	name = "safe codes"
	var/owner
	info = "<div style='text-align:center;'><img src='ntlogo.png'><center><h3>Safe Codes</h3></center>"

/obj/item/paper/safe_code/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/paper/safe_code/LateInitialize(mapload)
	. = ..()
	for(var/safe in GLOB.safes)
		var/obj/structure/safe/S = safe
		if(owner in S.known_by)
			info += "<br> The combination for the safe located in the [get_area(S)] is: [S.get_combination()]<br>"
			info_links = info
			update_icon()

#undef DRILL_SPARK_CHANCE
#undef DRILL_TIME
#undef SOUND_CHANCE
