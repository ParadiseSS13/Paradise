/obj/item/stack/cable_coil/rcl
	name = "rapid cable layer (RCL)"
	desc = "An electrician's best friend, this plastic spool can hold a large amount of cable and rapidly lay it down."
	icon = 'icons/obj/rcl.dmi'
	icon_state = "rcl"
	inhand_icon_state = "rcl"
	throwforce = 5
	belt_icon = null
	origin_tech = "engineering=4;materials=2"
	materials = list(MAT_METAL = 5000)
	destroy_upon_empty = FALSE
	max_amount = RCL_MAX_SPOOL_SIZE
	amount = RCL_MAX_SPOOL_SIZE
	color = null
	/// Are we rapidly laying cable?
	var/active = FALSE
	var/spool_color
	/// Remembers the last cable structure that got laid down to aid in further cable laying.
	var/obj/structure/cable/last

/obj/item/stack/cable_coil/rcl/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("It can stack <b>[RCL_MAX_SPOOL_SIZE]</b> lengths of cable around its spool.")
	. += SPAN_NOTICE("Use in-hand to swap to [active ? "standard" : "Rapid Cable Laying"] mode.")

/obj/item/stack/cable_coil/rcl/Initialize(mapload)
	. = ..()
	// Do not craft from an RCL.
	recipes = null
	color_rainbow()
	AddComponent(/datum/component/two_handed)
	w_class = WEIGHT_CLASS_NORMAL
	refresh_icon()

/obj/item/stack/cable_coil/rcl/Destroy()
	last = null
	active = FALSE
	return ..()

/obj/item/stack/cable_coil/rcl/screwdriver_act(mob/user, obj/item/I)
	if(!amount)
		to_chat(user, SPAN_WARNING("There's no cable to remove!"))
		return

	if(!I.use_tool(src, user, FALSE, volume = I.tool_volume))
		return ITEM_INTERACT_COMPLETE

	to_chat(user, SPAN_NOTICE("You loosen the securing screws on the side, allowing you to lower the guiding edge and retrieve the wires."))
	while(amount)
		var/delta = 30
		if(amount < 30)
			delta = amount
		if(cable_merge_id == CABLE_LOW_POWER)
			var/obj/item/stack/cable_coil/dropped_coil = new /obj/item/stack/cable_coil(user.loc, delta)
			dropped_coil.color = get_cable_color()
			use(delta, FALSE)
		else
			new /obj/item/stack/cable_coil/extra_insulated(user.loc, delta)
			use(delta, FALSE)
	refresh_icon(user)
	return ITEM_INTERACT_COMPLETE

/obj/item/stack/cable_coil/rcl/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/stack/cable_coil))
		return ..()

	// Another RCL is stealing cable from us, let its `interact_with_atom()` fire.
	if(istype(used, /obj/item/stack/cable_coil/rcl))
		return NONE

	load_cable(user, used)
	return ITEM_INTERACT_COMPLETE

/obj/item/stack/cable_coil/rcl/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!istype(target, /obj/item/stack/cable_coil))	
		..()
		is_empty(user)
		return NONE

	load_cable(user, target)
	return ITEM_INTERACT_COMPLETE

/obj/item/stack/cable_coil/rcl/proc/load_cable(mob/living/user, obj/item/used)
	var/obj/item/stack/cable_coil/used_coil = used
	if(get_amount() >= RCL_MAX_SPOOL_SIZE)
		to_chat(user, SPAN_WARNING("You cannot fit any more cable on [src]!"))
		return ITEM_INTERACT_COMPLETE

	// When loading an empty cable spool, turn it into either standard or heavy based on what we're loading.
	if(!get_amount())
		spool_color = used_coil.get_cable_color()
		cable_type = used_coil.cable_type
		cable_merge_id = used_coil.cable_merge_id
	// Robot RCL can freely swap between cable types anyway, allow them to eat the cable.
	else if((cable_merge_id != used_coil.cable_merge_id) && !is_robot_module())
		to_chat(user, SPAN_WARNING("These coils are of different types!"))
		return ITEM_INTERACT_COMPLETE

	var/delta = (RCL_MAX_SPOOL_SIZE - get_amount())
	add(min(used_coil.get_amount(), delta))
	used_coil.use(min(used_coil.get_amount(), delta), used_coil.destroy_upon_empty)
	refresh_icon(user)
	to_chat(user, SPAN_NOTICE("You add the cables to [src]. It now contains [get_amount()]."))
	return ITEM_INTERACT_COMPLETE

/obj/item/stack/cable_coil/rcl/get_cable_color()
	return spool_color

/obj/item/stack/cable_coil/rcl/proc/refresh_icon(mob/user)
	if(color)
		spool_color = color
		color = null
	update_icon(UPDATE_ICON_STATE|UPDATE_OVERLAYS)
	if(user)
		user.update_inv_l_hand()
		user.update_inv_r_hand()

