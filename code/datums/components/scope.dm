///A component that allows players to use the item to zoom out. Mainly intended for firearms, but now works with other items too.
/datum/component/scope
	/// How far the view can be moved from the player. At 1, it can be moved by the player's view distance; other values scale linearly.
	var/range_modifier = 1
	/// Fullscreen object we use for tracking.
	var/atom/movable/screen/fullscreen/stretch/cursor_catcher/scope/tracker
	/// The owner of the tracker's ckey. For comparing with the current owner mob, in case the client has left it (e.g. ghosted).
	var/tracker_owner_ckey
	/// The method which we zoom in and out
	var/zoom_method = ZOOM_METHOD_ITEM_ACTION
	/// if not null, an item action will be added. Redundant if the mode is ZOOM_METHOD_RIGHT_CLICK or ZOOM_METHOD_WIELD.
	var/item_action_type
	/// Time to scope up, if you want the scope to take time to boot up. Used by the LWAP
	var/time_to_scope
	/// Flags for scoping. Check `code\__DEFINES\flags.dm`
	var/flags

/datum/component/scope/Initialize(range_modifier = 1, zoom_method = ZOOM_METHOD_ITEM_ACTION, item_action_type = /datum/action/zoom, time_to_scope = 0, flags)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.range_modifier = range_modifier
	src.zoom_method = zoom_method
	src.item_action_type = item_action_type
	src.time_to_scope = time_to_scope
	src.flags = flags


/datum/component/scope/Destroy(force)
	if(is_zoomed_in())
		stop_zooming(tracker.owner)
	return ..()

/datum/component/scope/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move)) //Checks for being removed for person, not mob movement
	if(zoom_method == ZOOM_METHOD_WIELD)
		RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_WIELDED), PROC_REF(on_wielded))
		RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_WIELDED), PROC_REF(on_unwielded))
	if(item_action_type)
		var/obj/item/parent_item = parent
		var/datum/action/scope = new item_action_type(parent)
		parent_item.actions += scope
		RegisterSignal(scope, COMSIG_ACTION_TRIGGER, PROC_REF(on_action_trigger))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	if(istype(parent, /obj/item/gun))
		RegisterSignal(parent, COMSIG_GUN_TRY_FIRE, PROC_REF(on_gun_fire))

/datum/component/scope/UnregisterFromParent()
	if(item_action_type)
		var/obj/item/parent_item = parent
		var/datum/action/scope = locate(item_action_type) in parent_item.actions
		parent_item.actions -= scope
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		SIGNAL_ADDTRAIT(TRAIT_WIELDED),
		SIGNAL_REMOVETRAIT(TRAIT_WIELDED),
		COMSIG_GUN_TRY_FIRE,
		COMSIG_PARENT_EXAMINE,
	))

/datum/component/scope/process()
	if(!tracker)
		STOP_PROCESSING(SSprojectiles, src)
		return
	var/mob/user_mob = tracker.owner
	var/client/user_client = user_mob.client
	if(!user_client)
		stop_zooming(user_mob)
		return
	tracker.calculate_params()
	animate(user_client, world.tick_lag, pixel_x = tracker.given_x, pixel_y = tracker.given_y)

