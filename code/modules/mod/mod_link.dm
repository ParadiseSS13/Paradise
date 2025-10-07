/proc/make_link_visual_generic(datum/mod_link/mod_link, proc_path)
	var/mob/living/user = mod_link.get_user_callback.Invoke()
	var/obj/effect/overlay/link_visual = new()
	link_visual.name = "holocall ([mod_link.id])"
	link_visual.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	link_visual.appearance_flags |= KEEP_TOGETHER
	link_visual.makeHologram(0.5)
	mod_link.visual_overlays = user.overlays
	link_visual.add_overlay(mod_link.visual_overlays)
	mod_link.visual = link_visual
	mod_link.holder.RegisterSignals(user, list(COMSIG_CARBON_APPLY_OVERLAY, COMSIG_CARBON_REMOVE_OVERLAY), proc_path)
	return link_visual

/// Makes this atom look like a "hologram"
/// So transparent, blue, with a scanline and an emissive glow
/// This is acomplished using a combination of filters and render steps/overlays
/// The degree of the opacity is optional, based off the opacity arg (0 -> 1)
/atom/proc/makeHologram(opacity = 0.5)
	// First, we'll make things blue (roughly) and sorta transparent
	add_filter("HOLO: Color and Transparent", 1, color_matrix_filter(rgb(125, 180, 225, opacity * 255)))
	// Now we're gonna do a scanline effect
	// Gonna take this atom and give it a render target, then use it as a source for a filter
	// (We use an atom because it seems as if setting render_target on an MA is just invalid. I hate this engine)
	var/atom/movable/scanline = new(null)
	scanline.icon = 'icons/effects/effects.dmi'
	scanline.icon_state = "scanline"
	scanline.appearance_flags |= RESET_TRANSFORM
	// * so it doesn't render
	var/static/uid_scan = 0
	scanline.render_target = "*HoloScanline [uid_scan]"
	uid_scan++
	// Now we add it as a filter, and overlay the appearance so the render source is always around
	add_filter("HOLO: Scanline", 2, alpha_mask_filter(render_source = scanline.render_target))
	add_overlay(scanline)
	qdel(scanline)
	// And let's make the sucker emissive, so it glows in the dark
	if(!render_target)
		var/static/uid = 0
		render_target = "HOLOGRAM [uid]"
		uid++

/proc/get_link_visual_generic(datum/mod_link/mod_link, atom/movable/visuals, proc_path)
	var/mob/living/user = mod_link.get_user_callback.Invoke()
	playsound(mod_link.holder, 'sound/machines/terminal_processing.ogg', 50, TRUE)
	visuals.add_overlay(mutable_appearance('icons/effects/effects.dmi', "static_base", ABOVE_NORMAL_TURF_LAYER))
	visuals.add_overlay(mutable_appearance('icons/effects/effects.dmi', "modlink", ABOVE_ALL_MOB_LAYER))
	visuals.add_filter("crop_square", 1, alpha_mask_filter(icon = icon('icons/effects/effects.dmi', "modlink_filter")))
	visuals.maptext_height = 6
	visuals.alpha = 0
	user.vis_contents += visuals
	visuals.forceMove(user)
	animate(visuals, 0.5 SECONDS, alpha = 255)
	var/datum/callback/setdir_callback = CALLBACK(mod_link.holder, proc_path)
	setdir_callback.Invoke(user, user.dir, user.dir)
	mod_link.holder.RegisterSignal(mod_link.holder.loc, COMSIG_ATOM_DIR_CHANGE, proc_path)

/proc/delete_link_visual_generic(datum/mod_link/mod_link)
	var/mob/living/user = mod_link.get_user_callback.Invoke()
	playsound(mod_link.get_other().holder, 'sound/machines/terminal_processing.ogg', 50, TRUE, -1)
	mod_link.holder.UnregisterSignal(user, list(COMSIG_CARBON_APPLY_OVERLAY, COMSIG_CARBON_REMOVE_OVERLAY, COMSIG_ATOM_DIR_CHANGE))
	QDEL_NULL(mod_link.visual)

