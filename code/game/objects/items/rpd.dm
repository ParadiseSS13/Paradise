/*Contains:
	Rapid Pipe Dispenser
*/

#define RPD_COOLDOWN_TIME		4 //How long should we have to wait between dispensing pipes?
#define RPD_WALLBUILD_TIME		40 //How long should drilling into a wall take?
#define RPD_MENU_ROTATE "Rotate pipes" //Stuff for radial menu
#define RPD_MENU_FLIP "Flip pipes" //Stuff for radial menu
#define RPD_MENU_DELETE "Delete pipes" //Stuff for radial menu

/obj/item/rpd
	name = "rapid pipe dispenser"
	desc = "This device can rapidly dispense atmospherics and disposals piping, manipulate loose piping, and recycle any detached pipes it is applied to."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rpd"
	flags = CONDUCT
	force = 10
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL = 75000, MAT_GLASS = 37500)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF
	origin_tech = "engineering=4;materials=2"
	new_attack_chain = TRUE
	var/datum/effect_system/spark_spread/spark_system
	var/lastused
	/// Used to orient icons and pipes.
	var/iconrotation = 0
	/// Disposals, atmospherics, etc.
	var/mode = RPD_ATMOS_MODE
	/// For TGUI menus, this is a subtype of pipes e.g. scrubbers pipes, devices.
	var/pipe_category = RPD_ATMOS_PIPING
	/// What kind of atmos pipe are we trying to lay?
	var/whatpipe = PIPE_SIMPLE_STRAIGHT
	/// What kind of disposals pipe are we trying to lay?
	var/whatdpipe = PIPE_DISPOSALS_STRAIGHT
	/// What kind of transit tube are we trying to lay?
	var/whatttube = PIPE_TRANSIT_TUBE
	/// Cooldown on RPD use.
	var/spawndelay = RPD_COOLDOWN_TIME
	/// Time taken to drill a borehole before the pipe can be laid.
	var/walldelay = RPD_WALLBUILD_TIME
	/// Can this RPD lay pipe on non-adjacent turfs?
	var/ranged = FALSE
	var/primary_sound = 'sound/machines/click.ogg'
	var/alt_sound = null
	var/auto_wrench_toggle = TRUE
	var/pipe_label = null

	//Lists of things
	var/list/mainmenu = list(
		list("category" = "Atmospherics", "mode" = RPD_ATMOS_MODE, "icon" = "wrench"),
		list("category" = "Disposals", "mode" = RPD_DISPOSALS_MODE, "icon" = "recycle"),
		list("category" = "Transit", "mode" = RPD_TRANSIT_MODE, "icon" = "subway"),
		list("category" = "Rotate", "mode" = RPD_ROTATE_MODE, "icon" = "sync-alt"),
		list("category" = "Flip", "mode" = RPD_FLIP_MODE, "icon" = "arrows-alt-h"),
		list("category" = "Recycle", "mode" = RPD_DELETE_MODE, "icon" = "trash"))
	var/list/pipemenu = list(
		list("category" = "Normal", "pipemode" = RPD_ATMOS_PIPING),
		list("category" = "Supply", "pipemode" = RPD_SUPPLY_PIPING),
		list("category" = "Scrubber", "pipemode" = RPD_SCRUBBERS_PIPING),
		list("category" = "Devices", "pipemode" = RPD_DEVICES),
		list("category" = "Heat exchange", "pipemode" = RPD_HEAT_PIPING))


/obj/item/rpd/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(1, 0, src)
	spark_system.attach(src)

/obj/item/rpd/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/rpd/bluespace
	name = "bluespace rapid pipe dispenser"
	desc = "This device can rapidly dispense atmospherics and disposals piping, manipulate loose piping, and recycle any detached pipes it is applied to, at any range."
	icon_state = "brpd"
	materials = list(MAT_METAL = 75000, MAT_GLASS = 37500, MAT_SILVER = 3000)
	origin_tech = "engineering=4;materials=2;bluespace=3"
	ranged = TRUE
	primary_sound = 'sound/items/PSHOOM.ogg'
	alt_sound = 'sound/items/PSHOOM_2.ogg'

//Procs

/obj/item/rpd/proc/activate_rpd(delay) //Maybe makes sparks and activates cooldown if there is a delay
	if(alt_sound && prob(3))
		playsound(src, alt_sound, 50, 1)
	else
		playsound(src, primary_sound, 50, 1)
	if(prob(15) && !ranged)
		spark_system.start()
	if(delay)
		lastused = world.time

