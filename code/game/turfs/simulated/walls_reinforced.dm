/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to separate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "reinforced_wall-0"
	base_icon_state = "reinforced_wall"
	explosion_block = 2
	rad_insulation_gamma = RAD_VERY_EXTREME_INSULATION
	damage_cap = 600
	hardness = 10
	sheet_type = /obj/item/stack/sheet/plasteel
	sheet_amount = 1
	girder_type = /obj/structure/girder/reinforced
	can_dismantle_with_welder = FALSE
	smoothing_groups = list(SMOOTH_GROUP_SIMULATED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_REINFORCED_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_REGULAR_WALLS, SMOOTH_GROUP_REINFORCED_WALLS)
	heat_resistance = 20000 // Ain't getting through this soon

	var/d_state = RWALL_INTACT
	var/can_be_reinforced = 1

/turf/simulated/wall/r_wall/examine(mob/user)
	. = ..()
	switch(d_state)
		if(RWALL_INTACT)
			. += SPAN_NOTICE("The outer <b>grille</b> is fully intact.")
		if(RWALL_SUPPORT_LINES)
			. += SPAN_NOTICE("The outer <i>grille</i> has been cut, and the support lines are <b>screwed</b> securely to the outer cover.")
		if(RWALL_COVER)
			. += SPAN_NOTICE("The support lines have been <i>unscrewed</i>, and the metal cover is <b>welded</b> firmly in place.")
		if(RWALL_CUT_COVER)
			. += SPAN_NOTICE("The metal cover has been <i>sliced through</i>, and is <b>connected loosely</b> to the girder.")
		if(RWALL_BOLTS)
			. += SPAN_NOTICE("The outer cover has been <i>pried away</i>, and the bolts anchoring the support rods are <b>wrenched</b> in place.")
		if(RWALL_SUPPORT_RODS)
			. += SPAN_NOTICE("The bolts anchoring the support rods have been <i>loosened</i>, but are still <b>welded</b> firmly to the girder.")
		if(RWALL_SHEATH)
			. += SPAN_NOTICE("The support rods have been <i>sliced through</i>, and the outer sheath is <b>connected loosely</b> to the girder.")

/turf/simulated/wall/r_wall/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK

	if(d_state == RWALL_COVER && istype(attacking, /obj/item/gun/energy/plasmacutter))
		to_chat(user, SPAN_NOTICE("You begin slicing through the metal cover..."))
		if(attacking.use_tool(src, user, 40, volume = attacking.tool_volume) && d_state == RWALL_COVER)
			d_state = RWALL_CUT_COVER
			update_icon()
			to_chat(user, SPAN_NOTICE("You press firmly on the cover, dislodging it."))
		return FINISH_ATTACK
	else if(d_state == RWALL_SUPPORT_RODS && istype(attacking, /obj/item/gun/energy/plasmacutter))
		to_chat(user, SPAN_NOTICE("You begin slicing through the support rods..."))
		if(attacking.use_tool(src, user, 70, volume = attacking.tool_volume) && d_state == RWALL_SUPPORT_RODS)
			d_state = RWALL_SHEATH
			update_icon()
		return FINISH_ATTACK

	else if(d_state)
		// Repairing
		if(istype(attacking, /obj/item/stack/sheet/metal))
			var/obj/item/stack/sheet/metal/MS = attacking
			to_chat(user, SPAN_NOTICE("You begin patching-up the wall with [MS]..."))
			if(do_after(user, max(20 * d_state, 100) * MS.toolspeed, target = src) && d_state)
				if(!MS.use(1))
					to_chat(user, SPAN_WARNING("You don't have enough [MS.name] for that!"))
					return FINISH_ATTACK
				d_state = RWALL_INTACT
				update_icon()
				QUEUE_SMOOTH_NEIGHBORS(src)
				to_chat(user, SPAN_NOTICE("You repair the last of the damage."))
			return FINISH_ATTACK

/turf/simulated/wall/r_wall/welder_act(mob/user, obj/item/I)
	if(reagents?.get_reagent_amount("thermite") && I.use_tool(src, user, volume = I.tool_volume))
		thermitemelt(user)
		return TRUE
	if(!(d_state in list(RWALL_COVER, RWALL_SUPPORT_RODS, RWALL_CUT_COVER)))
		return ..()
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(d_state == RWALL_COVER)
		to_chat(user, SPAN_NOTICE("You begin slicing through the metal cover..."))
		if(I.use_tool(src, user, 60, volume = I.tool_volume) && d_state == RWALL_COVER)
			d_state = RWALL_CUT_COVER
			to_chat(user, SPAN_NOTICE("You press firmly on the cover, dislodging it."))
	else if(d_state == RWALL_SUPPORT_RODS)
		to_chat(user, SPAN_NOTICE("You begin slicing through the support rods..."))
		if(I.use_tool(src, user, 100, volume = I.tool_volume) && d_state == RWALL_SUPPORT_RODS)
			d_state = RWALL_SHEATH
	else if(d_state == RWALL_CUT_COVER)
		to_chat(user, SPAN_NOTICE("You begin welding the metal cover back to the frame..."))
		if(I.use_tool(src, user, 60, volume = I.tool_volume) && d_state == RWALL_CUT_COVER)
			to_chat(user, SPAN_NOTICE("The metal cover has been welded securely to the frame."))
			d_state = RWALL_COVER
	update_icon()

