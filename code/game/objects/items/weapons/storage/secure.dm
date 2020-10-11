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
	var/title = "Secure Storage"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/locked = TRUE
	var/error = null // error displayed to the user, machine not usable while error displayed
	var/code = "" // stores the user input
	var/l_code_len = 5 // The length of a valid code
	var/l_code = null // the secret code to unlock the device
	var/l_set = FALSE // has the code been set?
	var/l_hacking = FALSE // set to true while the user is attempting to reset the device. Prevents spamming multitool
	var/emagged = FALSE // set to true once emagged, cannot be undone
	var/open = FALSE // is the service panel open?
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 14

/obj/item/storage/secure/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += "The service panel is [open ? "open" : "closed"]."

/obj/item/storage/secure/attackby(obj/item/W, mob/user)
	if(!locked)
		return ..()

	if(!emagged && istype(W, /obj/item/melee/energy/blade))
		emag_act(user, W)

	else if(istype(W, /obj/item/screwdriver))
		if(do_after(user, 20 * W.toolspeed, target = src))
			open = !open
			user.show_message("<span class='notice'>You [open ? "open" : "close"] the service panel.</span>", 1)

	else if(istype(W, /obj/item/multitool) && open && !l_hacking)
		start_resetting(W, user)

	//At this point you have exhausted all the special things to do when locked
	// ... but it's still locked.
	return // ..()?

/obj/item/storage/secure/proc/start_resetting(obj/item/W, mob/user)
	if(l_hacking)
		return

	user.show_message("<span class='danger'>Now attempting to reset internal memory, please hold.</span>", 1)
	l_hacking = TRUE

	if(do_after(usr, 100 * W.toolspeed, target = src))
		if(prob(40))
			l_set = FALSE
			user.show_message("<span class='danger'>Internal memory reset. Please give it a few seconds to reinitialize.</span>", 1)
			set_error("ALERT: MEMORY SYSTEM ERROR - 6040 201")
			addtimer(CALLBACK(src, .proc/finish_resetting), 80)
		else
			user.show_message("<span class='danger'>Unable to reset internal memory.</span>", 1)
			l_hacking = FALSE
	else
		l_hacking = FALSE


/obj/item/storage/secure/proc/finish_resetting()
	l_hacking = FALSE

/obj/item/storage/secure/emag_act(mob/user, obj/weapon)
	if(emagged)
		return
	emagged = TRUE
	overlays += image('icons/obj/storage.dmi', icon_sparking)
	addtimer(CALLBACK(src, .proc/finish_emag_act, user, weapon), 6)

/obj/item/storage/secure/proc/finish_emag_act(mob/user, obj/weapon)
	overlays = null
	overlays += image('icons/obj/storage.dmi', icon_locking)
	locked = FALSE
	if(istype(weapon, /obj/item/melee/energy/blade))
		do_sparks(5, 0, loc)
		playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
		playsound(loc, "sparks", 50, 1)
		to_chat(user, "You slice through the lock on [src].")
	else
		to_chat(user, "You short out the lock on [src].")

/obj/item/storage/secure/AltClick(mob/user)
	if(!try_to_open())
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

/obj/item/storage/secure/attack_self(mob/user as mob)
	tgui_interact(user)///????

/obj/item/storage/secure/attack_hand(mob/user)
	if(..())
		return
	if(is_away_level(z))
		// todo fix? close ui on leave?
		to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the station!")
		return
	add_fingerprint(user)
	tgui_interact(user)

/obj/item/storage/secure/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SecureSafe", title, 280, 340)
		ui.open()

/obj/item/storage/secure/tgui_data(mob/user)
	var/list/data = list(\
		"l_set" = l_set,\
		"l_code_len" = l_code_len,\
		"emagged" = emagged,\
		"locked" = locked,\
		"code" = code,\
		"error" = error,\
	)
	return data


/obj/item/storage/secure/proc/set_error(msg)
	error = msg
	addtimer(CALLBACK(src, .proc/clear_error), 50) // todo prevent multiple calls?

/obj/item/storage/secure/proc/clear_error()
	error = null

/obj/item/storage/secure/proc/add_number(user_input)
	if(!locked)
		return FALSE

	var/num = round(text2num(user_input))

	if(num < 0 || num > 9)
		set_error("Invalid number added")
		return FALSE

	if(length(code) >= l_code_len)
		set_error("Code too long")
		// todo buzz?
		return FALSE

	code += num2text(num)

	return TRUE

/obj/item/storage/secure/proc/lock()
	locked = TRUE
	code = ""
	overlays = null

/obj/item/storage/secure/proc/unlock()
	locked = FALSE
	code = ""
	overlays = null
	overlays += image('icons/obj/storage.dmi', icon_opened)

/obj/item/storage/secure/tgui_act(action, params)
	//if(usr.incapacitated() || (get_dist(src, usr) > 1))
	//	return ???
	if(emagged || error)
		return TRUE

	switch(action)
		if("reset")
			lock()

		if("enter")
			if(l_set)
				if(code == l_code)
					// user entered matching code when code set
					unlock()
				else
					set_error("Incorrect code")
					code = ""
			else
				if(length(code) == l_code_len)
					// user entered a valid new code when no code set
					set_error("New code accepted")
					l_code = code
					l_set = TRUE
					unlock()
				else
					set_error("Code not long enough")
					code = ""
					// buzz?

		if("addCode")
			add_number(params["number"])

	add_fingerprint(usr)
	for(var/mob/M in viewers(1, loc))
		if(M.client && M.machine == src)
			attack_self(M) //?
		return

	return TRUE

/obj/item/storage/secure/can_be_inserted(obj/item/W, stop_messages = FALSE)
	if(!locked)
		return ..()
	if(!stop_messages)
		to_chat(usr, "<span class='notice'>[src] is locked!</span>")
	return 0

/obj/item/storage/secure/hear_talk(mob/living/M, list/message_pieces)
	return

/obj/item/storage/secure/hear_message(mob/living/M, msg)
	return

// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/storage/secure/briefcase
	name = "secure briefcase"
	title = "Secure Breifcase"
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
	if(loc == user)
		if(locked)
			to_chat(usr, "<span class='warning'>[src] is locked and cannot be opened!</span>")
		else
			playsound(loc, "rustle", 50, 1, -5)
			if(user.s_active)
				user.s_active.close(user) //Close and re-open
			show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if(M.s_active == src)
				close(M)
		orient2hud(user)
	add_fingerprint(user)

//Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/storage/secure/briefcase/syndie
	force = 15

/obj/item/storage/secure/briefcase/syndie/New()
	..()
	for(var/i = 0, i < storage_slots - 2, i++)
		handle_item_insertion(new /obj/item/stack/spacecash/c1000, 1)

// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/storage/secure/safe
	name = "secure safe"
	title = "Secure Safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	force = 8
	w_class = WEIGHT_CLASS_HUGE
	max_w_class = 8
	anchored = TRUE
	density = 0
	cant_hold = list(/obj/item/storage/secure/briefcase)

/obj/item/storage/secure/safe/New()
	..()
	handle_item_insertion(new /obj/item/paper, 1)
	handle_item_insertion(new /obj/item/pen, 1)

/obj/item/storage/secure/safe/attack_hand(mob/user as mob)
	return attack_self(user)
