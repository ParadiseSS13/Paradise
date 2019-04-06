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
	desc = "A huge chunk of metal with a dial embedded in it. Fine print on the dial reads \"Scarborough Arms - 2 tumbler safe, guaranteed thermite resistant, explosion resistant, and assistant resistant.\""
	icon = 'icons/obj/structures.dmi'
	icon_state = "safe"
	
	anchored = TRUE
	density = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	unacidable = TRUE

	var/open = FALSE
	var/locked = TRUE
	var/dial = 0		//the position the dial is pointing to

	var/tumbler_1_pos	//the tumbler position, between 0 and 99
	var/tumbler_1_open	//the tumbler position to open the safe, between 0 and 99
	var/tumbler_2_pos
	var/tumbler_2_open
	var/open_pos		//the position to open the safe

	var/space = 0		//the combined w_class of everything in the safe
	var/maxspace = 24	//the maximum combined w_class of stuff in the safe

	var/obj/item/thermal_drill/drill = null
	var/drill_timer
	var/time_to_drill
	var/image/bar
	var/drill_start_time
	var/drill_x_offset = -13
	var/drill_y_offset = -3
	var/known_by = list()

/obj/structure/safe/New()
	GLOB.safes += src

	tumbler_1_pos = rand(0, 99)
	tumbler_1_open = rand(0, 99)
	
	tumbler_2_pos = rand(0, 99)
	tumbler_2_open = rand(0, 99)

/obj/structure/safe/Initialize(mapload)
	. = ..()
	for(var/obj/item/I in loc)
		if(space >= maxspace)
			return
		if(I.w_class + space <= maxspace)
			space += I.w_class
			I.forceMove(src)

/obj/structure/safe/Destroy()
	GLOB.safes -= src
	drill?.soundloop?.stop()
	return ..()

/obj/structure/safe/blob_act()
	return

/obj/structure/safe/ex_act(severity)
	return

/obj/structure/safe/examine_status(mob/user)
	return

/obj/structure/safe/proc/check_unlocked()
	if(tumbler_1_pos == tumbler_1_open && tumbler_2_pos == tumbler_2_open && dial == open_pos)
		locked = FALSE
		return TRUE

	locked = TRUE
	return FALSE

/obj/structure/safe/proc/make_noise(turns, turns_total, tum1 = 0, tum2 = 0, mob/user, canhear)
	if(user && canhear)
		if(turns == 2)
			to_chat(user, "<span class='italics'>The sounds from [src] are too fast and blend together.</span>")
		if(tum1 && (turns_total == 1 || prob(10))) // So multi turns dont super spam the chat
			to_chat(user, "<span class='italics'>You hear a [pick("clack", "scrape", "clank")] from [src].</span>")
		if(tum2 && (turns_total == 1 || prob(10))) // So multi turns dont super spam the chat
			to_chat(user, "<span class='italics'>You hear a [pick("click", "chink", "clink")] from [src].</span>")
		if(tumbler_1_pos == tumbler_1_open && turns_total == 1 && tum1) // You cant hear tumblers if you spin fast!
			to_chat(user, "<span class='italics'>You hear a [pick("tonk", "krunk", "plunk")] from [src].</span>")
		if(tumbler_2_pos == tumbler_2_open && turns_total == 1 && tum2) // You cant hear tumblers if you spin fast!
			to_chat(user, "<span class='italics'>You hear a [pick("tink", "krink", "plink")] from [src].</span>")

	if(!locked)
		if(user)
			visible_message("<span class='boldnotice'>[pick("Spring", "Sprang", "Sproing", "Clunk", "Krunk")]!</span>")

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

	overlays.Cut()

	if(istype(drill, /obj/item/thermal_drill))
		var/drill_icon = istype(drill, /obj/item/thermal_drill/diamond_drill) ? "d" : "h"
		if(drill_timer)
			overlays += image(icon = 'icons/effects/drill.dmi', icon_state = "[initial(icon_state)]_[drill_icon]-drill-on", pixel_x = drill_x_offset, pixel_y = drill_y_offset)
		else
			overlays += image(icon = 'icons/effects/drill.dmi', icon_state = "[initial(icon_state)]_[drill_icon]-drill-off", pixel_x = drill_x_offset, pixel_y = drill_y_offset)

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
					processing_objects.Add(src)
			if("Turn Off")
				if(do_after(user, 2 SECONDS, target = src))
					deltimer(drill_timer)
					drill_timer = null
					drill.soundloop.stop()
					update_icon()
					processing_objects.Remove(src)
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

