/obj/structure/window
	name = "window"
	desc = "A window."
	icon_state = "window"
	density = TRUE
	layer = ABOVE_OBJ_LAYER //Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = TRUE
	flags = ON_BORDER
	flags_2 = RAD_PROTECT_CONTENTS_2
	can_be_unanchored = TRUE
	max_integrity = 25
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 80, ACID = 100)
	rad_insulation = RAD_VERY_LIGHT_INSULATION
	var/ini_dir = null
	var/state = WINDOW_OUT_OF_FRAME
	var/reinf = FALSE
	var/heat_resistance = 800
	var/decon_speed = null
	var/fulltile = FALSE
	var/shardtype = /obj/item/shard
	var/glass_decal = /obj/effect/decal/cleanable/glass
	var/glass_type = /obj/item/stack/sheet/glass
	var/glass_amount = 1
	var/mutable_appearance/crack_overlay
	var/real_explosion_block	//ignore this, just use explosion_block
	var/breaksound = "shatter"
	var/hitsound = 'sound/effects/Glasshit.ogg'
	/// Used to restore colours from polarised glass
	var/old_color
	/// Used to define what file the edging sprite is contained within
	var/edge_overlay_file
	/// Tracks the edging appearence sprite
	var/mutable_appearance/edge_overlay
	/// Minimum environment smash level (found on simple animals) to break through this instantly
	var/env_smash_level = ENVIRONMENT_SMASH_STRUCTURES

/obj/structure/window/examine(mob/user)
	. = ..()
	if(reinf)
		if(anchored && state == WINDOW_SCREWED_TO_FRAME)
			. += "<span class='notice'>The window is <b>screwed</b> to the frame.</span>"
		else if(anchored && state == WINDOW_IN_FRAME)
			. += "<span class='notice'>The window is <i>unscrewed</i> but <b>pried</b> into the frame.</span>"
		else if(anchored && state == WINDOW_OUT_OF_FRAME)
			. += "<span class='notice'>The window is out of the frame, but could be <i>pried</i> in. It is <b>screwed</b> to the floor.</span>"
		else if(!anchored)
			. += "<span class='notice'>The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.</span>"
	else
		if(anchored)
			. += "<span class='notice'>The window is <b>screwed</b> to the floor.</span>"
		else
			. += "<span class='notice'>The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.</span>"
	if(!anchored && !fulltile)
		. += "<span class='notice'>Alt-click to rotate it.</span>"

/obj/structure/window/Initialize(mapload, direct)
	. = ..()

	if(direct)
		setDir(direct)
	if(reinf && anchored)
		state = WINDOW_SCREWED_TO_FRAME

	ini_dir = dir

	if(fulltile)
		setDir()

	if(decon_speed == null && fulltile)
		decon_speed = 2 SECONDS

	//windows only block while reinforced and fulltile, so we'll use the proc
	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC

	air_update_turf(TRUE)

/obj/structure/window/proc/toggle_polarization()
	if(opacity)
		if(!old_color)
			old_color = "#FFFFFF"
		animate(src, color = old_color, time = 0.5 SECONDS)
		set_opacity(FALSE)
	else
		old_color = color
		animate(src, color = "#222222", time = 0.5 SECONDS)
		set_opacity(TRUE)

/obj/structure/window/narsie_act()
	color = NARSIE_WINDOW_COLOUR

/obj/structure/window/rpd_act()
	return

/obj/structure/window/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/structure/window/setDir(direct)
	if(!fulltile)
		..()
	else
		..(FULLTILE_WINDOW_DIR)

/obj/structure/window/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(dir == FULLTILE_WINDOW_DIR)
		return 0	//full tile window, you can't move into it!
	if(get_dir(loc, target) == dir)
		return !density
	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/structure/windoor_assembly))
		var/obj/structure/windoor_assembly/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/machinery/door/window) && !valid_window_location(loc, mover.dir))
		return FALSE
	return 1

/obj/structure/window/CheckExit(atom/movable/O, target)
	if(istype(O) && O.checkpass(PASSGLASS))
		return 1
	if(get_dir(O.loc, target) == dir)
		return 0
	return 1

