/*
CONTAINS:
SAFES
FLOOR SAFES
SAFE INTERNALS
SAFE CODES
*/

GLOBAL_LIST_EMPTY(safes)

//SAFES
/obj/structure/safe
	name = "\improper Safe"
	desc = "A huge chunk of metal with a dial embedded in it. Fine print on the dial reads \"Scarborough Arms tumbler safe, guaranteed thermite resistant, explosion resistant, and assistant resistant.\""
	icon = 'icons/obj/structures.dmi'
	icon_state = "safe"

	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	var/open = FALSE
	var/locked = TRUE
	var/dial = 0		// The position the dial is pointing to.

	var/number_of_tumblers = 3 // The amount of tumblers that will be generated.
	var/list/tumblers = list() // The list of tumbler dial positions that need to be hit.
	var/list/current_tumbler_index = 1 // The index in the tumblers list of the tumbler dial position that needs to be hit.

	var/space = 0		// The combined w_class of everything in the safe.
	var/maxspace = 24	// The maximum combined w_class of stuff in the safe.

	var/obj/item/thermal_drill/drill = null
	var/drill_timer
	var/time_to_drill
	var/image/bar
	var/drill_start_time
	var/drill_x_offset = -13
	var/drill_y_offset = -3
	var/known_by = list()

	var/image/progress_bar
	var/image/drill_overlay

/obj/structure/safe/Initialize(mapload)
	. = ..()

	GLOB.safes += src

	for(var/i in 1 to number_of_tumblers)
		tumblers.Add(rand(0, 99))

	for(var/obj/item/I in loc)
		if(space >= maxspace)
			return
		if(I.w_class + space <= maxspace)
			space += I.w_class
			I.forceMove(src)

/obj/structure/safe/Destroy()
	GLOB.safes -= src
	drill?.soundloop?.stop()
	drill?.forceMove(loc)
	drill = null

	qdel(progress_bar)
	qdel(drill_overlay)
	return ..()

/obj/structure/safe/process()
	if(drill_timer)
		cut_overlay(progress_bar)
		progress_bar = image('icons/effects/progessbar.dmi', src, "prog_bar_[round((((world.time - drill_start_time) / time_to_drill) * 100), 5)]", HUD_LAYER)
		add_overlay(progress_bar)
		if(prob(15))
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

/obj/structure/safe/proc/check_unlocked()
	if(current_tumbler_index > number_of_tumblers)
		locked = FALSE
		visible_message("<span class='boldnotice'>[pick("Spring", "Sprang", "Sproing", "Clunk", "Krunk")]!</span>")
		return TRUE

	locked = TRUE
	return FALSE

/obj/structure/safe/proc/get_combination()
	var/combination = ""
	var/looped = 0

	for(var/tumbler in tumblers)
		looped++
		combination += "[tumbler]"

		if(looped < LAZYLEN(tumblers))
			combination += ", "

	return combination

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
		if(drill_timer)
			drill_overlay = image(icon = 'icons/effects/drill.dmi', icon_state = "[initial(icon_state)]_[drill_icon]-drill-on", pixel_x = drill_x_offset, pixel_y = drill_y_offset)
		else
			drill_overlay = image(icon = 'icons/effects/drill.dmi', icon_state = "[initial(icon_state)]_[drill_icon]-drill-off", pixel_x = drill_x_offset, pixel_y = drill_y_offset)

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
					to_chat(user, "<span class='warning'>You cant remove the drill while it's running!</span>")
				else if(do_after(user, 2 SECONDS, target = src))
					user.put_in_hands(drill)
					drill = null
					update_icon()
			if("Cancel")
				return
	else
		ui_interact(user)

/obj/structure/safe/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "safe.tmpl", name, 600, 750)
		ui.open()
		ui.set_auto_update(1)

/obj/structure/safe/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]
	var/list/contents_names = list()
	if(open)
		for(var/obj/O in contents)
			contents_names[++contents_names.len] = list("name" = O.name, "index" = contents.Find(O), "sprite" = O.icon_state)
			user << browse_rsc(icon(O.icon, O.icon_state), "[O.icon_state].png")

	data["dial"] = dial
	data["open"] = open
	data["locked"] = locked
	data["rotation"] = "[-dial * 3.6]deg"
	data["contents"] = contents_names

	return data

/obj/structure/safe/proc/notify_user(user, canhear, sounds, total_ticks, current_tick)
	if(!canhear)
		return

	if(current_tick == 2)
		to_chat(user, "<span class='italics'>The sounds from [src] are too fast and blend together.</span>")

	if(total_ticks == 1 || prob(10))
		to_chat(user, "<span class='italics'>You hear a [pick(sounds)] from [src].</span>")