/obj/item/rpd/proc/can_dispense_pipe(pipe_id, pipe_type) //Returns TRUE if this is a legit pipe we can dispense, otherwise returns FALSE
	for(var/list/L in GLOB.rpd_pipe_list)
		if(pipe_type != L["pipe_type"]) //Sometimes pipes in different categories have the same pipe_id, so we need to skip anything not in the category we want
			continue
		if(pipe_id == L["pipe_id"]) //Found the pipe, we can dispense it
			return TRUE

/obj/item/rpd/proc/create_atmos_pipe(mob/user, turf/T) //Make an atmos pipe, meter, or gas sensor
	if(!can_dispense_pipe(whatpipe, RPD_ATMOS_MODE))
		CRASH("Failed to spawn [get_pipe_name(whatpipe, PIPETYPE_ATMOS)] - possible tampering detected") //Damn dirty apes -- I mean hackers
	var/obj/item/pipe/P
	if(whatpipe == PIPE_GAS_SENSOR)
		P = new /obj/item/pipe_gsensor(T)
	else if(whatpipe == PIPE_METER)
		P = new /obj/item/pipe_meter(T)
	else
		P = new(T, whatpipe, iconrotation) //Make the pipe, BUT WAIT! There's more!
		if(!iconrotation && P.is_bent_pipe()) //Automatically rotates dispensed pipes if the user selected auto-rotation
			P.dir = turn(user.dir, 135)
		else if(!iconrotation && (P.pipe_type in list(PIPE_CONNECTOR, PIPE_UVENT, PIPE_SCRUBBER, PIPE_HEAT_EXCHANGE, PIPE_CAP, PIPE_SUPPLY_CAP, PIPE_SCRUBBERS_CAP, PIPE_INJECTOR, PIPE_PASV_VENT))) //Some pipes dispense oppositely to what you'd expect, but we don't want to do anything if they selected a direction
			P.dir = turn(user.dir, -180)
		else if(iconrotation && P.is_bent_pipe()) //If user selected a rotation and the pipe is bent
			P.dir = turn(iconrotation, -45)
		else if(!iconrotation) //If user selected a rotation
			P.dir = user.dir
	to_chat(user, "<span class='notice'>[src] rapidly dispenses [P]!</span>")
	P.label = pipe_label
	automatic_wrench_down(user, P)
	activate_rpd(TRUE)

/obj/item/rpd/proc/create_disposals_pipe(mob/user, turf/T) //Make a disposals pipe / construct
	if(!can_dispense_pipe(whatdpipe, RPD_DISPOSALS_MODE))
		CRASH("Failed to spawn [get_pipe_name(whatdpipe, PIPETYPE_DISPOSAL)] - possible tampering detected")
	var/obj/structure/disposalconstruct/P = new(T, whatdpipe, iconrotation)
	if(!iconrotation) //Automatic rotation
		P.dir = user.dir
	if(!iconrotation && whatdpipe != PIPE_DISPOSALS_JUNCTION_RIGHT) //Disposals pipes are in the opposite direction to atmos pipes, so we need to flip them. Junctions don't have this quirk though
		P.flip()
	to_chat(user, "<span class='notice'>[src] rapidly dispenses [P]!</span>")
	automatic_wrench_down(user, P)
	activate_rpd(TRUE)

/obj/item/rpd/proc/create_transit_tube(mob/user, turf/dest)
	if(!can_dispense_pipe(whatttube, PIPETYPE_TRANSIT))
		CRASH("Failed to spawn [get_pipe_name(whatttube, PIPETYPE_TRANSIT)] - possible tampering detected")

	for(var/datum/pipes/transit/T in GLOB.construction_pipe_list)
		if(T.pipe_id == whatttube)
			var/obj/structure/transit_tube_construction/S = new T.construction_type(dest)
			if(!istype(S))
				CRASH("found [S] when constructing transit tube but expected /obj/structure/transit_tube_construction")

			S.dir = iconrotation ? iconrotation : user.dir

			to_chat(user, "<span class='notice'>[src] rapidly dispenses [S]!</span>")
			automatic_wrench_down(user, S)
			activate_rpd(TRUE)