/obj/structure/window/CanPathfindPass(obj/item/card/id/ID, to_dir, atom/movable/caller, no_id = FALSE)
	if(!density)
		return 1
	if((dir == FULLTILE_WINDOW_DIR) || (dir == to_dir) || fulltile)
		return 0

	return 1

/obj/structure/window/attack_tk(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='notice'>Something knocks on [src].</span>")
	add_fingerprint(user)
	playsound(src, 'sound/effects/glassknock.ogg', 50, 1)

/obj/structure/window/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(!can_be_reached(user))
		return 1
	. = ..()

/obj/structure/window/attack_hand(mob/user)
	if(!can_be_reached(user))
		return
	if(user.a_intent == INTENT_HARM)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src, 'sound/effects/glassbang.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] bangs against [src]!</span>", \
							"<span class='warning'>You bang against [src]!</span>", \
							"You hear a banging sound.")
		add_fingerprint(user)
	else
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src, 'sound/effects/glassknock.ogg', 50, 1)
		user.visible_message("[user] knocks on [src].", \
							"You knock on [src].", \
							"You hear a knocking sound.")
		add_fingerprint(user)

/obj/structure/window/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)	//used by attack_alien, attack_animal, and attack_slime
	if(!can_be_reached(user))
		return
	return ..()
/obj/structure/window/attack_animal(mob/living/simple_animal/M)
	if(!can_be_reached(M))
		return
	. = ..()
	if(. && M.environment_smash >= env_smash_level)
		deconstruct(FALSE)
		M.visible_message("<span class='danger'>[M] smashes through [src]!</span>", "<span class='warning'>You smash through [src].</span>", "<span class='warning'>You hear glass breaking.</span>")

/obj/structure/window/attackby(obj/item/I, mob/living/user, params)
	if(!can_be_reached(user))
		return 1 //skip the afterattack

	add_fingerprint(user)
	if(istype(I, /obj/item/stack/rods) && user.a_intent == INTENT_HELP)
		for(var/obj/structure/grille/G in get_turf(src))
			if(!G.broken)
				continue
			to_chat(user, "<span class='notice'>You start rebuilding the broken grille.</span>")
			if(do_after(user, 4 SECONDS, FALSE, G))
				G.repair(user, I)

	else if(istype(I, /obj/item/grab) && get_dist(src, user) < 2)
		var/obj/item/grab/G = I
		if(isliving(G.affecting))
			var/mob/living/M = G.affecting
			var/state = G.state
			qdel(I)	//gotta delete it here because if window breaks, it won't get deleted
			switch(state)
				if(1)
					M.visible_message("<span class='warning'>[user] slams [M] against \the [src]!</span>")
					M.apply_damage(7)
					take_damage(10)
				if(2)
					M.visible_message("<span class='danger'>[user] bashes [M] against \the [src]!</span>")
					if(prob(50))
						M.Weaken(2 SECONDS)
					M.apply_damage(10)
					take_damage(25)
				if(3)
					M.visible_message("<span class='danger'><big>[user] crushes [M] against \the [src]!</big></span>")
					M.Weaken(10 SECONDS)
					M.apply_damage(20)
					take_damage(50)
				if(4)
					visible_message("<span class='danger'><big>[user] smashes [M] against \the [src]!</big></span>")
					M.Weaken(10 SECONDS)
					M.apply_damage(30)
					take_damage(75)
	else
		return ..()


/obj/structure/window/crowbar_act(mob/user, obj/item/I)
	if(!reinf)
		return
	if(state != WINDOW_OUT_OF_FRAME && state != WINDOW_IN_FRAME)
		return
	if(!anchored)
		return
	if(flags & NODECONSTRUCT)
		return
	. = TRUE
	if(!can_be_reached(user))
		return
	if(decon_speed) // Only show this if it actually takes time
		to_chat(user, "<span class='notice'>You begin to lever the window [state == WINDOW_OUT_OF_FRAME ? "into":"out of"] the frame...</span>")
	if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
		return
	state = (state == WINDOW_OUT_OF_FRAME ? WINDOW_IN_FRAME : WINDOW_OUT_OF_FRAME)
	to_chat(user, "<span class='notice'>You pry the window [state == WINDOW_IN_FRAME ? "into":"out of"] the frame.</span>")

