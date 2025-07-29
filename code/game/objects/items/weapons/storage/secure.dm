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

	/// Are we locked?
	var/locked = TRUE
	/// What is our code to open?
	var/code
	/// Is our hacking panel open?
	var/panel_open = FALSE
	/// What has the user entered to guess the code
	var/user_entered_code
	/// Stops people from spamming enter like an idiot
	COOLDOWN_DECLARE(enter_spam)

/obj/item/storage/secure/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += "The service panel is [panel_open ? "open" : "closed"]."

/obj/item/storage/secure/populate_contents()
	new /obj/item/paper(src)
	new /obj/item/pen(src)

/obj/item/storage/secure/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob, params)
	if(locked)
		if((istype(W, /obj/item/melee/energy/blade)) && (!emagged))
			emag_act(user, W)

		//At this point you have exhausted all the special things to do when locked
		// ... but it's still locked.
		return

	return ..()

/obj/item/storage/secure/screwdriver_act(mob/living/user, obj/item/I)
	if(I.use_tool(src, user, 2 SECONDS * I.toolspeed, volume = 10))
		panel_open = !panel_open
		user.visible_message("<span class='notice'>[user] [panel_open ? "opens" : "closes"] the service panel on [src].</span>", "<span class='notice'>You [panel_open ? "open" : "close"] the service panel.</span>")
	return TRUE

/obj/item/storage/secure/multitool_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	to_chat(user, "<span class='notice'>You start fiddling with the internal memory mechanisms.</span>")
	if(do_after_once(user, 10 SECONDS * I.toolspeed, target = src))
		if(prob(40))
			to_chat(user, "<span class='notice'>The screen dims, the internal memory seems to be reset.</span>")
			code = null
		else
			to_chat(user, "<span class='notice'>The screen flashes, and then goes back to normal.</span>")


/obj/item/storage/secure/emag_act(user, weapon)
	if(!emagged)
		emagged = TRUE
		flick_overlay_view(image(icon, src, icon_sparking), src, 0.9 SECONDS)
		locked = FALSE
		update_icon(UPDATE_OVERLAYS)
		if(istype(weapon, /obj/item/melee/energy/blade))
			do_sparks(5, 0, loc)
			playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
			playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			to_chat(user, "You slice through the lock on [src].")
		else
			to_chat(user, "You short out the lock on [src].")
			return TRUE

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


/obj/item/storage/secure/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	if(!locked)
		return ..()
	if(!stop_messages)
		to_chat(usr, "<span class='notice'>[src] is locked!</span>")
	return FALSE

/obj/item/storage/secure/update_overlays()
	. = ..()
	if(isnull(code))
		return
	if(locked)
		. += icon_locking
	else
		. += icon_opened

/obj/item/storage/secure/hear_talk(mob/living/M as mob, list/message_pieces)
	return

/obj/item/storage/secure/hear_message(mob/living/M as mob, msg)
	return

/obj/item/storage/secure/attack_self__legacy__attackchain(mob/user)
	ui_interact(user)

/obj/item/storage/secure/ui_state(mob/user)
	return GLOB.default_state

/obj/item/storage/secure/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SecureStorage", name)
		ui.open()

/obj/item/storage/secure/ui_data(mob/user)
	var/list/data = list()
	data["locked"] = locked
	data["user_entered_code"] = user_entered_code
	data["no_passcode"] = isnull(code)
	data["emagged"] = emagged
	return data

/obj/item/storage/secure/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	add_fingerprint(usr)

	if(!COOLDOWN_FINISHED(src, enter_spam))
		return

	. = TRUE

	switch(action)
		if("keypad")
			if(emagged)
				return FALSE

			var/digit = params["digit"]
			switch(digit)
				if("E")
					if(isnull(code))
						if(length(user_entered_code) != 5)
							return FALSE
						code = user_entered_code
						to_chat(ui.user, "<span class='notice'>You set the code to [code].</span>")
						locked = FALSE
					else if(!locked)
						locked = TRUE
						to_chat(ui.user, "<span class='notice'>You lock [src].</span>")
					else if(user_entered_code == code) // correct code!
						locked = FALSE
						to_chat(ui.user, "<span class='notice'>You unlock [src].</span>")
					update_icon(UPDATE_OVERLAYS)
					COOLDOWN_START(src, enter_spam, 0.1 SECONDS)
				if("C")
					user_entered_code = null
					COOLDOWN_START(src, enter_spam, 0.1 SECONDS)
				else
					if(!isnum(text2num(digit)))
						return FALSE
					if(length(user_entered_code) >= 5)
						return FALSE
					user_entered_code = copytext("[user_entered_code][digit]", 1, 6)

		if("backspace")
			if(emagged)
				return FALSE
			user_entered_code = copytext(user_entered_code, 1, length(user_entered_code))
			COOLDOWN_START(src, enter_spam, 0.1 SECONDS)

	playsound(src, "terminal_type", 10, 1)

// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/storage/secure/briefcase
	name = "secure briefcase"
	desc = "A large briefcase with a digital locking system."
	icon_state = "secure"
	inhand_icon_state = "sec-case"
	flags = CONDUCT
	hitsound = "swing_hit"
	use_sound = 'sound/effects/briefcase.ogg'
	force = 8
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")

/obj/item/storage/secure/briefcase/attack_hand(mob/user as mob)
	if(loc == user && locked)
		to_chat(usr, "<span class='warning'>[src] is locked and cannot be opened!</span>")
	else if((loc == user) && !locked)
		playsound(loc, 'sound/effects/briefcase.ogg', 50, TRUE, -5)
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
	return

//Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/storage/secure/briefcase/syndie
	force = 15

/obj/item/storage/secure/briefcase/syndie/populate_contents()
	..()
	for(var/I in 1 to 3)
		new /obj/item/stack/spacecash/c200(src)

// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/storage/secure/safe
	name = "secure safe"
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = null
	icon_sparking = "safespark"
	force = 8
	w_class = WEIGHT_CLASS_HUGE
	max_w_class = 8
	anchored = TRUE
	cant_hold = list(/obj/item/storage/secure/briefcase)

/obj/item/storage/secure/safe/attack_hand(mob/user as mob)
	ui_interact(user)