/turf/simulated/wall/r_wall/crowbar_act(mob/user, obj/item/I)
	if(!(d_state in list(RWALL_CUT_COVER, RWALL_SHEATH, RWALL_BOLTS)))
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	switch(d_state)
		if(RWALL_CUT_COVER)
			to_chat(user, SPAN_NOTICE("You struggle to pry off the cover..."))
			if(!I.use_tool(src, user, 100, volume = I.tool_volume) || d_state != RWALL_CUT_COVER)
				return
			d_state = RWALL_BOLTS
			to_chat(user, SPAN_NOTICE("You pry off the cover."))
		if(RWALL_SHEATH)
			to_chat(user, SPAN_NOTICE("You struggle to pry off the outer sheath..."))
			if(!I.use_tool(src, user, 100, volume = I.tool_volume))
				return
			if(dismantle_wall())
				to_chat(user, SPAN_NOTICE("You pry off the outer sheath."))

		if(RWALL_BOLTS)
			to_chat(user, SPAN_NOTICE("You start to pry the cover back into place..."))
			playsound(src, I.usesound, 100, 1)
			if(!I.use_tool(src, user, 20, volume = I.tool_volume) || d_state != RWALL_BOLTS)
				return
			d_state = RWALL_CUT_COVER
			to_chat(user, SPAN_NOTICE("The metal cover has been pried back into place."))
	update_icon()

/turf/simulated/wall/r_wall/screwdriver_act(mob/user, obj/item/I)
	if(d_state != RWALL_SUPPORT_LINES && d_state != RWALL_COVER)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	var/state_check = d_state
	if(d_state == RWALL_SUPPORT_LINES)
		to_chat(user, SPAN_NOTICE("You begin unsecuring the support lines..."))
	else
		to_chat(user, SPAN_NOTICE("You begin securing the support lines..."))
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state_check != d_state)
		return
	if(d_state == RWALL_SUPPORT_LINES)
		d_state = RWALL_COVER
		to_chat(user, SPAN_NOTICE("You unsecure the support lines."))
	else
		d_state = RWALL_SUPPORT_LINES
		to_chat(user, SPAN_NOTICE("The support lines have been secured."))
	update_icon()

/turf/simulated/wall/r_wall/wirecutter_act(mob/user, obj/item/I)
	if(d_state != RWALL_INTACT && d_state != RWALL_SUPPORT_LINES)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(d_state == RWALL_INTACT)
		d_state = RWALL_SUPPORT_LINES
		to_chat(user, SPAN_NOTICE("You cut the outer grille."))
	else
		d_state = RWALL_INTACT
		to_chat(user, SPAN_NOTICE("You mend the outer grille."))
	update_icon()

/turf/simulated/wall/r_wall/wrench_act(mob/user, obj/item/I)
	if(d_state != RWALL_BOLTS && d_state != RWALL_SUPPORT_RODS)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	var/state_check = d_state
	if(d_state == RWALL_BOLTS)
		to_chat(user, SPAN_NOTICE("You start loosening the anchoring bolts which secure the support rods to their frame..."))
	else
		to_chat(user, SPAN_NOTICE("You start tightening the bolts which secure the support rods to their frame..."))
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state_check != d_state)
		return
	if(d_state == RWALL_BOLTS)
		d_state = RWALL_SUPPORT_RODS
		to_chat(user, SPAN_NOTICE("You remove the bolts anchoring the support rods."))
	else
		d_state = RWALL_BOLTS
		to_chat(user, SPAN_NOTICE("You tighten the bolts anchoring the support rods."))
	update_icon()

/turf/simulated/wall/r_wall/try_decon(obj/item/I, mob/user, params) //Plasma cutter only works in the deconstruction steps!
	return FALSE

/turf/simulated/wall/r_wall/try_destroy(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pickaxe/drill/diamonddrill))
		to_chat(user, SPAN_NOTICE("You begin to drill though the wall..."))

		if(do_after(user, 800 * I.toolspeed, target = src)) // Diamond drill has 0.25 toolspeed, so 200
			to_chat(user, SPAN_NOTICE("Your drill tears through the last of the reinforced plating."))
			dismantle_wall()
		return TRUE

	if(istype(I, /obj/item/pickaxe/drill/jackhammer))
		to_chat(user, SPAN_NOTICE("You begin to disintegrate the wall..."))

		if(do_after(user, 1000 * I.toolspeed, target = src)) // Jackhammer has 0.1 toolspeed, so 100
			to_chat(user, SPAN_NOTICE("Your sonic jackhammer disintegrates the reinforced plating."))
			dismantle_wall()
		return TRUE

	if(istype(I, /obj/item/pyro_claws))
		to_chat(user, SPAN_NOTICE("You begin to melt the wall..."))
		if(do_after(user, 50 * I.toolspeed, target = src)) // claws has 0.5 toolspeed, so 2.5 seconds
			to_chat(user, SPAN_NOTICE("Your [I] melt the reinforced plating."))
			dismantle_wall()
		return TRUE

	if(istype(I, /obj/item/zombie_claw))
		to_chat(user, SPAN_NOTICE("You begin to claw apart the wall."))
		if(do_after(user, 2 MINUTES * I.toolspeed, target = src))
			to_chat(user, SPAN_NOTICE("Your [I.name] rip apart the reinforced plating."))
			dismantle_wall()
		return TRUE

/turf/simulated/wall/r_wall/wall_singularity_pull(current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()

/turf/simulated/wall/r_wall/update_icon_state()
	if(d_state)
		icon_state = "r_wall-[d_state]"
		smoothing_flags = NONE
	else
		smoothing_flags = SMOOTH_BITMASK
		icon_state = "[base_icon_state]-[smoothing_junction]"
		QUEUE_SMOOTH_NEIGHBORS(src)
		QUEUE_SMOOTH(src)

/turf/simulated/wall/r_wall/devastate_wall()
	new sheet_type(src, sheet_amount)
	new /obj/item/stack/sheet/metal(src, 2)