/obj/structure/window/screwdriver_act(mob/user, obj/item/I)
	if(flags & NODECONSTRUCT)
		return
	. = TRUE
	if(!can_be_reached(user))
		return
	if(reinf)
		if(state == WINDOW_SCREWED_TO_FRAME || state == WINDOW_IN_FRAME)
			if(decon_speed)
				to_chat(user, "<span class='notice'>You begin to [state == WINDOW_SCREWED_TO_FRAME ? "unscrew the window from":"screw the window to"] the frame...</span>")
			if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				return
			state = (state == WINDOW_IN_FRAME ? WINDOW_SCREWED_TO_FRAME : WINDOW_IN_FRAME)
			to_chat(user, "<span class='notice'>You [state == WINDOW_IN_FRAME ? "unfasten the window from":"fasten the window to"] the frame.</span>")

		else if(state == WINDOW_OUT_OF_FRAME)
			if(decon_speed)
				to_chat(user, "<span class='notice'>You begin to [anchored ? "unscrew the frame from":"screw the frame to"] the floor...</span>")
			if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				return
			anchored = !anchored
			air_update_turf(TRUE)
			update_nearby_icons()
			to_chat(user, "<span class='notice'>You [anchored ? "fasten the frame to":"unfasten the frame from"] the floor.</span>")

	else //if we're not reinforced, we don't need to check or update state
		if(decon_speed)
			to_chat(user, "<span class='notice'>You begin to [anchored ? "unscrew the window from":"screw the window to"] the floor...</span>")
		if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
			return
		anchored = !anchored
		air_update_turf(TRUE)
		update_nearby_icons()
		to_chat(user, "<span class='notice'>You [anchored ? "fasten the window to":"unfasten the window from"] the floor.</span>")

/obj/structure/window/wrench_act(mob/user, obj/item/I)
	if(flags & NODECONSTRUCT)
		return
	if(anchored)
		return
	. = TRUE
	if(!can_be_reached(user))
		return
	if(decon_speed)
		TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, decon_speed, volume = I.tool_volume, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
		return
	var/obj/item/stack/sheet/G = new glass_type(user.loc, glass_amount)
	G.add_fingerprint(user)
	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You successfully disassemble [src].</span>")
	qdel(src)

/obj/structure/window/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(!can_be_reached(user))
		return
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
		return
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		obj_integrity = max_integrity
		update_nearby_icons()
		WELDER_REPAIR_SUCCESS_MESSAGE

/obj/structure/window/proc/check_state(checked_state)
	if(state == checked_state)
		return TRUE

/obj/structure/window/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/window/proc/check_state_and_anchored(checked_state, checked_anchored)
	return check_state(checked_state) && check_anchored(checked_anchored)

/obj/structure/window/mech_melee_attack(obj/mecha/M)
	if(!can_be_reached())
		return
	..()

/obj/structure/window/proc/can_be_reached(mob/user)
	if(!fulltile)
		if(get_dir(user, src) & dir)
			for(var/obj/O in loc)
				if(!O.CanPass(user, user.loc, 1))
					return 0
	return 1

/obj/structure/window/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(.) //received damage
		update_nearby_icons()

/obj/structure/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, hitsound, 75, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/Welder.ogg', 100, TRUE)

/obj/structure/window/deconstruct(disassembled = TRUE)
	if(QDELETED(src))
		return
	if(!disassembled)
		playsound(src, breaksound, 70, 1)
		if(!(flags & NODECONSTRUCT))
			for(var/obj/item/shard/debris in spawnDebris(drop_location()))
				transfer_fingerprints_to(debris) // transfer fingerprints to shards only
	qdel(src)
	update_nearby_icons()

/obj/structure/window/proc/spawnDebris(location)
	. = list()
	. += new shardtype(location)
	. += new glass_decal(location)
	if(reinf)
		. += new /obj/item/stack/rods(location, (fulltile ? 2 : 1))
	if(fulltile)
		. += new shardtype(location)

