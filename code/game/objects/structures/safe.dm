/*
CONTAINS:
SAFES
FLOOR SAFES
Safe Codes
Safe Internals
*/

GLOBAL_LIST_EMPTY(safes)

//SAFES
/obj/structure/safe
	name = "\improper Safe"
	desc = "A huge chunk of metal with a dial embedded in it. Fine print on the dial reads \"Scarborough Arms - 2 tumbler safe, guaranteed thermite resistant, explosion resistant, and assistant resistant.\""
	icon = 'icons/obj/structures.dmi'
	icon_state = "safe"
	anchored = 1
	density = 1
	var/open = FALSE	//is the safe open?
	var/locked = TRUE
	var/tumbler_1_pos	//the tumbler position- from 0 to 72
	var/tumbler_1_open	//the tumbler position to open at- 0 to 72
	var/tumbler_2_pos
	var/tumbler_2_open
	var/open_pos
	var/dial = 0		//where is the dial pointing?
	var/space = 0		//the combined w_class of everything in the safe
	var/maxspace = 24	//the maximum combined w_class of stuff in the safe
	var/combo_to_open	//so admins know the code
	var/obj/item/thermal_drill/drill = null
	var/drill_timer
	var/time_to_drill
	var/image/bar
	var/drill_start_time
	var/drill_x_offset = -13
	var/drill_y_offset = -3
	var/knownby = list()


/obj/structure/safe/New()
	GLOB.safes += src
	tumbler_2_pos = rand(0, 99) // first value in the combination set first
	tumbler_2_open = rand(0, 99)

	tumbler_1_pos = rand(0, 99)
	do
	tumbler_1_open = rand(0, 99)
	while(tumbler_1_open > Wrap(tumbler_2_open +48, 0, 100) && tumbler_1_open < Wrap(tumbler_2_open + 53, 0, 100)) // prevents a combination that wont open
	do
		open_pos = rand(0,99)
	while(open_pos > Wrap(tumbler_1_open - 2, 0, 100) && open_pos < Wrap(tumbler_1_open + 2, 0, 100)) // prevents a combination that wont open
	var/num1 = tumbler_2_open + 54
	if(num1 > 99)
		num1 = num1 - 100
	var/num2 = tumbler_1_open + 98
	if(num2 > 99)
		num2 = num2 - 100

	combo_to_open = "[num1] - [num2]"


/obj/structure/safe/Initialize()
	..()
	for(var/obj/item/I in loc)
		if(space >= maxspace)
			return
		if(I.w_class + space <= maxspace)
			space += I.w_class
			I.loc = src


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
			visible_message("<i><b>[pick("Spring", "Sprang", "Sproing", "Clunk", "Krunk")]!</b></i>")

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
	if(istype(drill, /obj/item/thermal_drill/diamond_drill))
		if(drill_timer)
			overlays += image(icon = 'icons/effects/drill.dmi', icon_state = "[initial(icon_state)]_d-drill-on", pixel_x = drill_x_offset, pixel_y = drill_y_offset)
		else
			overlays += image(icon = 'icons/effects/drill.dmi', icon_state = "[initial(icon_state)]_d-drill-off", pixel_x = drill_x_offset, pixel_y = drill_y_offset)
	else if(istype(drill, /obj/item/thermal_drill))
		if(drill_timer)
			overlays += image(icon = 'icons/effects/drill.dmi', icon_state = "[initial(icon_state)]_h-drill-on", pixel_x = drill_x_offset, pixel_y = drill_y_offset)
		else
			overlays += image(icon = 'icons/effects/drill.dmi', icon_state = "[initial(icon_state)]_h-drill-off", pixel_x = drill_x_offset, pixel_y = drill_y_offset)

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
	return

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
	else
		contents_names = list(list("name" = "you're"), list("name" = "a"), list("name" = "cheater"))

	data["dial"] = dial
	data["open"] = open
	data["locked"] = locked
	data["rotation"] = "[-dial*3.6]deg"
	data["contents"] = contents_names

	return data


