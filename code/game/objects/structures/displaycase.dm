/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox"
	desc = "A display case for prized possessions."
	density = TRUE
	anchored = TRUE
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 30, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, RAD = 0, FIRE = 70, ACID = 100)
	max_integrity = 200
	integrity_failure = 50
	/// The object stored inside.
	var/obj/item/showpiece
	/// If true, this is alarmed and will set off a siren when opened without proper access.
	var/alert = FALSE
	/// If this is currently unlocked
	var/open = FALSE
	/// If false, this can never be opened, and the item inside should be inaccessible. Good for showcases.
	var/openable = TRUE
	/// The electronics currently installed in this showpiece.
	var/obj/item/airlock_electronics/electronics
	/// The type that should be instantiated to fill the showpiece.
	var/start_showpiece_type
	/// A list of random items that could possibly fill the case, as well as a flavor message for them.
	/// Takes sublists in the form of list("type" = /obj/item/bikehorn, "trophy_message" = "henk")
	var/list/start_showpieces = list()
	/// A flavor message to show with this item.
	var/trophy_message = ""
	/// Do we want to force alarms even if off station?
	var/force_alarm = FALSE

/obj/structure/displaycase/Initialize(mapload)
	. = ..()
	if(length(start_showpieces) && !start_showpiece_type)
		var/list/showpiece_entry = pick(start_showpieces)
		if(showpiece_entry && showpiece_entry["type"])
			start_showpiece_type = showpiece_entry["type"]
			if(showpiece_entry["trophy_message"])
				trophy_message = showpiece_entry["trophy_message"]
	if(start_showpiece_type)
		showpiece = new start_showpiece_type(src)
	update_icon(UPDATE_OVERLAYS)

/obj/structure/displaycase/Destroy()
	QDEL_NULL(electronics)
	QDEL_NULL(showpiece)
	return ..()

