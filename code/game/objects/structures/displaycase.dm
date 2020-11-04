/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox0"
	desc = "A display case for prized possessions."
	density = TRUE
	anchored = TRUE
	resistance_flags = ACID_PROOF
	armor = list("melee" = 30, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 100)
	max_integrity = 200
	integrity_failure = 50
	var/obj/item/showpiece = null
	var/alert = TRUE
	var/open = FALSE
	var/openable = TRUE
	var/obj/item/airlock_electronics/electronics
	var/start_showpiece_type = null //add type for items on display
	var/list/start_showpieces = list() //Takes sublists in the form of list("type" = /obj/item/bikehorn, "trophy_message" = "henk")
	var/trophy_message = ""

/obj/structure/displaycase/Initialize(mapload)
	. = ..()
	if(start_showpieces.len && !start_showpiece_type)
		var/list/showpiece_entry = pick(start_showpieces)
		if (showpiece_entry && showpiece_entry["type"])
			start_showpiece_type = showpiece_entry["type"]
			if (showpiece_entry["trophy_message"])
				trophy_message = showpiece_entry["trophy_message"]
	if(start_showpiece_type)
		showpiece = new start_showpiece_type (src)
	update_icon()

/obj/structure/displaycase/Destroy()
	QDEL_NULL(electronics)
	QDEL_NULL(showpiece)
	return ..()

/obj/structure/displaycase/examine(mob/user)
	. = ..()
	if(alert)
		. += "<span class='notice'>Hooked up with an anti-theft system.</span>"
	if(showpiece)
		. += "<span class='notice'>There's [showpiece] inside.</span>"
	if(trophy_message)
		. += "The plaque reads:\n [trophy_message]"

/obj/structure/displaycase/proc/dump()
	if(showpiece)
		showpiece.forceMove(loc)
		showpiece = null

/obj/structure/displaycase/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/displaycase/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		dump()
		if(!disassembled)
			new /obj/item/shard(loc)
			trigger_alarm()
	qdel(src)

/obj/structure/displaycase/obj_break(damage_flag)
	if(!broken && !(flags & NODECONSTRUCT))
		density = FALSE
		broken = 1
		new /obj/item/shard( src.loc )
		playsound(src, "shatter", 70, TRUE)
		update_icon()
		trigger_alarm()

/obj/structure/displaycase/proc/trigger_alarm()
	set waitfor = FALSE
	if(alert && is_station_contact(z))
		var/area/alarmed = get_area(src)
		alarmed.burglaralert(src)
		visible_message("<span class='danger'>The burglar alarm goes off!</span>")
		// Play the burglar alarm three times
		for(var/i = 0, i < 4, i++)
			playsound(src, 'sound/machines/burglar_alarm.ogg', 50, 0)
			sleep(74) // 7.4 seconds long

/obj/structure/displaycase/update_icon()
	var/icon/I
	if(open)
		I = icon('icons/obj/stationobjs.dmi',"glassbox_open")
	else
		I = icon('icons/obj/stationobjs.dmi',"glassbox0")
	if(broken)
		I = icon('icons/obj/stationobjs.dmi',"glassboxb0")
	if(showpiece)
		var/icon/S = getFlatIcon(showpiece)
		S.Scale(17, 17)
		I.Blend(S,ICON_UNDERLAY,8,8)
	icon = I

