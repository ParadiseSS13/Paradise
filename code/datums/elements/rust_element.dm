/**
 * Adding this element to an atom will have it automatically render an overlay.
 */
/datum/element/rust
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2
	/// The rust image itself, since the icon and icon state are only used as an argument
	var/image/rust_overlay

/datum/element/rust/Attach(atom/target, rust_icon = 'icons/effects/rust_overlay.dmi', rust_icon_state = "rust_default")
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	rust_overlay = image(rust_icon, "rust[rand(1, 6)]")
	ADD_TRAIT(target, TRAIT_RUSTY, "rusted_turf")
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_rust_overlay))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(handle_examine))
	RegisterSignal(target, COMSIG_INTERACT_TARGET, PROC_REF(on_interaction))
	RegisterSignal(target, COMSIG_TOOL_ATTACK, PROC_REF(welder_tool_act))
	// Unfortunately registering with parent sometimes doesn't cause an overlay update
	target.update_appearance()

/datum/element/rust/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(source, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(source, COMSIG_TOOL_ATTACK)
	UnregisterSignal(source, COMSIG_INTERACT_TARGET)
	REMOVE_TRAIT(source, TRAIT_RUSTY, "rusted_turf")
	source.cut_overlays()
	source.update_appearance()

/datum/element/rust/proc/handle_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER //COMSIG_PARENT_EXAMINE

	examine_list += "<span class='notice'>[source] is very rusty, you could probably <b>burn</b> it off.</span>"

/datum/element/rust/proc/apply_rust_overlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER //COMSIG_ATOM_UPDATE_OVERLAYS

	if(rust_overlay)
		overlays += rust_overlay

/// Because do_after sleeps we register the signal here and defer via an async call
/datum/element/rust/proc/welder_tool_act(atom/source, obj/item/item, mob/user)
	SIGNAL_HANDLER // COMSIG_TOOL_ATTACK

	INVOKE_ASYNC(src, PROC_REF(handle_tool_use), source, item, user)
	return COMPONENT_CANCEL_TOOLACT

/// We call this from secondary_tool_act because we sleep with do_after
/datum/element/rust/proc/handle_tool_use(atom/source, obj/item/item, mob/user)
	switch(item.tool_behaviour)
		if(TOOL_WELDER)
			if(!item.tool_start_check(source, user, amount=1))
				return
			to_chat(user, "<span class='notice'>You start burning off the rust...</span>")

			if(!item.use_tool(source, user, 5 SECONDS, volume = item.tool_volume))
				return
			to_chat(user, "<span class='notice'>You burn off the rust!</span>")
			Detach(source)
			return

/// Prevents placing floor tiles on rusted turf
/datum/element/rust/proc/on_interaction(datum/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER // COMSIG_INTERACT_TARGET
	if(istype(tool, /obj/item/stack/tile) || istype(tool, /obj/item/stack/rods) || istype(tool, /obj/item/rcd))
		to_chat(user, "<span class='warning'>[source] is too rusted to build on!</span>")
		return ITEM_INTERACT_COMPLETE

/// For rust applied by heretics (if that ever happens) / revenants
/datum/element/rust/heretic

/datum/element/rust/heretic/Attach(atom/target, rust_icon, rust_icon_state)
	. = ..()
	if(. == ELEMENT_INCOMPATIBLE)
		return .
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

/datum/element/rust/heretic/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_ENTERED)
	UnregisterSignal(source, COMSIG_ATOM_EXITED)
	for(var/obj/effect/glowing_rune/rune_to_remove in source)
		qdel(rune_to_remove)
	for(var/mob/living/victim in source)
		victim.remove_status_effect(STATUS_EFFECT_RUST_CORRUPTION)

/datum/element/rust/heretic/proc/on_entered(turf/source, atom/movable/entered, ...)
	SIGNAL_HANDLER

	if(!isliving(entered))
		return
	var/mob/living/victim = entered
	if(istype(victim, /mob/living/simple_animal/revenant))
		return
	victim.apply_status_effect(STATUS_EFFECT_RUST_CORRUPTION)

/datum/element/rust/heretic/proc/on_exited(turf/source, atom/movable/gone)
	SIGNAL_HANDLER
	if(!isliving(gone))
		return
	var/mob/living/leaver = gone
	leaver.remove_status_effect(STATUS_EFFECT_RUST_CORRUPTION)

// Small visual effect imparted onto rusted things by revenants.
/obj/effect/glowing_rune
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "small_rune_1"
	plane = FLOOR_PLANE
	layer = SIGIL_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/glowing_rune/Initialize(mapload)
	. = ..()
	pixel_y = rand(-6, 6)
	pixel_x = rand(-6, 6)
	icon_state = "small_rune_[rand(1, 12)]"
	update_appearance()