/obj/structure/window/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return

	if(anchored)
		to_chat(usr, "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>")
		return FALSE

	var/target_dir = turn(dir, 90)
	if(!valid_window_location(loc, target_dir))
		to_chat(usr, "<span class='warning'>[src] cannot be rotated in that direction!</span>")
		return FALSE

	setDir(target_dir)
	air_update_turf(1)
	ini_dir = dir
	add_fingerprint(usr)
	return TRUE

/obj/structure/window/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return

	if(anchored)
		to_chat(usr, "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>")
		return FALSE

	var/target_dir = turn(dir, 270)

	if(!valid_window_location(loc, target_dir))
		to_chat(usr, "<span class='warning'>[src] cannot be rotated in that direction!</span>")
		return FALSE

	setDir(target_dir)
	ini_dir = dir
	add_fingerprint(usr)
	return TRUE

/obj/structure/window/AltClick(mob/user)
	if(fulltile) // Can't rotate these.
		return ..()
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return

	if(!Adjacent(user))
		to_chat(user, "<span class='warning'>Move closer to the window!</span>")
		return

	if(anchored)
		to_chat(user, "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>")
		return FALSE

	var/target_dir = turn(dir, 270)

	if(!valid_window_location(loc, target_dir))
		target_dir = turn(dir, 90)
	if(!valid_window_location(loc, target_dir))
		to_chat(user, "<span class='warning'>There is no room to rotate [src].</span>")
		return FALSE

	setDir(target_dir)
	ini_dir = dir
	add_fingerprint(user)
	return TRUE

/obj/structure/window/Destroy()
	density = FALSE
	air_update_turf(1)
	update_nearby_icons()
	return ..()

/obj/structure/window/Move()
	var/turf/T = loc
	. = ..()
	setDir(ini_dir)
	move_update_air(T)

/obj/structure/window/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	. = ..()
	anchored = FALSE
	QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/window/CanAtmosPass(turf/T)
	if(!anchored || !density)
		return TRUE
	return !(FULLTILE_WINDOW_DIR == dir || dir == get_dir(loc, T))

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_icon(UPDATE_ICON_STATE)
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/window/update_icon_state()
	. = ..()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)

/obj/structure/window/update_overlays()
	. = ..()
	if(QDELETED(src))
		return

	if(!fulltile)
		return

	var/ratio = obj_integrity / max_integrity
	ratio = CEILING(ratio * 4, 1) * 25
	if(ratio <= 75)
		crack_overlay = mutable_appearance('icons/obj/structures.dmi', "damage[ratio]", -(layer + 0.01), appearance_flags = RESET_COLOR)
		. += crack_overlay

	if(!edge_overlay_file)
		return

	edge_overlay = mutable_appearance(edge_overlay_file, "[smoothing_junction]", layer + 0.1, appearance_flags = RESET_COLOR)
	. += edge_overlay

/obj/structure/window/smooth_icon()
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > (T0C + heat_resistance))
		take_damage(round(exposed_volume / 100), BURN, 0, 0)