/datum/component/scope/proc/on_move(atom/movable/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER // COMSIG_MOVABLE_MOVED

	if(!is_zoomed_in())
		return
	if(source.loc != tracker.owner) //Dropped.
		to_chat(tracker.owner, "<span class='warning'>[parent]'s scope is overloaded by movement and shuts down!</span>")
	stop_zooming(tracker.owner)

/datum/component/scope/proc/on_action_trigger(datum/action/source)
	SIGNAL_HANDLER // COMSIG_ACTION_TRIGGER
	var/obj/item/item = source.target
	var/mob/living/user = item.loc
	if(is_internal_organ(item))
		var/obj/item/organ/internal/O = item
		user = O.owner
	if(is_zoomed_in())
		stop_zooming(user)
	else
		INVOKE_ASYNC(src, PROC_REF(zoom), user)

/datum/component/scope/proc/on_wielded(obj/item/source, trait)
	SIGNAL_HANDLER // SIGNAL_ADDTRAIT(TRAIT_WIELDED)
	var/mob/living/user = source.loc
	INVOKE_ASYNC(src, PROC_REF(zoom), user)

/datum/component/scope/proc/on_unwielded(obj/item/source, trait)
	SIGNAL_HANDLER // SIGNAL_REMOVETRAIT(TRAIT_WIELDED)
	var/mob/living/user = source.loc
	stop_zooming(user)

/datum/component/scope/proc/on_gun_fire(obj/item/gun/source, mob/living/user, atom/target, flag, params)
	SIGNAL_HANDLER // COMSIG_GUN_TRY_FIRE
	if(!tracker?.given_turf || target == get_target(tracker.given_turf))
		return NONE
	INVOKE_ASYNC(source, TYPE_PROC_REF(/obj/item, afterattack__legacy__attackchain), get_target(tracker.given_turf), user)
	return COMPONENT_CANCEL_GUN_FIRE

/datum/component/scope/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER // COMSIG_PARENT_EXAMINE

	var/scope = istype(parent, /obj/item/gun) ? "scope in" : "zoom out"
	switch(zoom_method)
		if(ZOOM_METHOD_WIELD)
			examine_list += "<span class='notice'>You can [scope] by wielding it with both hands.</span>"

/**
 * We find and return the best target to hit on a given turf.
 *
 * Arguments:
 * * target_turf: The turf we are looking for targets on.
*/
/datum/component/scope/proc/get_target(turf/target_turf)
	var/list/non_dense_targets = list()
	for(var/atom/movable/possible_target in target_turf)
		if(possible_target.layer <= PROJECTILE_HIT_THRESHHOLD_LAYER)
			continue
		if(possible_target.invisibility > tracker.owner.see_invisible)
			continue
		if(!possible_target.mouse_opacity)
			continue
		if(iseffect(possible_target))
			continue
		if(ismob(possible_target))
			if(possible_target == tracker.owner)
				continue
			return possible_target
		if(!possible_target.density)
			non_dense_targets += possible_target
			continue
		return possible_target
	if(length(non_dense_targets))
		return non_dense_targets[1]
	return target_turf

/**
 * We start zooming by adding our tracker overlay and starting our processing.
 *
 * Arguments:
 * * user: The mob we are starting zooming on.
*/
/datum/component/scope/proc/zoom(mob/user)
	if(isnull(user.client))
		return
	if(HAS_TRAIT(user, TRAIT_SCOPED))
		to_chat(user, "<span class='warning'>You are already zoomed in!</span>")
		return
	if((flags & SCOPE_TURF_ONLY) && !isturf(user.loc))
		to_chat(user, "<span class='warning'>There is not enough space to zoom in!</span>")
		return
	if((flags & SCOPE_NEED_ACTIVE_HAND) && user.get_active_hand() != parent)
		to_chat(user, "<span class='warning'>You need to hold [parent] in your active hand to zoom in!</span>")
		return
	if(time_to_scope)
		if(!do_after_once(user, time_to_scope, target = parent))
			return
	user.playsound_local(parent, 'sound/weapons/scope.ogg', 75, TRUE)
	tracker = user.overlay_fullscreen("scope", /atom/movable/screen/fullscreen/stretch/cursor_catcher/scope, istype(parent, /obj/item/gun))
	tracker.assign_to_mob(user, range_modifier)
	if(flags & SCOPE_MOVEMENT_CANCELS)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	if(flags & SCOPE_CLICK_MIDDLE)
		RegisterSignal(tracker, COMSIG_CLICK, PROC_REF(generic_click))
	tracker_owner_ckey = user.ckey
	if(user.is_holding(parent))
		RegisterSignals(user, list(COMSIG_CARBON_SWAP_HANDS, COMSIG_PARENT_QDELETING), PROC_REF(stop_zooming))
	else // The item is likely worn.
		RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(stop_zooming))
		var/static/list/capacity_signals = list(
			COMSIG_LIVING_STATUS_PARALYSE,
			COMSIG_LIVING_STATUS_STUN,
		)
		RegisterSignals(user, capacity_signals, PROC_REF(on_incapacitated))
	START_PROCESSING(SSprojectiles, src)
	ADD_TRAIT(user, TRAIT_SCOPED, "[UID()]")
	if(istype(parent, /obj/item/gun))
		var/obj/item/gun/G = parent
		G.on_scope_success(user)
	return TRUE