/obj/structure/displaycase/attackby(obj/item/I, mob/user, params)
	if(I.GetID() && !broken && openable)
		if(allowed(user))
			to_chat(user,  "<span class='notice'>You [open ? "close":"open"] [src].</span>")
			toggle_lock(user)
		else
			to_chat(user,  "<span class='warning'>Access denied.</span>")
	else if(open && !showpiece)
		if(user.drop_item())
			I.forceMove(src)
			showpiece = I
			to_chat(user, "<span class='notice'>You put [I] on display</span>")
			update_icon()
	else if(istype(I, /obj/item/stack/sheet/glass) && broken)
		var/obj/item/stack/sheet/glass/G = I
		if(G.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two glass sheets to fix the case!</span>")
			return
		to_chat(user, "<span class='notice'>You start fixing [src]...</span>")
		if(do_after(user, 20, target = src))
			G.use(2)
			broken = 0
			obj_integrity = max_integrity
			update_icon()
	else
		return ..()

/obj/structure/displaycase/crowbar_act(mob/user, obj/item/I) //Only applies to the lab cage and player made display cases
	if(alert || !openable)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(broken)
		if(showpiece)
			to_chat(user, "<span class='notice'>Remove the displayed object first.</span>")
		if(I.use_tool(src, user, 0, volume = I.tool_volume))
			to_chat(user, "<span class='notice'>You remove the destroyed case</span>")
			qdel(src)
	else
		to_chat(user, "<span class='notice'>You start to [open ? "close":"open"] [src].</span>")
		if(!I.use_tool(src, user, 20, volume = I.tool_volume))
			return
		to_chat(user,  "<span class='notice'>You [open ? "close":"open"] [src].</span>")
		toggle_lock(user)

obj/structure/displaycase/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(default_welder_repair(user, I))
		broken = FALSE

/obj/structure/displaycase/proc/toggle_lock(mob/user)
	open = !open
	update_icon()

/obj/structure/displaycase/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(showpiece && (broken || open))
		to_chat(user, "<span class='notice'>You deactivate the hover field built into the case.</span>")
		dump()
		add_fingerprint(user)
		update_icon()
		return
	else
	    //prevents remote "kicks" with TK
		if(!Adjacent(user))
			return
		user.visible_message("<span class='danger'>[user] kicks the display case.</span>")
		user.do_attack_animation(src, ATTACK_EFFECT_KICK)
		take_damage(2)

/obj/structure/displaycase_chassis
	anchored = TRUE
	density = FALSE
	name = "display case chassis"
	desc = "The wooden base of a display case."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox_chassis"
	var/obj/item/airlock_electronics/electronics

/obj/structure/displaycase_chassis/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/airlock_electronics))
		to_chat(user, "<span class='notice'>You start installing the electronics into [src]...</span>")
		playsound(src.loc, I.usesound, 50, 1)
		if(do_after(user, 30, target = src))
			if(user.drop_item())
				I.forceMove(src)
				electronics = I
				to_chat(user, "<span class='notice'>You install the airlock electronics.</span>")

	else if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/G = I
		if(G.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need ten glass sheets to do this!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [G] to [src]...</span>")
		if(do_after(user, 20, target = src))
			G.use(10)
			var/obj/structure/displaycase/display = new(src.loc)
			if(electronics)
				electronics.forceMove(display)
				display.electronics = electronics
				if(electronics.one_access)
					display.req_one_access = electronics.conf_access
				else
					display.req_access = electronics.conf_access
			qdel(src)
	else
		return ..()

/obj/structure/displaycase_chassis/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, 30, volume = I.tool_volume))
		return
	TOOL_DISMANTLE_SUCCESS_MESSAGE
	new /obj/item/stack/sheet/wood(get_turf(src), 5)
	qdel(src)

//The lab cage and captains display case do not spawn with electronics, which is why req_access is needed.
/obj/structure/displaycase/captain
	alert = TRUE
	start_showpiece_type = /obj/item/gun/energy/laser/captain
	req_access = list(ACCESS_CAPTAIN)

/obj/structure/displaycase/labcage
	name = "lab cage"
	desc = "A glass lab container for storing interesting creatures."
	start_showpiece_type = /obj/item/clothing/mask/facehugger/lamarr
	req_access = list(ACCESS_RD)

/obj/structure/displaycase/stechkin
	name = "officer's display case"
	desc = "A display case containing a humble stechkin pistol. Never forget your roots."
	start_showpiece_type = /obj/item/gun/projectile/automatic/pistol
	req_access = list(ACCESS_SYNDICATE_COMMAND)