/obj/structure/window/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	var/shattered = FALSE
	if(damage * 2 >= obj_integrity && shardtype && !mob_hurt)
		shattered = TRUE
		var/obj/item/S = new shardtype(loc)
		S.embedded_ignore_throwspeed_threshold = TRUE
		S.throw_impact(C)
		S.embedded_ignore_throwspeed_threshold = FALSE
		damage *= (4/3) //Inverts damage loss from being a structure, since glass breaking on you hurts
		var/turf/T = get_turf(src)
		for(var/obj/structure/grille/G in T.contents)
			var/obj/structure/cable/SC = T.get_cable_node()
			if(SC)
				playsound(G, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
				tesla_zap(G, 3, SC.get_queued_available_power() * 0.05, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN | ZAP_ALLOW_DUPLICATES) //Zap for 1/20 of the amount of power, because I am evil.
				SC.add_queued_power_demand(SC.get_queued_available_power() * 0.0375) // you can gain up to 3.5 via the 4x upgrades power is halved by the pole so thats 2x then 1X then .5X for 3.5x the 3 bounces shock.
			qdel(G) //We don't want the grille to block the way, we want rule of cool of throwing people into space!

	if(!self_hurt)
		take_damage(damage * 2, BRUTE) //Makes windows more vunerable to being thrown so they'll actually shatter in a reasonable ammount of time.
		self_hurt = TRUE
	..()
	if(shattered)
		C.throw_at(throwingdatum.target, throwingdatum.maxrange - 1, throwingdatum.speed - 1) //Annnnnnnd yeet them into space, but slower, now that everything is dealt with

/obj/structure/window/GetExplosionBlock()
	return reinf && fulltile ? real_explosion_block : 0

/obj/structure/window/basic
	desc = "It looks thin and flimsy. A few knocks with... anything, really should shatter it."

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "rwindow"
	reinf = TRUE
	heat_resistance = 1300
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 25, RAD = 100, FIRE = 80, ACID = 100)
	rad_insulation = RAD_HEAVY_INSULATION
	max_integrity = 50
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/rglass

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon_state = "twindow"
	opacity = TRUE

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	desc = "It looks rather strong and frosted over. Looks like it might take a few less hits then a normal reinforced window."
	icon_state = "twindow"
	max_integrity = 30

/obj/structure/window/reinforced/polarized
	name = "electrochromic window"
	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."
	glass_amount = 2
	var/id

/obj/machinery/button/windowtint
	name = "window tint control"
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"
	anchored = TRUE
	desc = "A remote control switch for polarized windows."
	var/range = 7
	var/id = 0
	var/active = FALSE

/obj/machinery/button/windowtint/Initialize(mapload, w_dir = null)
	. = ..()
	switch(w_dir)
		if(NORTH)
			pixel_y = 25
		if(SOUTH)
			pixel_y = -25
		if(EAST)
			pixel_x = 25
		if(WEST)
			pixel_x = -25

/obj/machinery/button/windowtint/attack_hand(mob/user)
	if(..())
		return TRUE

	toggle_tint()

/obj/machinery/button/windowtint/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/button/windowtint/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("<span class='notice'>[user] starts unwrenching [src] from the wall...</span>", "<span class='notice'>You are unwrenching [src] from the wall...</span>", "<span class='warning'>You hear ratcheting.</span>")
	if(!I.use_tool(src, user, 50, volume = I.tool_volume))
		return
	WRENCH_UNANCHOR_WALL_MESSAGE
	new /obj/item/mounted/frame/light_switch/windowtint(get_turf(src))
	qdel(src)

/obj/machinery/button/windowtint/proc/toggle_tint()
	use_power(5)

	active = !active
	update_icon()

	for(var/obj/structure/window/reinforced/polarized/W in range(src,range))
		if(W.id == src.id || !W.id)
			W.toggle_polarization()

	for(var/obj/structure/window/full/reinforced/polarized/W in range(src, range))
		if(W.id == id || !W.id)
			W.toggle_polarization()

	for(var/obj/machinery/door/D in range(src, range))
		if(!D.polarized_glass)
			continue
		if(D.id == id || !D.id)
			D.toggle_polarization()

/obj/machinery/button/windowtint/power_change()
	if(!..())
		return
	if(active && (stat & NOPOWER))
		toggle_tint()

/obj/machinery/button/windowtint/update_icon_state()
	icon_state = "light[active]"

/obj/structure/window/plasmabasic
	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "plasmawindow"
	glass_decal = /obj/effect/decal/cleanable/glass/plasma
	shardtype = /obj/item/shard/plasma
	glass_type = /obj/item/stack/sheet/plasmaglass
	heat_resistance = 32000
	max_integrity = 150
	explosion_block = 1
	armor = list(MELEE = 75, BULLET = 5, LASER = 0, ENERGY = 0, BOMB = 45, RAD = 100, FIRE = 99, ACID = 100)
	rad_insulation = RAD_NO_INSULATION

