/obj/item/rcl
	name = "rapid cable layer (RCL)"
	desc = "An electrician's best friend, this plastic spool can hold a large amount of cable and rapidly lay it down."
	icon = 'icons/obj/rcl.dmi'
	icon_state = "rcl"
	inhand_icon_state = "rcl"
	throwforce = 5
	origin_tech = "engineering=4;materials=2"
	materials = list(MAT_METAL = 5000)
	var/active = FALSE
	var/obj/structure/cable/last
	var/obj/item/stack/cable_coil/random/rcl_spool/loaded
	new_attack_chain = TRUE

/obj/item/rcl/Initialize(mapload)
	. = ..()
	loaded = new()
	AddComponent(/datum/component/two_handed)
	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/obj/item/rcl/examine(mob/user)
	. = ..()
	if(loaded.amount)
		. += SPAN_NOTICE("It contains <b>[loaded.amount]/[RCL_MAX_SPOOL_SIZE]</b> cables.")
	else
		. += SPAN_WARNING("It's empty!")
	. += SPAN_NOTICE("Use in-hand to swap to [active ? "standard" : "Rapid Cable Laying"] mode.")

/obj/item/rcl/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/stack/cable_coil))
		return ..()

	var/obj/item/stack/cable_coil/coil = used
	if(loaded.amount >= RCL_MAX_SPOOL_SIZE)
		to_chat(user, SPAN_WARNING("You cannot fit any more cable on [src]!"))
		return ITEM_INTERACT_COMPLETE

	// When loading an empty cable spool, turn it into either standard or heavy based on what we're loading.
	if(!loaded.amount)
		loaded.color = coil.color
		loaded.cable_type = coil.cable_type
		loaded.cable_merge_id = coil.cable_merge_id
	else if(loaded.cable_merge_id != coil.cable_merge_id)
		to_chat(user, SPAN_WARNING("These coils are of different types!"))
		return ITEM_INTERACT_COMPLETE

	var/amount = min(loaded.amount + coil.get_amount(), RCL_MAX_SPOOL_SIZE)
	coil.use(amount - loaded.amount)
	loaded.amount = amount
	refresh_icon(user)
	to_chat(user, SPAN_NOTICE("You add the cables to [src]. It now contains [loaded.amount]."))
	return ITEM_INTERACT_COMPLETE