/proc/on_user_set_dir_generic(datum/mod_link/mod_link, newdir)
	var/atom/other_visual = mod_link.get_other().visual
	if(!newdir) // can sometimes be null or 0
		return
	other_visual.setDir(SOUTH)
	other_visual.pixel_x = 0
	other_visual.pixel_y = 0
	var/matrix/new_transform = matrix()
	if(newdir & NORTH)
		other_visual.pixel_y = 13
		other_visual.layer = BELOW_MOB_LAYER
	if(newdir & SOUTH)
		other_visual.pixel_y = -24
		other_visual.layer = ABOVE_ALL_MOB_LAYER
		new_transform.Scale(-1, 1)
		new_transform.Translate(-1, 0)
	if(newdir & EAST)
		other_visual.pixel_x = 14
		other_visual.layer = BELOW_MOB_LAYER
		new_transform.Shear(0.5, 0)
		new_transform.Scale(0.65, 1)
	if(newdir & WEST)
		other_visual.pixel_x = -14
		other_visual.layer = BELOW_MOB_LAYER
		new_transform.Shear(-0.5, 0)
		new_transform.Scale(0.65, 1)
	other_visual.transform = new_transform

/obj/item/mod/control/proc/can_call()
	return get_charge() && wearer && wearer.stat < DEAD

/obj/item/mod/control/proc/make_link_visual()
	return make_link_visual_generic(mod_link, PROC_REF(on_overlay_change))

/obj/item/mod/control/proc/get_link_visual(atom/movable/visuals)
	return get_link_visual_generic(mod_link, visuals, PROC_REF(on_wearer_set_dir))

/obj/item/mod/control/proc/delete_link_visual()
	return delete_link_visual_generic(mod_link)

/obj/item/mod/control/hear_talk(mob/living/M, list/message_pieces)
	. = ..()
	if(bag)
		for(var/obj/object in bag)
			object.hear_talk(M, message_pieces)

	if(M != wearer || !mod_link.visual)
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.voice != M.real_name)
			mod_link.visual.name = H.voice
		else
			mod_link.visual.name = H.name
	else
		mod_link.visual.name = M.name
	mod_link.visual.atom_say(capitalize(multilingual_to_message(message_pieces)))

/obj/item/mod/control/proc/on_overlay_change(atom/source, cache_index, overlay)
	SIGNAL_HANDLER // COMSIG_CARBON_APPLY_OVERLAY, COMSIG_CARBON_REMOVE_OVERLAY
	addtimer(CALLBACK(src, PROC_REF(update_link_visual)), 0.2 SECONDS, TIMER_UNIQUE)

/obj/item/mod/control/proc/update_link_visual()
	if(QDELETED(mod_link.link_call))
		return
	mod_link.visual.cut_overlay(mod_link.visual_overlays)
	mod_link.visual_overlays = wearer.overlays
	mod_link.visual.add_overlay(mod_link.visual_overlays)

/obj/item/mod/control/proc/on_wearer_set_dir(atom/source, dir, newdir)
	SIGNAL_HANDLER // COMSIG_ATOM_DIR_CHANGE
	on_user_set_dir_generic(mod_link, newdir || SOUTH)

/obj/item/clothing/neck/link_scryer
	name = "\improper MODlink scryer"
	desc = "An intricate piece of machinery that creates a holographic video call with another MODlink-compatible device. Essentially a video necklace."
	icon_state = "modlink"
	actions_types = list(/datum/action/item_action/call_link)
	/// The installed power cell.
	var/obj/item/stock_parts/cell/cell
	/// The MODlink datum we operate.
	var/datum/mod_link/mod_link
	/// Initial frequency of the MODlink.
	var/starting_frequency = MODLINK_FREQ_NANOTRASEN
	/// An additional name tag for the scryer, seen as "MODlink scryer - [label]"
	var/label