/obj/structure/window/plasmabasic/BlockSuperconductivity()
	return 1

/obj/structure/window/plasmareinforced
	name = "reinforced plasma window"
	desc = "A plasma-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic plasma windows are insanely fireproof."
	icon_state = "plasmarwindow"
	glass_decal = /obj/effect/decal/cleanable/glass/plasma
	shardtype = /obj/item/shard/plasma
	glass_type = /obj/item/stack/sheet/plasmarglass
	reinf = TRUE
	heat_resistance = 32000
	max_integrity = 500
	explosion_block = 2
	armor = list(MELEE = 85, BULLET = 20, LASER = 0, ENERGY = 0, BOMB = 60, RAD = 100, FIRE = 99, ACID = 100)
	rad_insulation = RAD_NO_INSULATION
	damage_deflection = 21

/obj/structure/window/plasmareinforced/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/plasmareinforced/BlockSuperconductivity()
	return 1 //okay this SHOULD MAKE THE TOXINS CHAMBER WORK

/obj/structure/window/full
	glass_amount = 2
	dir = FULLTILE_WINDOW_DIR
	level = 3
	fulltile = TRUE
	flags = PREVENT_CLICK_UNDER
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_REGULAR_WALLS, SMOOTH_GROUP_REINFORCED_WALLS) //they are not walls but this lets walls smooth with them
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_WALLS)

/obj/structure/window/full/basic
	desc = "It looks thin and flimsy. A few knocks with... anything, really should shatter it."
	icon = 'icons/obj/smooth_structures/windows/window.dmi'
	icon_state = "window-0"
	base_icon_state = "window"
	max_integrity = 50
	edge_overlay_file = 'icons/obj/smooth_structures/windows/window_edges.dmi'

/obj/structure/window/full/plasmabasic
	name = "plasma window"
	desc = "A plasma-glass alloy window. It looks insanely tough to break. It appears it's also insanely tough to burn through."
	icon = 'icons/obj/smooth_structures/windows/plasma_window.dmi'
	icon_state = "plasma_window-0"
	base_icon_state = "plasma_window"
	glass_decal = /obj/effect/decal/cleanable/glass/plasma
	shardtype = /obj/item/shard/plasma
	glass_type = /obj/item/stack/sheet/plasmaglass
	heat_resistance = 32000
	max_integrity = 300
	explosion_block = 1
	armor = list(MELEE = 75, BULLET = 5, LASER = 0, ENERGY = 0, BOMB = 45, RAD = 100, FIRE = 99, ACID = 100)
	rad_insulation = RAD_NO_INSULATION
	edge_overlay_file = 'icons/obj/smooth_structures/windows/window_edges.dmi'
	env_smash_level = ENVIRONMENT_SMASH_WALLS  // these windows are a fair bit tougher

/obj/structure/window/full/plasmareinforced
	name = "reinforced plasma window"
	desc = "A plasma-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic plasma windows are insanely fireproof."
	icon = 'icons/obj/smooth_structures/windows/rplasma_window.dmi'
	icon_state = "rplasma_window-0"
	base_icon_state = "rplasma_window"
	glass_decal = /obj/effect/decal/cleanable/glass/plasma
	shardtype = /obj/item/shard/plasma
	glass_type = /obj/item/stack/sheet/plasmarglass
	reinf = TRUE
	heat_resistance = 32000
	max_integrity = 1000
	explosion_block = 2
	armor = list(MELEE = 85, BULLET = 20, LASER = 0, ENERGY = 0, BOMB = 60, RAD = 100, FIRE = 99, ACID = 100)
	rad_insulation = RAD_NO_INSULATION
	edge_overlay_file = 'icons/obj/smooth_structures/windows/reinforced_window_edges.dmi'
	env_smash_level = ENVIRONMENT_SMASH_RWALLS  // these ones are insanely tough

/obj/structure/window/full/plasmareinforced/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/full/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon = 'icons/obj/smooth_structures/windows/reinforced_window.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	max_integrity = 100
	reinf = TRUE
	heat_resistance = 1600
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 25, RAD = 100, FIRE = 80, ACID = 100)
	rad_insulation = RAD_HEAVY_INSULATION
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/rglass
	edge_overlay_file = 'icons/obj/smooth_structures/windows/reinforced_window_edges.dmi'