/obj/item/rcl/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(istype(target, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = target
		C.melee_attack_chain(user, src, list2params(modifiers))
		return ITEM_INTERACT_COMPLETE
	
	loaded.melee_attack_chain(user, target, list2params(modifiers))
	return ITEM_INTERACT_COMPLETE

/obj/item/rcl/proc/refresh_icon(mob/user)
	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)
	user.update_inv_l_hand()
	user.update_inv_r_hand()

/obj/item/rcl/screwdriver_act(mob/user, obj/item/I)
	if(!loaded)
		to_chat(user, SPAN_WARNING("There's no cable to remove!"))
		return
	. = TRUE
	if(!I.use_tool(src, user, FALSE, volume = I.tool_volume))
		return
	to_chat(user, SPAN_NOTICE("You loosen the securing screws on the side, allowing you to lower the guiding edge and retrieve the wires."))
	while(loaded.amount)
		var/diff = 30
		if(loaded.amount < 30)
			diff = loaded.amount
		if(loaded.cable_merge_id == CABLE_LOW_POWER)
			var/obj/item/stack/cable_coil/dropped_coil = new /obj/item/stack/cable_coil(user.loc, diff)
			dropped_coil.color = loaded.color
			loaded.use(diff)
		else
			new /obj/item/stack/cable_coil/extra_insulated(user.loc, diff)
			loaded.use(diff)
	refresh_icon(user)

/obj/item/rcl/Destroy()
	QDEL_NULL(loaded)
	last = null
	active = FALSE
	return ..()

/obj/item/rcl/update_overlays()
	. = ..()
	overlays.Cut()
	if(!loaded.amount)
		return

	var/coil_size
	switch(loaded.amount)
		if(61 to INFINITY)
			coil_size = "full"
		if(31 to 60)
			coil_size = "mid"
		if(1 to 30)
			coil_size = "low"

	if(loaded.cable_merge_id == CABLE_LOW_POWER)
		var/image/cable_overlay = image('icons/obj/rcl.dmi', icon_state = "rcl_[coil_size]")
		cable_overlay.color = loaded.color
		overlays += cable_overlay
	else if(loaded.cable_type == /obj/structure/cable/extra_insulated)
		overlays += "rcl_[coil_size]_hd"
	else
		overlays += "rcl_[coil_size]_hd_connected"


/obj/item/rcl/update_icon_state()
	. = ..()
	if(loaded.cable_merge_id == CABLE_LOW_POWER)
		inhand_icon_state = "rcl[loaded.amount ? "_[loaded.color]" : null]"
	else if(loaded.cable_type == /obj/structure/cable/extra_insulated)
		inhand_icon_state = "rcl[loaded.amount ?  "_hd" : null]"
	else
		inhand_icon_state = "rcl[loaded.amount ? "_hd_connected" : null]"

/obj/item/rcl/proc/is_empty(mob/user, loud = 1)
	refresh_icon(user)
	if(!loaded.amount)
		if(loud)
			to_chat(user, SPAN_WARNING("The last of the cables unreel from [src]!"))
		return TRUE
	return FALSE

/obj/item/rcl/dropped(mob/wearer)
	..()
	active = FALSE
	last = null

/obj/item/rcl/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK

	if(iscarbon(user))
		active = HAS_TRAIT(src, TRAIT_WIELDED)
	else
		active = !active
	if(!active)
		last = null
	else if(!last)
		for(var/obj/structure/cable/C in get_turf(user))
			if(C.d1 == 0 || C.d2 == 0)
				last = C
				break

	to_chat(user, SPAN_NOTICE("You [active ? "prepare to rapidly lay cable" : "stop rapidly laying cable"]."))

/obj/item/rcl/on_mob_move(direct, mob/user)
	if(active && isturf(user.loc))
		trigger(user)

/obj/item/rcl/proc/trigger(mob/user)
	if(is_empty(user, 0))
		to_chat(user, SPAN_WARNING("[src] is empty!"))
		return
	if(last)
		if(get_dist(last, user) == 1) //hacky, but it works
			var/turf/T = get_turf(user)
			if(!isturf(T) || T.intact || !T.can_have_cabling())
				last = null
				return
			if(get_dir(last, user) == last.d2)
				//Did we just walk backwards? Well, that's the one direction we CAN'T complete a stub.
				last = null
				return
			loaded.cable_join(last, user)
			if(is_empty(user))
				return //If we've run out, display message and exit
		else
			last = null
	last = loaded.place_turf(get_turf(loc), user, turn(user.dir, 180))
	is_empty(user) //If we've run out, display message

/obj/item/rcl/empty/Initialize(mapload)
	..()
	loaded.use(RCL_MAX_SPOOL_SIZE, FALSE)
	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/obj/item/rcl/robot
	name = "robotic rapid cable layer (RRCL)"
	desc = "A Rapid Cable Layer used to hold a spool of cable for engineering and construction robots."
	/// Tells us if we're laying basic or insulated cable.
	var/heavy_mode = FALSE

/obj/item/rcl/robot/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("[src] is currently dispensing [heavy_mode ? "<b>heavy duty cable</b>" : "<b>standard cable</b>"].")
	. += SPAN_NOTICE("<b>Alt-Click</b> to swap between laying <b>standard</b> and <b>heavy duty</b> cable.")
	. += SPAN_NOTICE("<b>Ctrl-Click</b> to [heavy_mode ? "toggle cable connectivity" : "select cable color"].")

/obj/item/rcl/robot/screwdriver_act(mob/user, obj/item/I)
	return

/obj/item/rcl/robot/AltClick(mob/user, modifiers)
	if(..())
		return ITEM_INTERACT_COMPLETE
	
	if(heavy_mode)
		loaded.cable_type = /obj/structure/cable
		loaded.cable_merge_id = CABLE_LOW_POWER
		loaded.color = "red"
	else
		loaded.cable_type = /obj/structure/cable/extra_insulated
		loaded.cable_merge_id = CABLE_HIGH_POWER
		loaded.color = null
	heavy_mode = !heavy_mode
	to_chat(user, SPAN_NOTICE("You start dispensing [heavy_mode ? "heavy-duty cable" : "standard cable"]."))
	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/obj/item/rcl/robot/CtrlClick(mob/user, modifiers)
	if(!heavy_mode)
		var/new_cable_color = tgui_input_list(user, "Pick a cable color.", "Cable Color", list("white","red","orange","yellow","green","blue","cyan","pink"))
		if(!new_cable_color)
			return

		to_chat(user, SPAN_NOTICE("[src] is now dispensing [new_cable_color] cable."))
		// For reasons beyond my comprehension, BYOND cannot comprehend the fact that green is equal to itself unless you explicitly tell it so.
		if(new_cable_color == "green")
			new_cable_color = COLOR_GREEN
		loaded.cable_color(new_cable_color)
	else
		if(loaded.cable_type == /obj/structure/cable/extra_insulated/pre_connect)
			loaded.cable_type = /obj/structure/cable/extra_insulated
			to_chat(user, SPAN_NOTICE("[src] is now dispensing closed-connection heavy duty cable"))
		else
			loaded.cable_type = /obj/structure/cable/extra_insulated/pre_connect
			to_chat(user, SPAN_NOTICE("[src] is now dispensing open-connection heavy duty cable"))

	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/obj/item/stack/cable_coil/random/rcl_spool
	rcl_spool = TRUE
	max_amount = RCL_MAX_SPOOL_SIZE
	amount = RCL_MAX_SPOOL_SIZE
