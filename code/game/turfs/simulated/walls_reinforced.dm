/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to separate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "r_wall"
	opacity = 1
	density = 1
	explosion_block = 2
	damage_cap = 600
	max_temperature = 6000
	hardness = 10
	sheet_type = /obj/item/stack/sheet/plasteel
	sheet_amount = 1
	girder_type = /obj/structure/girder/reinforced
	can_dismantle_with_welder = FALSE

	var/d_state = RWALL_INTACT
	var/can_be_reinforced = 1

/turf/simulated/wall/r_wall/examine(mob/user)
	. = ..()
	switch(d_state)
		if(RWALL_INTACT)
			. += "<span class='notice'>The outer <b>grille</b> is fully intact.</span>"
		if(RWALL_SUPPORT_LINES)
			. += "<span class='notice'>The outer <i>grille</i> has been cut, and the support lines are <b>screwed</b> securely to the outer cover.</span>"
		if(RWALL_COVER)
			. += "<span class='notice'>The support lines have been <i>unscrewed</i>, and the metal cover is <b>welded</b> firmly in place.</span>"
		if(RWALL_CUT_COVER)
			. += "<span class='notice'>The metal cover has been <i>sliced through</i>, and is <b>connected loosely</b> to the girder.</span>"
		if(RWALL_BOLTS)
			. += "<span class='notice'>The outer cover has been <i>pried away</i>, and the bolts anchoring the support rods are <b>wrenched</b> in place.</span>"
		if(RWALL_SUPPORT_RODS)
			. += "<span class='notice'>The bolts anchoring the support rods have been <i>loosened</i>, but are still <b>welded</b> firmly to the girder.</span>"
		if(RWALL_SHEATH)
			. += "<span class='notice'>The support rods have been <i>sliced through</i>, and the outer sheath is <b>connected loosely</b> to the girder.</span>"