/obj/item/rpd/proc/rotate_all_pipes(mob/user, turf/T) //Rotate all pipes on a turf
	for(var/obj/item/pipe/P in T)
		P.rotate()
	for(var/obj/structure/disposalconstruct/D in T)
		D.rotate()
	for(var/obj/structure/transit_tube_construction/tube in T)
		tube.rotate()

/obj/item/rpd/proc/flip_all_pipes(mob/user, turf/T) //Flip all pipes on a turf
	for(var/obj/item/pipe/P in T)
		P.flip()
	for(var/obj/structure/disposalconstruct/D in T)
		D.flip()
	for(var/obj/structure/transit_tube_construction/tube in T)
		tube.flip()

/obj/item/rpd/proc/delete_all_pipes(mob/user, turf/T) //Delete all pipes on a turf
	var/eaten
	for(var/obj/item/pipe/P in T)
		if(P.pipe_type == PIPE_CIRCULATOR) //Skip TEG heat circulators, they aren't really pipes
			continue
		QDEL_NULL(P)
		eaten = TRUE
	for(var/obj/item/pipe_gsensor/G in T)
		QDEL_NULL(G)
		eaten = TRUE
	for(var/obj/item/pipe_meter/M in T)
		QDEL_NULL(M)
		eaten = TRUE
	for(var/obj/structure/disposalconstruct/D in T)
		if(!D.anchored)
			QDEL_NULL(D)
			eaten = TRUE
	for(var/obj/structure/transit_tube_construction/C in T)
		QDEL_NULL(C)
		eaten = TRUE
	if(eaten)
		to_chat(user, "<span class='notice'>[src] sucks up the loose pipes on [T].")
		activate_rpd()
	else
		to_chat(user, "<span class='notice'>There were no loose pipes on [T].</span>")

/obj/item/rpd/proc/delete_single_pipe(mob/user, obj/P) //Delete a single pipe
	to_chat(user, "<span class='notice'>[src] sucks up [P].</span>")
	QDEL_NULL(P)
	activate_rpd()

/**
 * Automatically wrenches down an atmos device/pipe if the auto_wrench_toggle is TRUE.
 * Arguments:
 * * user - the user of the RPD.
 * * target - the pipe/device/tube being placed by the RPD.
 */
/obj/item/rpd/proc/automatic_wrench_down(mob/living/user, obj/item/target)
	if(!auto_wrench_toggle)
		return
	if(mode == RPD_TRANSIT_MODE)
		if(target.screwdriver_act(user, src) & RPD_TOOL_SUCCESS)
			playsound(src, 'sound/items/impactwrench.ogg', 50, TRUE)
			return
	if(target.wrench_act(user, src) & RPD_TOOL_SUCCESS)
		playsound(src, 'sound/items/impactwrench.ogg', 50, TRUE)
		return
// TGUI stuff

/obj/item/rpd/activate_self(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/item/rpd/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/rpd/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RPD", name)
		ui.open()

/obj/item/rpd/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/rpd)
	)

/obj/item/rpd/AltClick(mob/user)
	radial_menu(user)

/obj/item/rpd/ui_data(mob/user)
	var/list/data = list()
	data["iconrotation"] = iconrotation
	data["mainmenu"] = mainmenu
	data["mode"] = mode
	data["pipelist"] = GLOB.rpd_pipe_list
	data["pipemenu"] = pipemenu
	data["pipe_category"] = pipe_category
	data["whatdpipe"] = whatdpipe
	data["whatpipe"] = whatpipe
	data["whatttube"] = whatttube
	data["auto_wrench_toggle"] = auto_wrench_toggle
	return data

/obj/item/rpd/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("iconrotation")
			iconrotation = isnum(params[action]) ? params[action] : text2num(params[action])
		if("whatpipe")
			whatpipe = isnum(params[action]) ? params[action] : text2num(params[action])
		if("whatdpipe")
			whatdpipe = isnum(params[action]) ? params[action] : text2num(params[action])
		if("whatttube")
			whatttube = isnum(params[action]) ? params[action] : text2num(params[action])
		if("pipe_category")
			pipe_category = isnum(params[action]) ? params[action] : text2num(params[action])
		if("mode")
			mode = isnum(params[action]) ? params[action] : text2num(params[action])
		if("auto_wrench_toggle")
			auto_wrench_toggle = !auto_wrench_toggle
		if("set_label")
			pipe_label = params[action]

//RPD radial menu
/obj/item/rpd/proc/check_menu(mob/living/user)
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	if(loc != user)
		return
	return TRUE

