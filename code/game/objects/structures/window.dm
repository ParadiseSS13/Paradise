var/global/wcBar = pick(list("#0d8395", "#58b5c3", "#58c366", "#90d79a", "#ffffff"))
var/global/wcBrig = pick(list("#aa0808", "#7f0606", "#ff0000"))
var/global/wcCommon = pick(list("#379963", "#0d8395", "#58b5c3", "#49e46e", "#8fcf44", "#ffffff"))

/obj/proc/color_windows(obj/W)
	var/list/wcBarAreas = list(/area/crew_quarters/bar)
	var/list/wcBrigAreas = list(/area/security,/area/prison,/area/shuttle/gamma)

	var/newcolor
	var/turf/T = get_turf(W)
	if(!istype(T))
		return
	var/area/A = T.loc

	if(is_type_in_list(A,wcBarAreas))
		newcolor = wcBar
	else if(is_type_in_list(A,wcBrigAreas))
		newcolor = wcBrig
	else
		newcolor = wcCommon

	return newcolor

/obj/structure/window
	name = "window"
	desc = "A window."
	icon_state = "window"
	density = TRUE
	layer = ABOVE_OBJ_LAYER //Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = TRUE
	flags = ON_BORDER
	can_be_unanchored = TRUE
	max_integrity = 25
	var/ini_dir = null
	var/state = WINDOW_OUT_OF_FRAME
	var/reinf = FALSE
	var/heat_resistance = 800
	var/decon_speed = null
	var/fulltile = FALSE
	var/shardtype = /obj/item/shard
	var/glass_type = /obj/item/stack/sheet/glass
	var/glass_amount = 1
	var/cancolor = FALSE
	var/image/crack_overlay
	var/list/debris = list()
	var/real_explosion_block	//ignore this, just use explosion_block
	var/breaksound = "shatter"
	var/hitsound = 'sound/effects/Glasshit.ogg'

/obj/structure/window/examine(mob/user)
	..()
	if(reinf)
		if(anchored && state == WINDOW_SCREWED_TO_FRAME)
			to_chat(user, "<span class='notice'>The window is <b>screwed</b> to the frame.</span>")
		else if(anchored && state == WINDOW_IN_FRAME)
			to_chat(user, "<span class='notice'>The window is <i>unscrewed</i> but <b>pried</b> into the frame.</span>")
		else if(anchored && state == WINDOW_OUT_OF_FRAME)
			to_chat(user, "<span class='notice'>The window is out of the frame, but could be <i>pried</i> in. It is <b>screwed</b> to the floor.</span>")
		else if(!anchored)
			to_chat(user, "<span class='notice'>The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.</span>")
	else
		if(anchored)
			to_chat(user, "<span class='notice'>The window is <b>screwed</b> to the floor.</span>")
		else
			to_chat(user, "<span class='notice'>The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.</span>")
	if(!anchored && !fulltile)
		to_chat(user, "<span class='notice'>Alt-click to rotate it.</span>")

/obj/structure/window/New(Loc, direct)
	..()
	if(direct)
		setDir(direct)
	if(reinf && anchored)
		state = WINDOW_SCREWED_TO_FRAME

	ini_dir = dir

	if(!color && cancolor)
		color = color_windows(src)

	// Precreate our own debris

	var/shards = 1
	if(fulltile)
		shards++
		setDir()

	if(decon_speed == null)
		if(fulltile)
			decon_speed = 20
		else
			decon_speed = 1

	var/rods = 0
	if(reinf)
		rods++
		if(fulltile)
			rods++

	for(var/i in 1 to shards)
		debris += new shardtype(src)
	if(rods)
		debris += new /obj/item/stack/rods(src, rods)

	//windows only block while reinforced and fulltile, so we'll use the proc
	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC

/obj/structure/window/Initialize()
	air_update_turf(1)
	return ..()

/obj/structure/window/narsie_act()
	color = NARSIE_WINDOW_COLOUR
	for(var/obj/item/shard/shard in debris)
		shard.color = NARSIE_WINDOW_COLOUR