/datum/component/scope/proc/on_incapacitated(mob/living/source, amount = 0, ignore_canstun = FALSE)
	SIGNAL_HANDLER // COMSIG_LIVING_STATUS_PARALYSE, COMSIG_LIVING_STATUS_STUN

	if(amount > 0)
		stop_zooming(source)

/datum/component/scope/proc/generic_click(/obj/source, location, control, params)
	SIGNAL_HANDLER // COMSIG_CLICK
	INVOKE_ASYNC(tracker.owner, TYPE_PROC_REF(/mob, ClickOn), get_target(tracker.given_turf), params)

/**
 * We stop zooming, canceling processing, resetting stuff back to normal and deleting our tracker.
 *
 * Arguments:
 * * user: The mob we are canceling zooming on.
*/
/datum/component/scope/proc/stop_zooming(mob/user)
	SIGNAL_HANDLER // COMSIG_CARBON_SWAP_HANDS, COMSIG_PARENT_QDELETING

	if(!HAS_TRAIT(user, TRAIT_SCOPED))
		return

	STOP_PROCESSING(SSprojectiles, src)
	UnregisterSignal(user, list(
		COMSIG_LIVING_STATUS_PARALYSE,
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_CARBON_SWAP_HANDS,
		COMSIG_PARENT_QDELETING,
	))
	REMOVE_TRAIT(user, TRAIT_SCOPED, "[UID()]")

	user.playsound_local(parent, 'sound/weapons/scope.ogg', 75, TRUE, frequency = -1)
	user.clear_fullscreen("scope")

	// if the client has ended up in another mob, find that mob so we can fix their cursor
	var/mob/true_user
	if(user.ckey != tracker_owner_ckey)
		true_user = get_mob_by_ckey(tracker_owner_ckey)

	if(!isnull(true_user))
		user = true_user

	if(user.client)
		animate(user.client, 0.2 SECONDS, pixel_x = 0, pixel_y = 0)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	QDEL_NULL(tracker)
	tracker_owner_ckey = null
	if(istype(parent, /obj/item/gun))
		var/obj/item/gun/G = parent
		G.on_scope_end(user)

/datum/component/scope/proc/is_zoomed_in()
	return !!tracker

/atom/movable/screen/fullscreen/stretch/cursor_catcher/scope
	icon = 'icons/mob/screen_scope.dmi'
	icon_state = "scope"
	/// Multiplier for given_X an given_y.
	var/range_modifier = 1

/atom/movable/screen/fullscreen/stretch/cursor_catcher/scope/assign_to_mob(mob/new_owner, range_modifier)
	src.range_modifier = range_modifier
	return ..()

/atom/movable/screen/fullscreen/stretch/cursor_catcher/scope/Click(location, control, params)
	if(usr == owner)
		calculate_params()
		SEND_SIGNAL(src, COMSIG_CLICK, location, control, params)

	return ..()

/atom/movable/screen/fullscreen/stretch/cursor_catcher/scope/calculate_params()
	var/list/modifiers = params2list(mouse_params)
	var/icon_x = text2num(LAZYACCESS(modifiers, "vis-x"))
	if(isnull(icon_x))
		icon_x = text2num(LAZYACCESS(modifiers, "icon-x"))
	var/icon_y = text2num(LAZYACCESS(modifiers, "vis-y"))
	if(isnull(icon_y))
		icon_y = text2num(LAZYACCESS(modifiers, "icon-y"))
	given_x = round(range_modifier * (icon_x - view_list[1] * world.icon_size / 2))
	given_y = round(range_modifier * (icon_y - view_list[2] * world.icon_size / 2))
	given_turf = locate(owner.x + round(given_x / world.icon_size, 1), owner.y + round(given_y / world.icon_size, 1), owner.z)


/datum/action/zoom
	name = "Toggle Scope"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING
	button_icon_state = "sniper_zoom"