/obj/structure/safe/Topic(href, href_list)
	if(..())
		return TRUE

	var/canhear = 0
	if(!ishuman(usr))
		to_chat(usr, "You don't have hands to operate the safe!")
		return FALSE

	var/mob/living/carbon/human/user = usr
	if(istype(user.l_hand, /obj/item/clothing/accessory/stethoscope) || istype(user.r_hand, /obj/item/clothing/accessory/stethoscope))
		canhear = 1

	if(href_list["open"])
		if(check_unlocked() || open || broken)
			to_chat(user, "<span class='notice'>You [open ? "close" : "open"] [src].</span>")
			open = !open
			update_icon()
		else
			to_chat(user, "<span class='warning'>You can't open [src], the lock is engaged!</span>")
		.= TRUE
		SSnanoui.update_uis(src)

	if(href_list["decrement"])
		var/ticks = text2num(href_list["decrement"])
		if(open)
			return
		if(broken)
			to_chat(user, "The dial will not turn, the mechanism is destroyed.")
			return
		for(var/i=1 to ticks)
			if(!check_unlocked())
				dial = Wrap(dial - 1, 0 ,100)
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
		.= TRUE

	if(href_list["increment"])
		var/ticks = text2num(href_list["increment"])
		if(open)
			return
		if(broken)
			to_chat(user, "The dial will not turn, the mechanism is destroyed.")
			return
		for(var/i=1 to ticks)
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
		.= TRUE

	if(href_list["retrieve"])
		var/index = text2num(href_list["retrieve"])
		if(index > 0 && index <= contents.len)
			var/obj/item/P = contents[index]
			if(open)
				if(P && in_range(src, user))
					user.put_in_hands(P)
					space -= P.w_class
		SSnanoui.update_uis(src)
		.= TRUE


	updateUsrDialog()
	return


/obj/structure/safe/attackby(obj/item/I, mob/user, params)
	if(open)
		if(broken && istype(I, /obj/item/safe_internals) && do_after(user, 2 SECONDS, target = src))
			to_chat(user, "You replace the broken mechanism.")
			qdel(I)
			broken = !broken
			update_icon()
			return
		else if(I.w_class + space <= maxspace)
			space += I.w_class
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>\The [I] is stuck to your hand, you cannot put it in the safe!</span>")
				return
			I.loc = src
			to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
			updateUsrDialog()
			return
		else
			to_chat(user, "<span class='notice'>[I] won't fit in [src].</span>")
			return
	else
		if(istype(I, /obj/item/clothing/accessory/stethoscope))
			to_chat(user, "<span class='warning'>Hold [I] in one of your hands while you manipulate the dial!</span>")
			return
		else if(istype(I, /obj/item/thermal_drill))
			if(drill)
				to_chat(user, "There is already a drill attached!")
			else if(do_after(user, 2 SECONDS, target = src))
				if(!user.drop_item())
					to_chat(user, "<span class='warning'>[I] is stuck to your hand, you cannot put it in the safe!</span>")
					return
				I.loc = src
				drill = I
				time_to_drill = 300 SECONDS * drill.time_multiplier
				update_icon()
		else
			to_chat(user, "<span class='warning'>You can't put [I] in into the safe while it is closed!</span>")
			return

/obj/structure/safe/proc/drill_open()
	broken = TRUE
	drill_timer = null
	drill.soundloop.stop()
	update_icon()
	processing_objects.Remove(src)

/obj/structure/safe/blob_act()
	return

/obj/structure/safe/ex_act(severity)
	return

/obj/structure/safe/examine_status(mob/user)
	return

/obj/structure/safe/Destroy()
	GLOB.safes -= src
	drill?.soundloop?.stop()
	return ..()

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
		to_chat(user, "On the inside of the the door is <b>[combo_to_open]</b>")

//FLOOR SAFES
/obj/structure/safe/floor
	name = "floor safe"
	icon_state = "floorsafe"
	density = 0
	level = 1	//underfloor
	layer = 2.5
	drill_x_offset = -1
	drill_y_offset = 20

/obj/structure/safe/floor/Initialize()
	..()
	var/turf/T = loc
	hide(T.intact)

/obj/structure/safe/floor/hide(var/intact)
	invisibility = intact ? 101 : 0

/obj/item/safe_internals
	name = "safe internals"
	desc = "The mechanism and locking bolts for a Scarborough Arms - 2 tumbler safe"
	icon_state = "safe_internals"

/obj/item/paper/safe_code
	name = "safe codes"
	var/owner
	info = "<div style='text-align:center;'><img src='ntlogo.png'><center><h3>Safe Codes</h3></center>"

/obj/item/paper/safe_code/New()
	..()
	addtimer(CALLBACK(src, .proc/populate_codes), 10)

/obj/item/paper/safe_code/proc/populate_codes()
	for(var/safe in GLOB.safes)
		var/obj/structure/safe/S = safe
		if(owner in S.knownby)
			info += "<br> The combination for the safe located in the [get_area(S).name] is: [S.combo_to_open]<br>"
			info_links = info
			update_icon()