/obj/structure/window/ratvar_act()
	if(!fulltile)
		new/obj/structure/window/reinforced/clockwork(get_turf(src), dir)
	else
		new/obj/structure/window/reinforced/clockwork/fulltile(get_turf(src))
	qdel(src)

/obj/structure/window/rpd_act()
	return

/obj/structure/window/singularity_pull(S, current_size)
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

/obj/structure/window/CanAStarPass(ID, to_dir)
	if(!density)
		return 1
	if((dir == FULLTILE_WINDOW_DIR) || (dir == to_dir))
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
		playsound(src, 'sound/effects/glassknock.ogg', 80, 1)
		user.visible_message("<span class='warning'>[user] bangs against [src]!</span>", \
							"<span class='warning'>You bang against [src]!</span>", \
							"You hear a banging sound.")
		add_fingerprint(user)
	else
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src, 'sound/effects/glassknock.ogg', 80, 1)
		user.visible_message("[user] knocks on [src].", \
							"You knock on [src].", \
							"You hear a knocking sound.")
		add_fingerprint(user)

/obj/structure/window/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)	//used by attack_alien, attack_animal, and attack_slime
	if(!can_be_reached(user))
		return
	..()

/obj/structure/window/attackby(obj/item/I, mob/living/user, params)
	if(!can_be_reached(user))
		return 1 //skip the afterattack

	add_fingerprint(user)

	if(iswelder(I) && user.a_intent == INTENT_HELP)
		var/obj/item/weldingtool/WT = I
		if(obj_integrity < max_integrity)
			if(WT.remove_fuel(0,user))
				to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
				playsound(src, WT.usesound, 40, 1)
				if(do_after(user, 40*I.toolspeed, target = src))
					obj_integrity = max_integrity
					playsound(src, 'sound/items/welder2.ogg', 50, 1)
					update_nearby_icons()
					to_chat(user, "<span class='notice'>You repair [src].</span>")
		else
			to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
		return

	if(istype(I, /obj/item/grab) && get_dist(src, user) < 2)
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
						M.Weaken(1)
					M.apply_damage(10)
					take_damage(25)
				if(3)
					M.visible_message("<span class='danger'><big>[user] crushes [M] against \the [src]!</big></span>")
					M.Weaken(5)
					M.apply_damage(20)
					take_damage(50)
				if(4)
					visible_message("<span class='danger'><big>[user] smashes [M] against \the [src]!</big></span>")
					M.Weaken(5)
					M.apply_damage(30)
					take_damage(75)
			return

	if(can_deconstruct)
		if(isscrewdriver(I))
			playsound(src, I.usesound, 75, 1)
			if(reinf)
				if(state == WINDOW_SCREWED_TO_FRAME || state == WINDOW_IN_FRAME)
					to_chat(user, "<span class='notice'>You begin to [state == WINDOW_SCREWED_TO_FRAME ? "unscrew the window from":"screw the window to"] the frame...</span>")
					if(do_after(user, decon_speed*I.toolspeed, target = src, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
						state = (state == WINDOW_IN_FRAME ? WINDOW_SCREWED_TO_FRAME : WINDOW_IN_FRAME)
						to_chat(user, "<span class='notice'>You [state == WINDOW_IN_FRAME ? "unfasten the window from":"fasten the window to"] the frame.</span>")
				else if(state == WINDOW_OUT_OF_FRAME)
					to_chat(user, "<span class='notice'>You begin to [anchored ? "unscrew the frame from":"screw the frame to"] the floor...</span>")
					if(do_after(user, decon_speed*I.toolspeed, target = src, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
						anchored = !anchored
						update_nearby_icons()
						to_chat(user, "<span class='notice'>You [anchored ? "fasten the frame to":"unfasten the frame from"] the floor.</span>")
			else //if we're not reinforced, we don't need to check or update state
				to_chat(user, "<span class='notice'>You begin to [anchored ? "unscrew the window from":"screw the window to"] the floor...</span>")
				if(do_after(user, decon_speed*I.toolspeed, target = src, extra_checks = CALLBACK(src, .proc/check_anchored, anchored)))
					anchored = !anchored
					air_update_turf(TRUE)
					update_nearby_icons()
					to_chat(user, "<span class='notice'>You [anchored ? "fasten the window to":"unfasten the window from"] the floor.</span>")
			return

		else if(iscrowbar(I) && reinf && (state == WINDOW_OUT_OF_FRAME || state == WINDOW_IN_FRAME))
			to_chat(user, "<span class='notice'>You begin to lever the window [state == WINDOW_OUT_OF_FRAME ? "into":"out of"] the frame...</span>")
			playsound(src, I.usesound, 75, 1)
			if(do_after(user, decon_speed*I.toolspeed, target = src, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
				state = (state == WINDOW_OUT_OF_FRAME ? WINDOW_IN_FRAME : WINDOW_OUT_OF_FRAME)
				to_chat(user, "<span class='notice'>You pry the window [state == WINDOW_IN_FRAME ? "into":"out of"] the frame.</span>")
			return

		else if(iswrench(I) && !anchored)
			playsound(src, I.usesound, 75, 1)
			to_chat(user, "<span class='notice'> You begin to disassemble [src]...</span>")
			if(do_after(user, decon_speed*I.toolspeed, target = src, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
				var/obj/item/stack/sheet/G = new glass_type(user.loc, glass_amount)
				G.add_fingerprint(user)
				playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You successfully disassemble [src].</span>")
				qdel(src)
			return
	return ..()

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
				playsound(src, hitsound, 75, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, 1)

/obj/structure/window/deconstruct(disassembled = TRUE)
	if(QDELETED(src))
		return
	if(!disassembled)
		playsound(src, breaksound, 70, 1)
		if(can_deconstruct)
			for(var/i in debris)
				var/obj/item/I = i
				I.forceMove(loc)
				transfer_fingerprints_to(I)
	qdel(src)
	update_nearby_icons()

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
		to_chat(user, "<span class='warning'>There is no room to rotate the [src]</span>")
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
	..()
	setDir(ini_dir)
	move_update_air(T)

/obj/structure/window/CanAtmosPass(turf/T)
	if(!anchored || !density)
		return TRUE
	return !(FULLTILE_WINDOW_DIR == dir || dir == get_dir(loc, T))

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_icon()
	if(smooth)
		queue_smooth_neighbors(src)

/obj/structure/window/update_icon()
	if(!QDELETED(src))
		if(!fulltile)
			return
		var/ratio = obj_integrity / max_integrity
		ratio = CEILING(ratio*4, 1) * 25
		if(smooth)
			queue_smooth(src)
		overlays -= crack_overlay
		if(ratio > 75)
			return
		crack_overlay = image('icons/obj/structures.dmi',"damage[ratio]",-(layer+0.1))
		overlays += crack_overlay

/obj/structure/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > (T0C + heat_resistance))
		take_damage(round(exposed_volume / 100), BURN, 0, 0)
	..()

/obj/structure/window/GetExplosionBlock()
	return reinf && fulltile ? real_explosion_block : 0

/obj/structure/window/basic
	desc = "It looks thin and flimsy. A few knocks with... anything, really should shatter it."

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "rwindow"
	reinf = TRUE
	cancolor = TRUE
	heat_resistance = 1600
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 25, "bio" = 100, "rad" = 100)
	max_integrity = 50
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/rglass

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon_state = "twindow"
	opacity = 1

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	desc = "It looks rather strong and frosted over. Looks like it might take a few less hits then a normal reinforced window."
	icon_state = "fwindow"
	max_integrity = 30

/obj/structure/window/reinforced/polarized
	name = "electrochromic window"
	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."
	var/id

/obj/structure/window/reinforced/polarized/proc/toggle()
	if(opacity)
		animate(src, color="#FFFFFF", time=5)
		set_opacity(0)
	else
		animate(src, color="#222222", time=5)
		set_opacity(1)

/obj/machinery/button/windowtint
	name = "window tint control"
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"
	desc = "A remote control switch for polarized windows."
	var/range = 7
	var/id = 0
	var/active = 0

/obj/machinery/button/windowtint/attack_hand(mob/user)
	if(..())
		return 1

	toggle_tint()

/obj/machinery/button/windowtint/proc/toggle_tint()
	use_power(5)

	active = !active
	update_icon()

	for(var/obj/structure/window/reinforced/polarized/W in range(src,range))
		if(W.id == src.id || !W.id)
			spawn(0)
				W.toggle()
				return

/obj/machinery/button/windowtint/power_change()
	..()
	if(active && !powered(power_channel))
		toggle_tint()

/obj/machinery/button/windowtint/update_icon()
	icon_state = "light[active]"

/obj/structure/window/plasmabasic
	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "plasmawindow"
	shardtype = /obj/item/shard/plasma
	glass_type = /obj/item/stack/sheet/plasmaglass
	heat_resistance = 32000
	max_integrity = 120
	explosion_block = 1
	armor = list("melee" = 75, "bullet" = 5, "laser" = 0, "energy" = 0, "bomb" = 45, "bio" = 100, "rad" = 100)

/obj/structure/window/plasmabasic/BlockSuperconductivity()
	return 1

/obj/structure/window/plasmareinforced
	name = "reinforced plasma window"
	desc = "A plasma-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic plasma windows are insanely fireproof."
	icon_state = "plasmarwindow"
	shardtype = /obj/item/shard/plasma
	glass_type = /obj/item/stack/sheet/plasmarglass
	reinf = TRUE
	max_integrity = 160
	explosion_block = 2
	armor = list("melee" = 85, "bullet" = 20, "laser" = 0, "energy" = 0, "bomb" = 60, "bio" = 100, "rad" = 100)

/obj/structure/window/plasmareinforced/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/plasmareinforced/BlockSuperconductivity()
	return 1 //okay this SHOULD MAKE THE TOXINS CHAMBER WORK

/obj/structure/window/full
	glass_amount = 2
	dir = FULLTILE_WINDOW_DIR
	level = 3
	fulltile = TRUE

/obj/structure/window/full/basic
	desc = "It looks thin and flimsy. A few knocks with... anything, really should shatter it."
	icon = 'icons/obj/smooth_structures/window.dmi'
	icon_state = "window"
	max_integrity = 50
	smooth = SMOOTH_TRUE
	cancolor = TRUE
	canSmoothWith = list(/obj/structure/window/full/basic, /obj/structure/window/full/reinforced, /obj/structure/window/full/reinforced/tinted, /obj/structure/window/full/plasmabasic, /obj/structure/window/full/plasmareinforced)

/obj/structure/window/full/plasmabasic
	name = "plasma window"
	desc = "A plasma-glass alloy window. It looks insanely tough to break. It appears it's also insanely tough to burn through."
	icon = 'icons/obj/smooth_structures/plasma_window.dmi'
	icon_state = "plasmawindow"
	shardtype = /obj/item/shard/plasma
	glass_type = /obj/item/stack/sheet/plasmaglass
	heat_resistance = 32000
	max_integrity = 240
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/window/full/basic, /obj/structure/window/full/reinforced, /obj/structure/window/full/reinforced/tinted, /obj/structure/window/full/plasmabasic, /obj/structure/window/full/plasmareinforced)
	explosion_block = 1
	armor = list("melee" = 75, "bullet" = 5, "laser" = 0, "energy" = 0, "bomb" = 45, "bio" = 100, "rad" = 100)

/obj/structure/window/full/plasmareinforced
	name = "reinforced plasma window"
	desc = "A plasma-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic plasma windows are insanely fireproof."
	icon = 'icons/obj/smooth_structures/rplasma_window.dmi'
	icon_state = "rplasmawindow"
	shardtype = /obj/item/shard/plasma
	glass_type = /obj/item/stack/sheet/plasmarglass
	smooth = SMOOTH_TRUE
	reinf = TRUE
	max_integrity = 320
	explosion_block = 2
	armor = list("melee" = 85, "bullet" = 20, "laser" = 0, "energy" = 0, "bomb" = 60, "bio" = 100, "rad" = 100)

/obj/structure/window/full/plasmareinforced/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/full/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."
	icon = 'icons/obj/smooth_structures/reinforced_window.dmi'
	icon_state = "r_window"
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/window/full/basic, /obj/structure/window/full/reinforced, /obj/structure/window/full/reinforced/tinted, /obj/structure/window/full/plasmabasic, /obj/structure/window/full/plasmareinforced)
	max_integrity = 100
	reinf = TRUE
	heat_resistance = 1600
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 25, "bio" = 100, "rad" = 100)
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/rglass
	cancolor = TRUE

/obj/structure/window/full/reinforced/tinted
	name = "tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	icon = 'icons/obj/smooth_structures/tinted_window.dmi'
	icon_state = "tinted_window"
	opacity = 1

obj/structure/window/full/reinforced/ice
	icon = 'icons/obj/smooth_structures/rice_window.dmi'
	icon_state = "ice_window"
	max_integrity = 150
	cancolor = FALSE

/obj/structure/window/full/shuttle
	name = "shuttle window"
	desc = "A reinforced, air-locked pod window."
	icon = 'icons/obj/smooth_structures/shuttle_window.dmi'
	icon_state = "shuttle_window"
	max_integrity = 160
	reinf = TRUE
	heat_resistance = 1600
	explosion_block = 3
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 100, "rad" = 100)
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	glass_type = /obj/item/stack/sheet/titaniumglass

/obj/structure/window/full/shuttle/narsie_act()
	color = "#3C3434"

/obj/structure/window/full/shuttle/tinted
	opacity = TRUE

/obj/structure/window/plastitanium
	name = "plastitanium window"
	desc = "An evil looking window of plasma and titanium."
	icon = 'icons/obj/smooth_structures/plastitanium_window.dmi'
	icon_state = "plastitanium_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 200
	fulltile = TRUE
	reinf = TRUE
	heat_resistance = 1600
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 100, "rad" = 100)
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	explosion_block = 3
	level = 3
	glass_type = /obj/item/stack/sheet/plastitaniumglass
	glass_amount = 2

/obj/structure/window/reinforced/clockwork
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass."
	icon = 'icons/obj/smooth_structures/clockwork_window.dmi'
	icon_state = "clockwork_window_single"
	burn_state = FIRE_PROOF
	unacidable = 1
	max_integrity = 80
	armor = list("melee" = 60, "bullet" = 25, "laser" = 0, "energy" = 0, "bomb" = 25, "bio" = 100, "rad" = 100)
	explosion_block = 2 //fancy AND hard to destroy. the most useful combination.
	glass_type = /obj/item/stack/tile/brass
	reinf = FALSE
	cancolor = FALSE
	var/made_glow = FALSE

/obj/structure/window/reinforced/clockwork/New(loc, direct)
	if(fulltile)
		made_glow = TRUE
	..()
	QDEL_LIST(debris)
	if(fulltile)
		new /obj/effect/temp_visual/ratvar/window(get_turf(src))
		debris += new/obj/item/stack/tile/brass(src, 2)
	else
		debris += new/obj/item/stack/tile/brass(src, 1)

/obj/structure/window/reinforced/clockwork/setDir(direct)
	if(!made_glow)
		var/obj/effect/E = new /obj/effect/temp_visual/ratvar/window/single(get_turf(src))
		E.setDir(direct)
		made_glow = TRUE
	..()

/obj/structure/window/reinforced/clockwork/ratvar_act()
	obj_integrity = max_integrity
	update_icon()

/obj/structure/window/reinforced/clockwork/narsie_act()
	take_damage(rand(25, 75), BRUTE)
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

/obj/structure/window/reinforced/clockwork/fulltile
	icon_state = "clockwork_window"
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	fulltile = TRUE
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 120
	level = 3
	glass_amount = 2