/obj/item/clothing/neck/link_scryer/Initialize(mapload)
	. = ..()
	mod_link = new(
		src,
		starting_frequency,
		CALLBACK(src, PROC_REF(get_user)),
		CALLBACK(src, PROC_REF(can_call)),
		CALLBACK(src, PROC_REF(make_link_visual)),
		CALLBACK(src, PROC_REF(get_link_visual)),
		CALLBACK(src, PROC_REF(delete_link_visual))
	)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/neck/link_scryer/Destroy()
	QDEL_NULL(cell)
	QDEL_NULL(mod_link)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/neck/link_scryer/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>The battery charge reads [cell.percent()]%. Use a <b>Screwdriver</b> to remove it.</span>"
	else
		. += "<span class='notice'>It is missing a battery, one can be installed by clicking with a power cell on it.</span>"
	. += "<span class='notice'>The MODlink ID is [mod_link.id], frequency is [mod_link.frequency || "unset"]. <b>Use</b> a multitool to copy/imprint frequency.</span>"
	. += "<span class='notice'>Use in hand to set name.</span>"

/obj/item/clothing/neck/link_scryer/equipped(mob/living/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_NECK)
		mod_link?.end_call()

/obj/item/clothing/neck/link_scryer/dropped(mob/living/user)
	. = ..()
	mod_link?.end_call()

/obj/item/clothing/neck/link_scryer/attack_self__legacy__attackchain(mob/user)
	var/new_label = reject_bad_text(tgui_input_text(user, "Change the visible name", "Set Name", label, MAX_NAME_LEN))
	if(!user.is_holding(src))
		return
	if(!new_label)
		to_chat(user, "<span class='warning'>That name is invalid!</span>")
		return
	label = new_label
	to_chat(user, "<span class='notice'>You set the name as [label].</span>")
	update_appearance(UPDATE_NAME)


/obj/item/clothing/neck/link_scryer/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	var/obj/item/linked_thing = locateUID(M.buffer_uid)

	if(!linked_thing)
		to_chat(user, "<span class='notice'>You save the frequency of [src] to the buffer.</span>")
		M.buffer_uid = UID()
		return TRUE
	if(ismodcontrol(linked_thing))
		var/obj/item/mod/control/chosen_control = linked_thing
		var/response = tgui_alert(user, "Would you like to copy the frequency to the multitool or imprint the frequency to [src]?", "MODlink Frequency", list("Copy", "Imprint"))
		if(!user.is_holding(I))
			return FALSE
		switch(response)
			if("Copy")
				to_chat(user, "<span class='notice'>You save the frequency of [src] to the buffer.</span>")
				M.buffer_uid = UID()
				return TRUE
			if("Imprint")
				mod_link.frequency = chosen_control.mod_link.frequency
				to_chat(user, "<span class='notice'>You imprint the frequency to [src].</span>")
				return TRUE
	else
		var/obj/item/clothing/neck/link_scryer/chosen_scryer = linked_thing
		var/response = tgui_alert(user, "Would you like to copy the frequency to the multitool or imprint the frequency to [src]?", "MODlink Frequency", list("Copy", "Imprint"))
		if(!user.is_holding(I))
			return FALSE
		switch(response)
			if("Copy")
				to_chat(user, "<span class='notice'>You save the frequency of [src] to the buffer.</span>")
				M.buffer_uid = UID()
				return TRUE
			if("Imprint")
				mod_link.frequency = chosen_scryer.mod_link.frequency
				to_chat(user, "<span class='notice'>You imprint the frequency to [src].</span>")
				return TRUE

/obj/item/clothing/neck/link_scryer/get_cell()
	return cell

/obj/item/clothing/neck/link_scryer/process()
	if(!mod_link.link_call)
		return
	cell.use(50)

/obj/item/clothing/neck/link_scryer/attackby__legacy__attackchain(obj/item/O, mob/user, params)
	. = ..()
	if(cell || !istype(O, /obj/item/stock_parts/cell))
		return
	if(!user.drop_item())
		to_chat(user, "<span class='warning'>[O] is stuck to your hand!</span>")
		return
	O.forceMove(src)
	cell = O
	to_chat(user, "<span class='notice'>You load [O] into [src].</span>")

/obj/item/clothing/neck/link_scryer/update_name(updates)
	. = ..()
	name = "[initial(name)][label ? " - [label]" : ""]"