/obj/structure/displaycase/emag_act(mob/user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You override the ID lock on [src].</span>")
		trigger_alarm()

		emagged = TRUE
		toggle_lock()
		return TRUE

/obj/structure/displaycase/examine(mob/user)
	. = ..()
	if(showpiece)
		. += "<span class='notice'>There's \a [showpiece] displayed inside.</span>"
	else
		. += "<span class='notice'>It's empty.</span>"
	if(trophy_message)
		. += "The plaque reads:\n [trophy_message]"
	if(!openable)
		. += "<span class='notice'>It seems to be sealed shut, there's no way you're getting that open.</span>"
	else
		if(!open)
			. += "<span class='notice'>The ID lock is active, you need to swipe an ID to open it.</span>"
		else if((broken || open) && showpiece)
			. += "<span class='notice'>[showpiece] is held in a loose low gravity suspension field. You can take [showpiece] out[broken ? "." : ", or lock [src] with an ID"].</span>"

	if(alert)
		. += "<span class='notice'>It is hooked up with an anti-theft system.</span>"
	if(emagged)
		. += "<span class='warning'>The ID lock has been shorted out.</span>"

/obj/structure/displaycase/proc/dump(mob/user)
	if(showpiece)
		if(!user || !user.put_in_hands(showpiece))
			showpiece.forceMove(loc)
		showpiece = null

/obj/structure/displaycase/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/displaycase/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		dump()
		if(!disassembled)
			new /obj/item/shard(drop_location())
			trigger_alarm()
	qdel(src)

/obj/structure/displaycase/obj_break(damage_flag)
	if(!broken && !(flags & NODECONSTRUCT))
		density = FALSE
		broken = TRUE
		open = TRUE
		new /obj/item/shard(drop_location())
		playsound(src, "shatter", 70, TRUE)
		update_icon(UPDATE_OVERLAYS)
		trigger_alarm()

/obj/structure/displaycase/proc/trigger_alarm()
	set waitfor = FALSE
	if(alert && (is_station_contact(z) || force_alarm))
		var/area/alarmed = get_area(src)
		alarmed.burglaralert(src)
		visible_message("<span class='danger'>The burglar alarm goes off!</span>")
		// Play the burglar alarm three times
		for(var/i = 0, i < 4, i++)
			playsound(src, 'sound/machines/burglar_alarm.ogg', 50, 0)
			sleep(74) // 7.4 seconds long

/obj/structure/displaycase/update_overlays()
	. = ..()
	if(broken)
		. += "glassbox_broken"
	if(showpiece)
		var/mutable_appearance/showpiece_overlay = mutable_appearance(showpiece.icon, showpiece.icon_state)
		showpiece_overlay.copy_overlays(showpiece)
		showpiece_overlay.transform *= 0.6
		. += showpiece_overlay
	if(!open && !broken)
		. += "glassbox_closed"

/obj/structure/displaycase/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(I.GetID())
		if(!openable)
			to_chat(user, "<span class='warning'>There is no ID scanner, looks like this one is sealed shut.</span>")
			return ITEM_INTERACT_COMPLETE
		if(broken)
			to_chat(user, "<span class='warning'>[src] is broken, the ID lock won't do anything.</span>")
			return ITEM_INTERACT_COMPLETE
		if(allowed(user) || emagged)
			to_chat(user, "<span class='notice'>You use [I] to [open ? "close" : "open"] [src].</span>")
			toggle_lock()
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return ITEM_INTERACT_COMPLETE
	else if(open && !showpiece)
		if(!(I.flags & (ABSTRACT | DROPDEL)) && user.drop_item())
			I.forceMove(src)
			showpiece = I
			to_chat(user, "<span class='notice'>You put [I] on display</span>")
			update_icon()
		return ITEM_INTERACT_COMPLETE
	else if(istype(I, /obj/item/stack/sheet/glass) && broken)
		var/obj/item/stack/sheet/glass/G = I
		if(G.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two glass sheets to fix the case!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You start fixing [src]...</span>")
		if(do_after(user, 20, target = src))
			G.use(2)
			broken = FALSE
			open = FALSE
			obj_integrity = max_integrity
			update_icon(UPDATE_OVERLAYS)
		return ITEM_INTERACT_COMPLETE
	else
		return ..()

/obj/structure/displaycase/crowbar_act(mob/user, obj/item/I)
	if((alert && !open) || !openable)
		return
	if(open && !showpiece && user.a_intent == INTENT_HELP) // The user can display a crowbar if they're on that intent specifically. Otherwise they'll either take it apart, or close it if the alarm's off
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if((open || broken) && user.a_intent == INTENT_HARM)
		if(showpiece)
			to_chat(user, "<span class='notice'>Remove the displayed object first.</span>")
			return
		if(!I.use_tool(src, user, 15, volume = I.tool_volume))
			return
		if(!broken)
			new /obj/item/stack/sheet/glass(drop_location(), 10)
		else
			new /obj/item/shard(drop_location())
		to_chat(user, "<span class='notice'>You start dismantling the case.</span>")
		var/obj/structure/displaycase_chassis/display = new(loc)
		if(electronics)
			electronics.forceMove(display)
			display.electronics = electronics
		qdel(src)
		return
	if(!alert)
		to_chat(user, "<span class='notice'>You start to [open ? "close":"open"] [src].</span>")
		if(!I.use_tool(src, user, 20, volume = I.tool_volume))
			return
		to_chat(user,  "<span class='notice'>You [open ? "close":"open"] [src].</span>")
		toggle_lock()

/obj/structure/displaycase/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(default_welder_repair(user, I))
		broken = FALSE

/obj/structure/displaycase/proc/toggle_lock()
	open = !open
	update_icon(UPDATE_OVERLAYS)

/obj/structure/displaycase/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(showpiece && (broken || open))
		to_chat(user, "<span class='notice'>You deactivate the hover field built into the case.</span>")
		dump(user)
		add_fingerprint(user)
		update_icon(UPDATE_OVERLAYS)
		return
	if(!open && openable)
		to_chat(user, "<span class='notice'>The ID lock is active, you'll need to unlock it first.</span>")
		return
	//prevents remote "kicks" with TK
	if(!Adjacent(user))
		return
	user.visible_message("<span class='danger'>[user] kicks the display case.</span>")
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	take_damage(2)

/obj/structure/displaycase_chassis
	anchored = TRUE
	name = "display case chassis"
	desc = "The wooden base of a display case."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox_chassis"
	var/obj/item/airlock_electronics/electronics

/obj/structure/displaycase_chassis/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(istype(I, /obj/item/airlock_electronics))
		to_chat(user, "<span class='notice'>You start installing the electronics into [src]...</span>")
		playsound(loc, I.usesound, 50, TRUE)
		if(do_after(user, 30, target = src))
			var/obj/item/airlock_electronics/new_electronics = I
			if(user.drop_item() && !new_electronics.is_installed)
				new_electronics.forceMove(src)
				electronics = new_electronics
				to_chat(user, "<span class='notice'>You install the airlock electronics.</span>")
				electronics.is_installed = TRUE
		return ITEM_INTERACT_COMPLETE
	else if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(G.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need ten glass sheets to do this!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You start adding [G] to [src]...</span>")
		if(do_after(user, 20, target = src))
			G.use(10)
			var/obj/structure/displaycase/display = new(loc)
			if(electronics)
				electronics.forceMove(display)
				display.electronics = electronics
				display.alert = TRUE
				if(electronics.one_access)
					display.req_one_access = electronics.selected_accesses
				else
					display.req_access = electronics.selected_accesses
			qdel(src)
		return ITEM_INTERACT_COMPLETE
	else
		return ..()

/obj/structure/displaycase_chassis/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(electronics)
		if(I.use_tool(src, user, 0, volume = I.tool_volume))
			to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")
			new /obj/item/airlock_electronics(drop_location(), 1)
			electronics.is_installed = FALSE
			electronics = null

/obj/structure/displaycase_chassis/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(electronics)
		to_chat(user, "<span class='notice'>Remove the airlock electronics first.</span>")
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, 30, volume = I.tool_volume))
		return
	TOOL_DISMANTLE_SUCCESS_MESSAGE
	new /obj/item/stack/sheet/wood(drop_location(), 5)
	qdel(src)

//The lab cage and captains display case do not spawn with electronics, which is why req_access is needed.
/obj/structure/displaycase/captain
	alert = TRUE
	start_showpiece_type = /obj/item/gun/energy/laser/captain
	req_access = list(ACCESS_CAPTAIN)

/obj/structure/displaycase/labcage
	name = "lab cage"
	alert = TRUE
	desc = "A glass lab container for storing interesting creatures."
	start_showpiece_type = /obj/item/clothing/mask/facehugger/lamarr
	req_access = list(ACCESS_RD)

/obj/structure/displaycase/stechkin
	name = "officer's display case"
	alert = TRUE
	desc = "A display case containing a humble stechkin pistol. Never forget your roots."
	start_showpiece_type = /obj/item/gun/projectile/automatic/pistol
	req_access = list(ACCESS_SYNDICATE_COMMAND)
