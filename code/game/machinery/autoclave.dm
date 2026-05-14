/obj/machinery/autoclave
	name = "autoclave"
	desc = "A pressurized chamber used to eliminate bacteria."

	icon = 'icons/obj/machines/autoclave.dmi'
	base_icon_state = "autoclave"
	icon_state = "autoclave"

	active_power_consumption = 5000
	idle_power_consumption = 5

	/// Time to sanitize the item inside
	var/sanitize_time = 30 SECONDS

	/// Alpha mask for the contained item sprite
	var/static/alpha_mask_filter

	/// Is the door open
	var/is_open = FALSE

	/// Sound to play
	var/datum/looping_sound/kitchen/microwave/soundloop

	/// Timer ID for the actual work. Can be used to check if the machine is "busy"
	var/work_timer_id

	/// What is currently inside the autoclave
	var/obj/item/occupant
	/// Visual
	var/obj/effect/occupant_overlay

/obj/machinery/autoclave/Initialize(mapload)
	. = ..()
	soundloop = new(src)
	alpha_mask_filter ||= filter(type = "alpha", icon = icon(icon, "alphamask"))
	update_appearance(UPDATE_OVERLAYS)
	// Stock parts
	component_parts = list()
	component_parts += new /obj/item/circuitboard/autoclave(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stack/sheet/glass(src)
	RefreshParts()

/obj/machinery/autoclave/Destroy()
	QDEL_NULL(soundloop)
	if(occupant)
		occupant.forceMove(get_turf(src))
	return ..()

/obj/machinery/autoclave/examine(mob/user, infix, suffix)
	. = ..()
	. += SPAN_NOTICE("You can open or close [src] with an empty hand.")
	. += SPAN_NOTICE("You can turn on [src] if it's closed or take an item out of [src] if it is open with by alt-clicking.")
	if(occupant)
		. += SPAN_INFO("There is \a [occupant] inside.")
	if(emagged)
		. += SPAN_WARNING("A bright red radiation warning light blinks on the display.")

/obj/machinery/autoclave/RefreshParts()
	. = ..()
	var/average_level = 0
	for(var/obj/item/stock_parts/component in component_parts)
		average_level += component.rating
	average_level = average_level / 2
	// Update our values
	sanitize_time = 30 SECONDS / average_level

/obj/machinery/autoclave/emag_act(mob/user)
	. = ..()
	if(emagged)
		return
	to_chat(user, SPAN_WARNING("You short out [src]'s radiation controller!"))
	do_sparks(2, 0, src)
	emagged = TRUE

/obj/machinery/autoclave/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "autoclave-open"
		return
	icon_state = "autoclave"

/obj/machinery/autoclave/update_overlays()
	. = ..()
	overlays.Cut()
	if(is_open)
		if(occupant)
			var/mutable_appearance/content_copy = new /mutable_appearance(occupant)
			content_copy.layer = FLOAT_LAYER
			content_copy.plane = FLOAT_PLANE
			content_copy.pixel_x = 0
			content_copy.pixel_y = 0
			content_copy.appearance_flags |= KEEP_TOGETHER
			content_copy.filters += alpha_mask_filter
			. += content_copy
		. += image(icon, "door-open")
	else
		. += image(icon, "door-closed")

	if((stat & NOPOWER) || (stat & BROKEN))
		. += image(icon, "lights-off")
	else if(work_timer_id)
		. += image(icon, "lights-green")
		. += emissive_appearance(icon, "lights-green-emi", alpha = 90)
	else
		. += image(icon, "lights-red")
		. += emissive_appearance(icon, "lights-red-emi", alpha = 90)

/obj/machinery/autoclave/proc/toggle_light()
	if(power_state == ACTIVE_POWER_USE)
		light_color = "#DEEFFF"
		light_power = 0.8
		light_range = 2.5
		return
	light_color = "#FFFFFF"
	light_power = 0
	light_range = 0

/obj/machinery/autoclave/AltClick(mob/user, modifiers)
	if(!Adjacent(user))
		return

	if(is_open && occupant)
		add_fingerprint(user)
		user.put_in_active_hand(occupant)
		to_chat(user, SPAN_NOTICE("You take [occupant] out of [src]."))
		occupant = null
		update_appearance(UPDATE_OVERLAYS)

	else if(!is_open && try_start())
		add_fingerprint(user)

/obj/machinery/autoclave/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!Adjacent(user))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/card/emag))
		return ..()

	if(user.a_intent != INTENT_HELP)
		return ..()

	if(!is_open)
		to_chat(user, SPAN_WARNING("The door on [src] is closed!"))
		return ITEM_INTERACT_COMPLETE

	if(used.w_class > WEIGHT_CLASS_NORMAL)
		to_chat(user, SPAN_WARNING("[used] is too big to fit in [src]."))
		return ITEM_INTERACT_COMPLETE

	if(used.flags & NODROP || !user.transfer_item_to(used, src))
		to_chat(user, SPAN_WARNING("[used] is stuck to your hand!"))
		return ITEM_INTERACT_COMPLETE
	if(occupant)
		user.put_in_active_hand(occupant)
		to_chat(user, SPAN_NOTICE("You swap [used] with [occupant] in [src]."))
	else
		to_chat(user, SPAN_NOTICE("You insert [used] into [src]."))
	occupant = used
	user.visible_message(SPAN_NOTICE("[user] places [used] into [src]."))
	update_appearance(UPDATE_OVERLAYS)
	return ITEM_INTERACT_COMPLETE