/obj/structure/window/full/reinforced/polarized
	name = "electrochromic window"
	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."
	glass_amount = 4
	var/id

/obj/structure/window/full/reinforced/tinted
	name = "tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon = 'icons/obj/smooth_structures/windows/tinted_window.dmi'
	icon_state = "tinted_window-0"
	base_icon_state = "tinted_window"
	opacity = TRUE

/obj/structure/window/full/shuttle
	name = "shuttle window"
	desc = "A reinforced, air-locked pod window."
	icon = 'icons/obj/smooth_structures/windows/shuttle_window.dmi'
	icon_state = "shuttle_window-0"
	base_icon_state = "shuttle_window"
	max_integrity = 200
	reinf = TRUE
	heat_resistance = 1600
	explosion_block = 3
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, RAD = 100, FIRE = 80, ACID = 100)
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE, SMOOTH_GROUP_TITANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE, SMOOTH_GROUP_TITANIUM_WALLS)
	glass_type = /obj/item/stack/sheet/titaniumglass
	env_smash_level = ENVIRONMENT_SMASH_RWALLS  // shuttle windows should probably be a bit stronger, too

/obj/structure/window/full/shuttle/narsie_act()
	color = "#3C3434"

/obj/structure/window/full/shuttle/tinted
	opacity = TRUE

/obj/structure/window/full/plastitanium
	name = "plastitanium window"
	desc = "An evil looking window of plasma and titanium."
	icon = 'icons/obj/smooth_structures/windows/plastitanium_window.dmi'
	icon_state = "plastitanium_window-0"
	base_icon_state = "plastitanium_window"
	max_integrity = 1200
	reinf = TRUE
	heat_resistance = 32000
	armor = list(MELEE = 85, BULLET = 20, LASER = 0, ENERGY = 0, BOMB = 60, RAD = 100, FIRE = 99, ACID = 100)
	rad_insulation = RAD_NO_INSULATION
	explosion_block = 3
	glass_type = /obj/item/stack/sheet/plastitaniumglass
	smoothing_groups = list(SMOOTH_GROUP_SHUTTLE_PARTS, SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM, SMOOTH_GROUP_PLASTITANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM, SMOOTH_GROUP_SYNDICATE_WALLS, SMOOTH_GROUP_PLASTITANIUM_WALLS)

/obj/structure/window/reinforced/clockwork
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass."
	icon = 'icons/obj/smooth_structures/windows/clockwork_window.dmi'
	icon_state = "clockwork_window_single"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_integrity = 80
	armor = list(MELEE = 60, BULLET = 25, LASER = 0, ENERGY = 0, BOMB = 25, RAD = 100, FIRE = 80, ACID = 100)
	explosion_block = 2 //fancy AND hard to destroy. the most useful combination.
	glass_type = /obj/item/stack/tile/brass
	reinf = FALSE
	var/made_glow = FALSE

/obj/structure/window/reinforced/clockwork/spawnDebris(location)
	. = list()
	. += new /obj/item/stack/tile/brass(location, (fulltile ? 2 : 1))

/obj/structure/window/reinforced/clockwork/setDir(direct)
	if(!made_glow)
		if(fulltile)
			new /obj/effect/temp_visual/ratvar/window(get_turf(src))
		else
			var/obj/effect/E = new /obj/effect/temp_visual/ratvar/window/single(get_turf(src))
			E.setDir(direct)
		made_glow = TRUE
	..()

/obj/structure/window/reinforced/clockwork/narsie_act()
	take_damage(rand(25, 75), BRUTE)
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

/obj/structure/window/reinforced/clockwork/fulltile
	icon_state = "clockwork_window-0"
	base_icon_state = "clockwork_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_WINDOW_FULLTILE_BRASS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE_BRASS)
	fulltile = TRUE
	flags = PREVENT_CLICK_UNDER
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 120
	level = 3
	glass_amount = 2