/obj/structure/safe/Topic(href, href_list)
	if(..())
		return TRUE

	var/mob/user = usr
	if(!user.IsAdvancedToolUser() && !isobserver(user))
		to_chat(user, "<span class='warning'>You're not able to operate the safe.</span>")
		return

	var/canhear = FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.can_hear() && H.is_in_hands(/obj/item/clothing/accessory/stethoscope))
			canhear = TRUE

	if(href_list["open"])
		if(check_unlocked() || open || broken)
			to_chat(user, "<span class='notice'>You [open ? "close" : "open"] [src].</span>")
			open = !open
			update_icon()
		else
			to_chat(user, "<span class='warning'>You can't open [src], as its lock is engaged!</span>")

		. = TRUE

	if(href_list["turnright"])
		if(open)
			return

		if(broken)
			to_chat(user, "<span class='warning'>The dial will not turn, as the mechanism is destroyed.</span>")
			return

		var/ticks = text2num(href_list["turnright"])
		for(var/i = 1 to ticks)
			dial = Wrap(dial - 1, 0, 100)

			var/invalid_turn = current_tumbler_index % 2 == 0 || current_tumbler_index > number_of_tumblers
			if(invalid_turn) // The moment you turn the wrong way or go too far, the tumblers reset
				current_tumbler_index = 1

			if(!invalid_turn && dial == tumblers[current_tumbler_index])
				notify_user(user, canhear, list("tink", "krink", "plink"), ticks, i)
				current_tumbler_index++
			else
				notify_user(user, canhear, list("clack", "scrape", "clank"), ticks, i)

			sleep(1)
			check_unlocked(user, canhear)
			SSnanoui.update_uis(src)

		. = TRUE

	if(href_list["turnleft"])
		if(open)
			return

		if(broken)
			to_chat(user, "<span class='warning'>The dial will not turn, as the mechanism is destroyed.</span>")
			return

		var/ticks = text2num(href_list["turnleft"])
		for(var/i = 1 to ticks)
			dial = Wrap(dial + 1, 0, 100)

			var/invalid_turn = current_tumbler_index % 2 != 0 || current_tumbler_index > number_of_tumblers
			if(invalid_turn) // The moment you turn the wrong way or go too far, the tumblers reset
				current_tumbler_index = 1

			if(!invalid_turn && dial == tumblers[current_tumbler_index])
				notify_user(user, canhear, list("tonk", "krunk", "plunk"), ticks, i)
				current_tumbler_index++
			else
				notify_user(user, canhear, list("click", "chink", "clink"), ticks, i)

			sleep(1)
			check_unlocked(user, canhear)
			SSnanoui.update_uis(src)

		. = TRUE

	if(href_list["retrieve"])
		var/index = text2num(href_list["retrieve"])
		if(index > 0 && index <= contents.len)
			var/obj/item/P = contents[index]
			if(open)
				if(P && in_range(src, user))
					user.put_in_hands(P)
					space -= P.w_class
		. = TRUE

/obj/structure/safe/proc/drill_open()
	broken = TRUE
	drill_timer = null
	drill.soundloop.stop()
	update_icon()
	STOP_PROCESSING(SSobj, src)

/obj/structure/safe/attackby(obj/item/I, mob/user, params)
	if(open)
		if(broken && istype(I, /obj/item/safe_internals) && do_after(user, 2 SECONDS, target = src))
			to_chat(user, "<span class='notice'>You replace the broken mechanism.</span>")
			qdel(I)
			broken = !broken
			update_icon()
		else if(I.w_class + space <= maxspace)
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>\The [I] is stuck to your hand, you cannot put it in the safe!</span>")
				return
			space += I.w_class
			I.forceMove(src)
			to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		else
			to_chat(user, "<span class='notice'>[I] won't fit in [src].</span>")
	else
		if(istype(I, /obj/item/clothing/accessory/stethoscope))
			to_chat(user, "<span class='warning'>Hold [I] in one of your hands while you manipulate the dial!</span>")
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
				time_to_drill = 300 SECONDS * drill.time_multiplier
				update_icon()
		else
			to_chat(user, "<span class='warning'>You can't put [I] into the safe while it is closed!</span>")
			return

//FLOOR SAFES
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

/obj/item/safe_internals
	name = "safe internals"
	desc = "The mechanism and locking bolts for a Scarborough Arms - 2 tumbler safe"
	icon_state = "safe_internals"

/obj/item/paper/safe_code
	name = "safe codes"
	var/owner
	info = "<div style='text-align:center;'><img src='ntlogo.png'><center><h3>Safe Codes</h3></center>"

/obj/item/paper/safe_code/Initialize(mapload)
	return INITIALIZE_HINT_LATELOAD

/obj/item/paper/safe_code/LateInitialize(mapload)
	. = ..()
	for(var/safe in GLOB.safes)
		var/obj/structure/safe/S = safe
		if(owner in S.known_by)
			info += "<br> The combination for the safe located in the [get_area(S).name] is: [S.get_combination()]<br>"
			info_links = info
			update_icon()