/obj/machinery/autoclave/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	if(work_timer_id)
		to_chat(user, SPAN_ALERT("[src] is busy. Please wait for completion of previous operation."))
		return
	default_deconstruction_screwdriver(user, "autoclave-open", "autoclave", I)
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/autoclave/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/autoclave/wrench_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	default_unfasten_wrench(user, I, 0)

/obj/machinery/autoclave/attack_hand(mob/user, params)
	if(.)
		return

	if(work_timer_id)
		to_chat(user, SPAN_WARNING("[src] is locked."))
		return TRUE

	toggle_open()

	return TRUE

/obj/machinery/autoclave/proc/try_start()
	if(work_timer_id || !occupant || panel_open)
		return FALSE

	soundloop.start()
	work_timer_id = addtimer(CALLBACK(src, PROC_REF(try_stop)), sanitize_time, TIMER_DELETE_ME | TIMER_STOPPABLE)
	change_power_mode(ACTIVE_POWER_USE)
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/machinery/autoclave/proc/try_stop()
	if(!work_timer_id)
		return FALSE

	if(occupant)
		sanitize()

	deltimer(work_timer_id)
	work_timer_id = null

	soundloop.stop()
	change_power_mode(IDLE_POWER_USE)
	update_appearance(UPDATE_OVERLAYS)
	toggle_light()
	return TRUE

/obj/machinery/autoclave/proc/sanitize()
	var/obj/item/I = occupant
	if(istype(I, /obj/item/holder))
		for(var/mob/M in src.contents)
			M.forceMove(get_turf(src))
			M.gib()
		qdel(occupant)
		occupant = null
		return
	var/list/stored_items = I.get_all_contents()
	var/mob_death = FALSE
	for(var/obj/item/holder/H in stored_items)
		for(var/mob/M in src.contents)
			M.forceMove(get_turf(src))
			M.gib()
		qdel(H)
		mob_death = TRUE
	if(mob_death)
		return
	for(var/obj/item/stored in stored_items)
		stored.germ_level = 0
		stored.clean_blood()
	I.germ_level = 0
	I.clean_blood()
	if(emagged)
		I.contaminate_atom(src, 150, BETA_RAD)

/obj/machinery/autoclave/proc/toggle_open()
	is_open = !is_open
	if(is_open)
		playsound(get_turf(src), 'sound/items/taperecorder/taperecorder_open.ogg', 30, TRUE)
	else
		playsound(get_turf(src), 'sound/items/taperecorder/taperecorder_close.ogg', 30, TRUE)
	update_appearance(UPDATE_OVERLAYS)
