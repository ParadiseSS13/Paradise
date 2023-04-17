/*
 *	Absorbs /obj/item/secstorage.
 *	Reimplements it only slightly to use existing storage functionality.
 *
 *	Contains:
 *		Secure Briefcase
 *		Wall Safe
 */

// -----------------------------
//         Generic Item
// -----------------------------
/obj/item/storage/secure
	name = "secstorage"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/locked = TRUE
	var/code = ""
	var/l_code = null
	var/l_set = FALSE
	var/l_setshort = FALSE
	var/l_hacking = FALSE
	var/emagged = FALSE
	var/open = FALSE
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 14

/obj/item/storage/secure/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += "<span class='notice'>The service panel is [open ? "open" : "closed"].</span>"

/obj/item/storage/secure/attackby(obj/item/W, mob/user, params)
	if(locked)
		if((istype(W, /obj/item/melee/energy/blade)) && (!emagged))
			emag_act(user, W)

		if(istype(W, /obj/item/screwdriver))
			if(do_after(user, 20 * W.toolspeed * gettoolspeedmod(user), target = src))
				open = !open
				user.show_message("<span class='notice'>You [open ? "open" : "close"] the service panel.</span>", 1)
			return

		if((istype(W, /obj/item/multitool)) && (open) && (!l_hacking))
			user.show_message("<span class='danger'>Now attempting to reset internal memory, please hold.</span>", 1)
			l_hacking = TRUE
			if(do_after(user, 100 * W.toolspeed * gettoolspeedmod(user), target = src))
				if(prob(40))
					l_setshort = TRUE
					l_set = FALSE
					user.show_message("<span class='danger'>Internal memory reset. Please give it a few seconds to reinitialize.</span>", 1)
					sleep(80)
					l_setshort = FALSE
					l_hacking = FALSE
				else
					user.show_message("<span class='danger'>Unable to reset internal memory.</span>", 1)
					l_hacking = FALSE
			else
				l_hacking = FALSE
			return
		//At this point you have exhausted all the special things to do when locked
		// ... but it's still locked.
		return

	return ..()

/obj/item/storage/secure/emag_act(mob/user, obj/weapon)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		overlays += image('icons/obj/storage.dmi', icon_sparking)
		sleep(6)
		overlays.Cut()
		overlays += image('icons/obj/storage.dmi', icon_locking)
		locked = FALSE
		if(istype(weapon, /obj/item/melee/energy/blade))
			do_sparks(5, 0, loc)
			playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
			playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			to_chat(user, "You slice through the lock on [src].")
		else
			to_chat(user, "You short out the lock on [src].")
		return

/obj/item/storage/secure/AltClick(mob/living/user)
	if(istype(user) && !try_to_open())
		return FALSE
	return ..()

/obj/item/storage/secure/MouseDrop(over_object, src_location, over_location)
	if(!try_to_open())
		return FALSE
	return ..()

/obj/item/storage/secure/proc/try_to_open()
	if(locked)
		add_fingerprint(usr)
		to_chat(usr, "<span class='warning'>It's locked!</span>")
		return FALSE
	return TRUE

/obj/item/storage/secure/attack_self(mob/user)
	user.set_machine(src)
	ui_interact(user)

/obj/item/storage/secure/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SecureStorage", name, 520, 200)
		ui.open()

/obj/item/storage/secure/ui_data(mob/user)
	var/list/data = list()

	data["emagged"] = emagged
	data["locked"] = locked
	data["l_set"] = l_set
	data["l_setshort"] = l_setshort
	data["current_code"] = (code) ? (isnum(text2num(code))) ? code : "ERROR" : FALSE
	return data


/obj/item/storage/secure/ui_act(action, params)
	if(..())
		return

	if(!usr.IsAdvancedToolUser() && !isobserver(usr))
		to_chat(usr, "<span class='warning'>You are not able to operate [src].</span>")
		return

	. = TRUE
	switch(action)
		if("close")
			locked = TRUE
			overlays.Cut()
			code = null
			close(usr)
		if("setnumber")
			switch(params["buttonValue"])
				if("E")
					if(!l_set && (length(code) == 5) && (code != "ERROR"))
						l_code = code
						l_set = TRUE
						to_chat(usr, "<span class = 'notice'>The code was set successfully.</span>")
					else if((code == l_code) && l_set)
						locked = FALSE
						overlays.Cut()
						overlays += image('icons/obj/storage.dmi', icon_opened)
						code = null
					else
						code = "ERROR"
				if("R")
					code = null
				else
					code += text("[]", params["buttonValue"])
					if(length(code) > 5 )
						code = "ERROR"

/obj/item/storage/secure/can_be_inserted(obj/item/W, stop_messages = 0)
	if(!locked)
		return ..()
	if(!stop_messages)
		to_chat(usr, "<span class='notice'>[src] is locked!</span>")
	return FALSE

/obj/item/storage/secure/hear_talk(mob/living/M, list/message_pieces)
	return

/obj/item/storage/secure/hear_message(mob/living/M, msg)
	return

// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/storage/secure/briefcase
	name = "secure briefcase"
	desc = "A large briefcase with a digital locking system."
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	item_state = "sec-case"
	flags = CONDUCT
	hitsound = "swing_hit"
	force = 8
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")

/obj/item/storage/secure/briefcase/New()
	..()
	handle_item_insertion(new /obj/item/paper, 1)
	handle_item_insertion(new /obj/item/pen, 1)

/obj/item/storage/secure/briefcase/attack_hand(mob/user)
	if((loc == user) && locked)
		to_chat(usr, "<span class='warning'>[src] is locked and cannot be opened!</span>")
	else if((loc == user) && !locked)
		playsound(loc, "rustle", 50, 1, -5)
		user.s_active?.close(user) //Close and re-open
		show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if(M.s_active == src)
				close(M)
		orient2hud(user)
	add_fingerprint(user)
	return

//Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/storage/secure/briefcase/syndie
	force = 15

/obj/item/storage/secure/briefcase/syndie/New()
	..()
	for(var/i in 1 to (storage_slots - 2))
		handle_item_insertion(new /obj/item/stack/spacecash/c1000, 1)

// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	force = 8
	w_class = WEIGHT_CLASS_HUGE
	max_w_class = 8
	anchored = 1
	density = 0
	cant_hold = list(/obj/item/storage/secure/briefcase)

/obj/item/storage/secure/safe/New()
	..()
	handle_item_insertion(new /obj/item/paper, 1)
	handle_item_insertion(new /obj/item/pen, 1)

/obj/item/storage/secure/safe/attack_hand(mob/user)
	return attack_self(user)