/obj/item/clothing/neck/link_scryer/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == cell)
		cell = null

/obj/item/clothing/neck/link_scryer/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!cell)
		return
	to_chat(user, "<span class='notice'>You remove [cell] from [src].</span>")
	user.put_in_hands(cell)
	return

/obj/item/clothing/neck/link_scryer/ui_action_click(mob/user)
	if(mod_link.link_call)
		mod_link.end_call()
	else
		call_link(user, mod_link)

/obj/item/clothing/neck/link_scryer/proc/get_user()
	var/mob/living/carbon/human/user = loc
	return istype(user) && user.neck == src ? user : null

/obj/item/clothing/neck/link_scryer/proc/can_call()
	var/mob/living/user = loc
	return istype(user) && cell?.charge && user.stat < DEAD

/obj/item/clothing/neck/link_scryer/proc/make_link_visual()
	var/mob/living/user = mod_link.get_user_callback.Invoke()
	user.update_inv_neck()
	return make_link_visual_generic(mod_link, PROC_REF(on_overlay_change))

/obj/item/clothing/neck/link_scryer/proc/get_link_visual(atom/movable/visuals)
	return get_link_visual_generic(mod_link, visuals, PROC_REF(on_user_set_dir))

/obj/item/clothing/neck/link_scryer/proc/delete_link_visual()
	var/mob/living/user = mod_link.get_user_callback.Invoke()
	if(!QDELETED(user))
		user.update_inv_neck()
	return delete_link_visual_generic(mod_link)

/obj/item/clothing/neck/link_scryer/hear_talk(mob/living/M, list/message_pieces)
	. = ..()
	if(M != loc || !mod_link.visual)
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.voice != M.real_name)
			mod_link.visual.name = H.voice
		else
			mod_link.visual.name = H.name
	else
		mod_link.visual.name = M.name
	mod_link.visual.atom_say(capitalize(multilingual_to_message(message_pieces)))

/obj/item/clothing/neck/link_scryer/proc/on_overlay_change(atom/source, cache_index, overlay)
	SIGNAL_HANDLER // COMSIG_CARBON_APPLY_OVERLAY, COMSIG_CARBON_REMOVE_OVERLAY
	addtimer(CALLBACK(src, PROC_REF(update_link_visual)), 0.2 SECONDS, TIMER_UNIQUE)

/obj/item/clothing/neck/link_scryer/proc/update_link_visual()
	if(QDELETED(mod_link.link_call))
		return
	var/mob/living/user = loc
	mod_link.visual.cut_overlay(mod_link.visual_overlays)
	mod_link.visual_overlays = user.overlays
	mod_link.visual.add_overlay(mod_link.visual_overlays)

/obj/item/clothing/neck/link_scryer/proc/on_user_set_dir(atom/source, dir, newdir)
	SIGNAL_HANDLER // COMSIG_ATOM_DIR_CHANGE
	on_user_set_dir_generic(mod_link, newdir || SOUTH)

/obj/item/clothing/neck/link_scryer/loaded/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/cell/high(src)

/obj/item/clothing/neck/link_scryer/loaded/theta
	starting_frequency = MODLINK_FREQ_THETA

/// A MODlink datum, used to handle unique functions that will be used in the MODlink call.
/datum/mod_link
	/// Generic name for multitool buffers.
	var/name = "MODlink"
	/// The frequency of the MODlink. You can only call other MODlinks on the same frequency.
	var/frequency
	/// The unique ID of the MODlink.
	var/id = ""
	/// The atom that holds the MODlink.
	var/atom/movable/holder
	/// A reference to the visuals generated by the MODlink.
	var/atom/movable/visual
	/// A list of all overlays of the user, copied everytime they have an overlay change.
	var/list/visual_overlays = list()
	/// A reference to the call between two MODlinks.
	var/datum/mod_link_call/link_call
	/// A callback that returns the user of the MODlink.
	var/datum/callback/get_user_callback
	/// A callback that returns whether the MODlink can currently call.
	var/datum/callback/can_call_callback
	/// A callback that returns the visuals of the MODlink.
	var/datum/callback/make_visual_callback
	/// A callback that receives the visuals of the other MODlink.
	var/datum/callback/get_visual_callback
	/// A callback that deletes the visuals of the MODlink.
	var/datum/callback/delete_visual_callback