/obj/structure/safe/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
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

/obj/structure/safe/Topic(href, href_list)
	if(..())
		return TRUE

	var/mob/user = usr
	if (!user.IsAdvancedToolUser() && !isobserver(user))
		to_chat(user, "<span class='warning'>You're not able to operate the safe.</span>")
		return

	var/canhear = FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.is_in_hands(/obj/item/clothing/accessory/stethoscope))
			canhear = TRUE

	if(href_list["open"])
		if(check_unlocked() || open || broken)
			to_chat(user, "<span class='notice'>You [open ? "close" : "open"] [src].</span>")
			open = !open
			update_icon()
		else
			to_chat(user, "<span class='warning'>You can't open [src], as its lock is engaged!</span>")
		. = TRUE

	if(href_list["decrement"])
		if(open)
			return

		if(broken)
			to_chat(user, "<span class='warning'>The dial will not turn, as the mechanism is destroyed.</span>")
			return

		var/ticks = text2num(href_list["decrement"])
		for(var/i = 1 to ticks)
			if(!check_unlocked())
				dial = Wrap(dial - 1, 0, 100)
				if(dial == tumbler_1_pos + 1 || dial == tumbler_1_pos - 99)
					tumbler_1_pos = Wrap(tumbler_1_pos - 1, 0, 100)
					make_noise(i, ticks, 1, 0, user, canhear)
					if(tumbler_1_pos == tumbler_2_pos + 51 || tumbler_1_pos == tumbler_2_pos - 49)
						tumbler_2_pos = Wrap(tumbler_2_pos - 1, 0, 100)
						make_noise(0, ticks, 0, 1, user, canhear)
			sleep(1)
			check_unlocked()
			SSnanoui.update_uis(src)
		make_noise(0, 0, 0, 0, user, canhear)
		. = TRUE

	if(href_list["increment"])
		if(open)
			return

		if(broken)
			to_chat(user, "<span class='warning'>The dial will not turn, as the mechanism is destroyed.</span>")
			return

		var/ticks = text2num(href_list["increment"])
		for(var/i = 1 to ticks)
			check_unlocked()
			dial = Wrap(dial + 1, 0, 100)
			if(dial == tumbler_1_pos - 1 || dial == tumbler_1_pos + 99)
				tumbler_1_pos = Wrap(tumbler_1_pos + 1, 0, 100)
				make_noise(i, ticks, 1, 0, user, canhear)
				if(tumbler_1_pos == tumbler_2_pos - 51 || tumbler_1_pos == tumbler_2_pos + 49)
					tumbler_2_pos = Wrap(tumbler_2_pos + 1, 0, 100)
					make_noise(0, ticks, 0, 1, user, canhear)
			sleep(1)
			SSnanoui.update_uis(src)
		make_noise(0, 0, 0, 0, user, canhear)
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

/obj/structure/safe/proc/drill_open()
	broken = TRUE
	drill_timer = null
	drill.soundloop.stop()
	update_icon()
	processing_objects.Remove(src)

/obj/structure/safe/process()
	if(drill_timer)
		overlays -= bar
		bar = image('icons/effects/progessbar.dmi', src, "prog_bar_[round((((world.time - drill_start_time) / time_to_drill) * 100), 5)]", HUD_LAYER)
		overlays += bar
		if(prob(15))
			drill.spark_system.start()

/obj/structure/safe/examine(mob/user)
	..()
	if(open)
		to_chat(user, "On the inside of the the door is <b>[tumbler_1_open] - [tumbler_2_open]</b>")

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
	. = ..()
	for(var/safe in GLOB.safes)
		var/obj/structure/safe/S = safe
		if(owner in S.known_by)
			info += "<br> The combination for the safe located in the [get_area(S).name] is: [S.tumbler_1_open] - [S.tumbler_2_open]]<br>"
			info_links = info
			update_icon()