/turf/simulated/wall/r_wall/attackby(obj/item/I, mob/user, params)
	if(d_state == RWALL_COVER && istype(I, /obj/item/gun/energy/plasmacutter))
		to_chat(user, "<span class='notice'>You begin slicing through the metal cover...</span>")
		if(I.use_tool(src, user, 40, volume = I.tool_volume) && d_state == RWALL_COVER)
			d_state = RWALL_CUT_COVER
			update_icon()
			to_chat(user, "<span class='notice'>You press firmly on the cover, dislodging it.</span>")
		return
	else if(RWALL_SUPPORT_RODS && istype(I, /obj/item/gun/energy/plasmacutter))
		to_chat(user, "<span class='notice'>You begin slicing through the support rods...</span>")
		if(I.use_tool(src, user, 70, volume = I.tool_volume) && d_state == RWALL_SUPPORT_RODS)
			d_state = RWALL_SHEATH
			update_icon()
		return
	else if(d_state == RWALL_SUPPORT_LINES && istype(I, /obj/item/stack/rods))
		var/obj/item/stack/S = I
		if(S.use(1))
			d_state = RWALL_INTACT
			update_icon()
			to_chat(user, "<span class='notice'>You replace the outer grille.</span>")
		else
			to_chat(user, "<span class='warning'>You don't have enough rods for that!</span>")
		return
	else if(d_state)
		// Repairing
		if(istype(I, /obj/item/stack/sheet/metal))
			var/obj/item/stack/sheet/metal/MS = I
			to_chat(user, "<span class='notice'>You begin patching-up the wall with [MS]...</span>")
			if(do_after(user, max(20 * d_state, 100) * MS.toolspeed, target = src) && d_state)
				if(!MS.use(1))
					to_chat(user, "<span class='warning'>You don't have enough [MS.name] for that!</span>")
					return
				d_state = RWALL_INTACT
				update_icon()
				queue_smooth_neighbors(src)
				to_chat(user, "<span class='notice'>You repair the last of the damage.</span>")
			return

	else if(istype(I, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/PS = I
		if(!can_be_reinforced)
			to_chat(user, "<span class='notice'>The wall is already coated!</span>")
			return
		to_chat(user, "<span class='notice'>You begin adding an additional layer of coating to the wall with [PS]...</span>")
		if(do_after(user, 40 * PS.toolspeed, target = src) && !d_state)
			if(!PS.use(2))
				to_chat(user, "<span class='warning'>You don't have enough [PS.name] for that!</span>")
				return
			to_chat(user, "<span class='notice'>You add an additional layer of coating to the wall.</span>")
			ChangeTurf(/turf/simulated/wall/r_wall/coated)
			update_icon()
			queue_smooth_neighbors(src)
			can_be_reinforced = FALSE
		return
	else
		return ..()

/turf/simulated/wall/r_wall/welder_act(mob/user, obj/item/I)
	if(thermite && I.use_tool(src, user, volume = I.tool_volume))
		thermitemelt(user)
		return TRUE
	if(!(d_state in list(RWALL_COVER, RWALL_SUPPORT_RODS, RWALL_CUT_COVER)))
		return ..()
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(d_state == RWALL_COVER)
		to_chat(user, "<span class='notice'>You begin slicing through the metal cover...</span>")
		if(I.use_tool(src, user, 60, volume = I.tool_volume) && d_state == RWALL_COVER)
			d_state = RWALL_CUT_COVER
			to_chat(user, "<span class='notice'>You press firmly on the cover, dislodging it.</span>")
	else if(d_state == RWALL_SUPPORT_RODS)
		to_chat(user, "<span class='notice'>You begin slicing through the support rods...</span>")
		if(I.use_tool(src, user, 100, volume = I.tool_volume) && d_state == RWALL_SUPPORT_RODS)
			d_state = RWALL_SHEATH
	else if(d_state == RWALL_CUT_COVER)
		to_chat(user, "<span class='notice'>You begin welding the metal cover back to the frame...</span>")
		if(I.use_tool(src, user, 60, volume = I.tool_volume) && d_state == RWALL_CUT_COVER)
			to_chat(user, "<span class='notice'>The metal cover has been welded securely to the frame.</span>")
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
			to_chat(user, "<span class='notice'>You struggle to pry off the cover...</span>")
			if(!I.use_tool(src, user, 100, volume = I.tool_volume) || d_state != RWALL_CUT_COVER)
				return
			d_state = RWALL_BOLTS
			to_chat(user, "<span class='notice'>You pry off the cover.</span>")
		if(RWALL_SHEATH)
			to_chat(user, "<span class='notice'>You struggle to pry off the outer sheath...</span>")
			if(!I.use_tool(src, user, 100, volume = I.tool_volume) || d_state != RWALL_SHEATH)
				return
			to_chat(user, "<span class='notice'>You pry off the outer sheath.</span>")
			dismantle_wall()
			return
		if(RWALL_BOLTS)
			to_chat(user, "<span class='notice'>You start to pry the cover back into place...</span>")
			playsound(src, I.usesound, 100, 1)
			if(!I.use_tool(src, user, 20, volume = I.tool_volume) || d_state != RWALL_BOLTS)
				return
			d_state = RWALL_CUT_COVER
			to_chat(user, "<span class='notice'>The metal cover has been pried back into place.</span>")
	update_icon()

/turf/simulated/wall/r_wall/screwdriver_act(mob/user, obj/item/I)
	if(d_state != RWALL_SUPPORT_LINES && d_state != RWALL_COVER)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	var/state_check = d_state
	if(d_state == RWALL_SUPPORT_LINES)
		to_chat(user, "<span class='notice'>You begin unsecuring the support lines...</span>")
	else
		to_chat(user, "<span class='notice'>You begin securing the support lines...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state_check != d_state)
		return
	if(d_state == RWALL_SUPPORT_LINES)
		d_state = RWALL_COVER
		to_chat(user, "<span class='notice'>You unsecure the support lines.</span>")
	else
		d_state = RWALL_SUPPORT_LINES
		to_chat(user, "<span class='notice'>The support lines have been secured.</span>")
	update_icon()

/turf/simulated/wall/r_wall/wirecutter_act(mob/user, obj/item/I)
	if(d_state != RWALL_INTACT)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	d_state = RWALL_SUPPORT_LINES
	update_icon()
	new /obj/item/stack/rods(src)
	to_chat(user, "<span class='notice'>You cut the outer grille.</span>")

/turf/simulated/wall/r_wall/wrench_act(mob/user, obj/item/I)
	if(d_state != RWALL_BOLTS && d_state != RWALL_SUPPORT_RODS)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	var/state_check = d_state
	if(d_state == RWALL_BOLTS)
		to_chat(user, "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame...</span>")
	else
		to_chat(user, "<span class='notice'>You start tightening the bolts which secure the support rods to their frame...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state_check != d_state)
		return
	if(d_state == RWALL_BOLTS)
		d_state = RWALL_SUPPORT_RODS
		to_chat(user, "<span class='notice'>You remove the bolts anchoring the support rods.</span>")
	else
		d_state = RWALL_BOLTS
		to_chat(user, "<span class='notice'>You tighten the bolts anchoring the support rods.</span>")
	update_icon()

/turf/simulated/wall/r_wall/try_destroy(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pickaxe/drill/diamonddrill))
		to_chat(user, "<span class='notice'>You begin to drill though the wall...</span>")

		if(do_after(user, 800 * I.toolspeed, target = src)) // Diamond drill has 0.25 toolspeed, so 200
			to_chat(user, "<span class='notice'>Your drill tears through the last of the reinforced plating.</span>")
			dismantle_wall()
		return TRUE

	if(istype(I, /obj/item/pickaxe/drill/jackhammer))
		to_chat(user, "<span class='notice'>You begin to disintegrate the wall...</span>")

		if(do_after(user, 1000 * I.toolspeed, target = src)) // Jackhammer has 0.1 toolspeed, so 100
			to_chat(user, "<span class='notice'>Your sonic jackhammer disintegrates the reinforced plating.</span>")
			dismantle_wall()
		return TRUE


/turf/simulated/wall/r_wall/wall_singularity_pull(current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()

/turf/simulated/wall/r_wall/update_icon()
	. = ..()

	if(d_state)
		icon_state = "r_wall-[d_state]"
		smooth = SMOOTH_FALSE
		clear_smooth_overlays()
	else
		smooth = SMOOTH_TRUE
		icon_state = ""

/turf/simulated/wall/r_wall/devastate_wall()
	new sheet_type(src, sheet_amount)
	new /obj/item/stack/sheet/metal(src, 2)