/datum/mod_link/New(
	atom/holder,
	frequency,
	datum/callback/get_user_callback,
	datum/callback/can_call_callback,
	datum/callback/make_visual_callback,
	datum/callback/get_visual_callback,
	datum/callback/delete_visual_callback
)
	var/attempts = 0
	var/digits_to_make = 3
	do
		if(attempts == 10)
			attempts = 0
			digits_to_make++
		id = ""
		for(var/i in 1 to digits_to_make)
			id += num2text(rand(0, 9))
		attempts++
	while(GLOB.mod_link_ids[id])
	GLOB.mod_link_ids[id] = src
	src.frequency = frequency
	src.holder = holder
	src.get_user_callback = get_user_callback
	src.can_call_callback = can_call_callback
	src.make_visual_callback = make_visual_callback
	src.get_visual_callback = get_visual_callback
	src.delete_visual_callback = delete_visual_callback
	RegisterSignal(holder, COMSIG_PARENT_QDELETING, PROC_REF(on_holder_delete))

/datum/mod_link/Destroy()
	GLOB.mod_link_ids -= id
	if(link_call)
		end_call()
	get_user_callback = null
	make_visual_callback = null
	get_visual_callback = null
	delete_visual_callback = null
	return ..()

/datum/mod_link/proc/get_other()
	RETURN_TYPE(/datum/mod_link)
	if(!link_call)
		return
	return link_call.link_caller == src ? link_call.link_receiver : link_call.link_caller

/datum/mod_link/proc/call_link(datum/mod_link/called, mob/user)
	if(!frequency)
		return
	if(!istype(called))
		to_chat(user, "<span class='warning'>That target is invalid!</span>")
		return
	var/mob/living/link_user = get_user_callback.Invoke()
	if(!link_user)
		return
	if(HAS_TRAIT(link_user, TRAIT_IN_CALL))
		to_chat(user, "<span class='warning'>You are already calling someone!</span>")
		return
	var/mob/living/link_target = called.get_user_callback.Invoke()
	if(!link_target)
		to_chat(user, "<span class='warning'>That target is invalid!</span>")
		return
	if(HAS_TRAIT(link_target, TRAIT_IN_CALL))
		to_chat(user, "<span class='warning'>The person you are calling is already in a call!</span>")
		return
	if(!can_call_callback.Invoke() || !called.can_call_callback.Invoke())
		to_chat(user, "<span class='warning'>You are unable to call at this time!</span>")
		return
	link_target.playsound_local(get_turf(called.holder), 'sound/weapons/ring.ogg', 15, TRUE)
	var/atom/movable/screen/alert/modlink_call/alert = link_target.throw_alert("[UID()]_modlink", /atom/movable/screen/alert/modlink_call)
	alert.desc = "[holder] ([id]) is calling you! Left-click this to accept the call. Right-click to deny it."
	alert.link_caller_uid = UID()
	alert.link_receiver_uid = called.UID()
	alert.user_uid = user.UID()

/datum/mod_link/proc/end_call()
	QDEL_NULL(link_call)

/datum/mod_link/proc/on_holder_delete(atom/source)
	SIGNAL_HANDLER
	qdel(src)

/// A MODlink call datum, used to handle the call between two MODlinks.
/datum/mod_link_call
	/// The MODlink that is calling.
	var/datum/mod_link/link_caller
	/// The MODlink that is being called.
	var/datum/mod_link/link_receiver

/datum/mod_link_call/New(datum/mod_link/link_caller, datum/mod_link/link_receiver)
	link_caller.link_call = src
	link_receiver.link_call = src
	src.link_caller = link_caller
	src.link_receiver = link_receiver
	var/mob/living/caller_mob = link_caller.get_user_callback.Invoke()
	ADD_TRAIT(caller_mob, TRAIT_IN_CALL, UID())
	var/mob/living/receiver_mob = link_receiver.get_user_callback.Invoke()
	ADD_TRAIT(receiver_mob, TRAIT_IN_CALL, UID())
	make_visuals()
	START_PROCESSING(SSprocessing, src)