/obj/item/stack/cable_coil/rcl/update_overlays()
	. = ..()
	overlays.Cut()
	if(!get_amount())
		return

	var/coil_size
	switch(get_amount())
		if(61 to INFINITY)
			coil_size = "full"
		if(31 to 60)
			coil_size = "mid"
		if(1 to 30)
			coil_size = "low"
	if(cable_merge_id == CABLE_LOW_POWER)
		var/image/cable_overlay = image('icons/obj/rcl.dmi', icon_state = "rcl_[coil_size]")
		cable_overlay.color = get_cable_color()
		overlays += cable_overlay
	else if(cable_type == /obj/structure/cable/extra_insulated)
		overlays += "rcl_[coil_size]_hd"
	else
		overlays += "rcl_[coil_size]_hd_connected"

/obj/item/stack/cable_coil/rcl/update_icon_state()
	icon_state = "rcl"
	if(cable_merge_id == CABLE_LOW_POWER)
		inhand_icon_state = "rcl[amount ? "_[get_cable_color()]" : null]"
	else if(cable_type == /obj/structure/cable/extra_insulated)
		inhand_icon_state = "rcl[amount ?  "_hd" : null]"
	else
		inhand_icon_state = "rcl[amount ? "_hd_connected" : null]"

/obj/item/stack/cable_coil/rcl/update_name()
	. = ..()
	name = initial(name)

/obj/item/stack/cable_coil/rcl/proc/is_empty(mob/user, loud = 1)
	refresh_icon(user)
	if(!get_amount())
		if(loud)
			to_chat(user, SPAN_WARNING("The last of the cables unreel from [src]!"))
		return TRUE
	return FALSE

/obj/item/stack/cable_coil/rcl/dropped(mob/wearer)
	..()
	active = FALSE
	last = null

/obj/item/stack/cable_coil/rcl/activate_self(mob/user)
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

/obj/item/stack/cable_coil/rcl/on_mob_move(direct, mob/user)
	if(active && isturf(user.loc))
		trigger(user)

/obj/item/stack/cable_coil/rcl/proc/trigger(mob/user)
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

			cable_join(last, user)
			if(is_empty(user))
				return //If we've run out, display message and exit

		else
			last = null
	last = place_turf(get_turf(loc), user, turn(user.dir, 180))
	is_empty(user) //If we've run out, display message

/obj/item/stack/cable_coil/rcl/empty/Initialize(mapload)
	..()
	use(RCL_MAX_SPOOL_SIZE, FALSE)
	refresh_icon()

/obj/item/stack/cable_coil/rcl/AltClick(mob/living/user)
	return

/obj/item/stack/cable_coil/rcl/update_wclass()
	return

/obj/item/stack/cable_coil/rcl/robot
	name = "robotic rapid cable layer (RRCL)"
	desc = "A Rapid Cable Layer used to hold a spool of cable for engineering and construction robots."
	energy_type = /datum/robot_storage/material/cable
	is_cyborg = TRUE
	/// Tells us if we're laying basic or insulated cable.
	var/heavy_mode = FALSE

// update_icon() refuses to add the cable overlay on Initialize(), I'm convinced it's an issue with energy stacks.
// Energy stacks cannot be avoided because the icon of a stack refuses to render otherwise for reasons beyond my comprehension.
/obj/item/stack/cable_coil/rcl/robot/Initialize(mapload)
	..()
	var/image/cable_overlay = image('icons/obj/rcl.dmi', icon_state = "rcl_full")
	cable_overlay.color = spool_color
	overlays += cable_overlay

/obj/item/stack/cable_coil/rcl/robot/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("[src] is currently dispensing [heavy_mode ? "<b>heavy duty cable</b>" : "<b>standard cable</b>"].")
	. += SPAN_NOTICE("<b>Alt-Click</b> to swap between laying <b>standard</b> and <b>heavy duty</b> cable.")
	. += SPAN_NOTICE("<b>Ctrl-Click</b> to [heavy_mode ? "toggle cable connectivity" : "select cable color"].")

/obj/item/stack/cable_coil/rcl/robot/screwdriver_act(mob/user, obj/item/I)
	return

/obj/item/stack/cable_coil/rcl/robot/AltClick(mob/user, modifiers)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(heavy_mode)
		cable_type = /obj/structure/cable
		cable_merge_id = CABLE_LOW_POWER
		spool_color = "red"
	else
		cable_type = /obj/structure/cable/extra_insulated
		cable_merge_id = CABLE_HIGH_POWER
		spool_color = null
	heavy_mode = !heavy_mode
	to_chat(user, SPAN_NOTICE("You start dispensing [heavy_mode ? "heavy-duty cable" : "standard cable"]."))
	refresh_icon()

/obj/item/stack/cable_coil/rcl/robot/CtrlClick(mob/user, modifiers)
	if(!heavy_mode)
		var/new_cable_color = tgui_input_list(user, "Pick a cable color.", "Cable Color", list("pink","red","orange","yellow","green","blue","cyan","white"))
		if(!new_cable_color)
			return

		to_chat(user, SPAN_NOTICE("[src] is now dispensing [new_cable_color] cable."))
		cable_color(new_cable_color)
	else
		if(cable_type == /obj/structure/cable/extra_insulated/pre_connect)
			cable_type = /obj/structure/cable/extra_insulated
			to_chat(user, SPAN_NOTICE("[src] is now dispensing closed-connection heavy duty cable"))
		else
			cable_type = /obj/structure/cable/extra_insulated/pre_connect
			to_chat(user, SPAN_NOTICE("[src] is now dispensing open-connection heavy duty cable"))

	refresh_icon()