/obj/item/rpd/proc/radial_menu(mob/user)
	if(!check_menu(user))
		to_chat(user, "<span class='notice'>You can't do that right now!</span>")
		return
	var/list/choices = list(
		RPD_MENU_ROTATE = image(icon = 'icons/obj/interface.dmi', icon_state = "rpd_rotate"),
		RPD_MENU_FLIP = image(icon = 'icons/obj/interface.dmi', icon_state = "rpd_flip"),
		RPD_MENU_DELETE = image(icon = 'icons/obj/interface.dmi', icon_state = "rpd_delete"),
		"UI" = image(icon = 'icons/obj/interface.dmi', icon_state = "ui_interact")
	)
	var/selected_mode = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user))
	if(!check_menu(user))
		return
	if(selected_mode == "UI")
		ui_interact(user)
	else
		switch(selected_mode)
			if(RPD_MENU_ROTATE)
				mode = RPD_ROTATE_MODE
			if(RPD_MENU_FLIP)
				mode = RPD_FLIP_MODE
			if(RPD_MENU_DELETE)
				mode = RPD_DELETE_MODE
			else
				return //Either nothing was selected, or an invalid mode was selected
		to_chat(user, "<span class='notice'>You set [src]'s mode.</span>")

/obj/item/rpd/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!ranged)
		return NONE

	if(handle_atom_interaction(target, user, ranged))
		return ITEM_INTERACT_COMPLETE

	return NONE

/obj/item/rpd/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(handle_atom_interaction(target, user, ranged))
		return ITEM_INTERACT_COMPLETE

	return NONE

/obj/item/rpd/proc/handle_atom_interaction(atom/target, mob/living/user, ranged)
	if(isstorage(target) || ismodcontrol(target))
		return NONE

	if(world.time < lastused + spawndelay)
		return ITEM_INTERACT_COMPLETE

	// Use as melee weapon
	if(user.a_intent == INTENT_HARM)
		return NONE

	var/turf/T = get_turf(target)
	if(!T)
		return ITEM_INTERACT_COMPLETE

	if(target != T)
		if(target.loc != T) // Avoids placing pipes when clicking onto something that's inside something. Like clicking on your PDA on UI.
			return ITEM_INTERACT_COMPLETE

		// We only check the rpd_act of the target if it isn't the turf, because otherwise
		// (A) blocked turfs can be acted on, and (B) unblocked turfs get acted on twice.
		if(target.rpd_act(user, src))
			// If the object we are clicking on has a valid RPD interaction for just that specific object, do that and nothing else.
			// Example: clicking on a pipe with a RPD in rotate mode should rotate that pipe and ignore everything else on the tile.
			if(ranged)
				user.Beam(T, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)
			return ITEM_INTERACT_COMPLETE

	// If we get this far, we have to check every object in the tile, to make sure that none of them block RPD usage on this tile.
	// This is done by calling rpd_blocksusage on every /obj in the tile. If any block usage, fail at this point.
	for(var/obj/O in T)
		if(O.rpd_blocksusage())
			to_chat(user, "<span class='warning'>[O] blocks [src]!</span>")
			return ITEM_INTERACT_COMPLETE

	// If we get here, then we're effectively acting on the turf, probably placing a pipe.
	if(ranged) //woosh beam!
		if(get_dist(src, T) >= (user.client.maxview() / 2))
			message_admins("\[EXPLOIT] [key_name_admin(user)] attempted to place pipes with a BRPD via a camera console (attempted range exploit).")
			playsound(src, 'sound/machines/synth_no.ogg', 15, TRUE)
			to_chat(user, "<span class='warning'>ERROR: \The [T] is out of [src]'s range!</span>")
			return ITEM_INTERACT_COMPLETE

		if(!(user in hearers(12, T))) // Checks if user can hear the target turf, cause viewers doesnt work for it.
			to_chat(user, "<span class='warning'>[src] needs full visibility to determine the dispensing location.</span>")
			playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE)
			return ITEM_INTERACT_COMPLETE

		user.Beam(T, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)
	T.rpd_act(user, src)
	return ITEM_INTERACT_COMPLETE

#undef RPD_COOLDOWN_TIME
#undef RPD_WALLBUILD_TIME
#undef RPD_MENU_ROTATE
#undef RPD_MENU_FLIP
#undef RPD_MENU_DELETE