/datum/mod_link_call/Destroy()
	var/mob/living/caller_mob = link_caller.get_user_callback.Invoke()
	if(!QDELETED(caller_mob))
		REMOVE_TRAIT(caller_mob, TRAIT_IN_CALL, UID())
	var/mob/living/receiver_mob = link_receiver.get_user_callback.Invoke()
	if(!QDELETED(receiver_mob))
		REMOVE_TRAIT(receiver_mob, TRAIT_IN_CALL, UID())
	STOP_PROCESSING(SSprocessing, src)
	clear_visuals()
	link_caller.link_call = null
	link_receiver.link_call = null
	return ..()

/datum/mod_link_call/process(seconds_per_tick)
	if(can_continue_call())
		return
	qdel(src)

/datum/mod_link_call/proc/can_continue_call()
	return link_caller.frequency == link_receiver.frequency && link_caller.can_call_callback.Invoke() && link_receiver.can_call_callback.Invoke()

/datum/mod_link_call/proc/make_visuals()
	var/caller_visual = link_caller.make_visual_callback.Invoke()
	var/receiver_visual = link_receiver.make_visual_callback.Invoke()
	link_caller.get_visual_callback.Invoke(receiver_visual)
	link_receiver.get_visual_callback.Invoke(caller_visual)

/datum/mod_link_call/proc/clear_visuals()
	link_caller.delete_visual_callback.Invoke()
	link_receiver.delete_visual_callback.Invoke()

/proc/call_link(mob/user, datum/mod_link/calling_link)
	if(!calling_link.frequency)
		to_chat(user, "<span class='warning'>The frequency isn't set!</span>")
		return
	var/list/callers = list()
	for(var/id in GLOB.mod_link_ids)
		var/datum/mod_link/link = GLOB.mod_link_ids[id]
		if(link.frequency != calling_link.frequency)
			continue
		if(link == calling_link)
			continue
		if(!link.can_call_callback.Invoke())
			continue
		callers["[link.holder] ([id])"] = id
	if(!length(callers))
		to_chat(user, "<span class='notice'>There are no targets on freq [calling_link.frequency].</span>")
		return
	var/chosen_link = tgui_input_list(user, "Choose ID to call from [calling_link.frequency] frequency", "MODlink", callers)
	if(!chosen_link)
		return
	calling_link.call_link(GLOB.mod_link_ids[callers[chosen_link]], user)

/atom/movable/screen/alert/modlink_call
	name = "MODlink Call Incoming"
	desc = "Someone is calling you! Left-click this to accept the call. Alt-click to deny it."
	icon_state = "called"
	timeout = 10 SECONDS
	var/end_message = "call timed out!"
	/// A UID to the MODlink that is calling.
	var/link_caller_uid
	/// A UID to the MODlink that is being called.
	var/link_receiver_uid
	/// A UID to the mob that is calling.
	var/user_uid

/atom/movable/screen/alert/modlink_call/Click(location, control, params)
	. = ..()
	if(usr != owner)
		return
	var/datum/mod_link/link_caller = locateUID(link_caller_uid)
	var/datum/mod_link/link_receiver = locateUID(link_receiver_uid)
	if(!link_caller || !link_receiver)
		return
	if(link_caller.link_call || link_receiver.link_call)
		return
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, ALT_CLICK))
		end_message = "The call was denied!"
		owner.clear_alert("[link_caller.UID()]_modlink")
		return
	end_message = "The call was accepted!"
	new /datum/mod_link_call(link_caller, link_receiver)
	owner.clear_alert("[link_caller.UID()]_modlink")

/atom/movable/screen/alert/modlink_call/Destroy()
	var/mob/living/user = locateUID(user_uid)
	var/datum/mod_link/link_caller = locateUID(link_caller_uid)
	if(!user || !link_caller)
		return ..()
	to_chat(user, "<span class='notice'>[end_message]</span>")
	return ..()
