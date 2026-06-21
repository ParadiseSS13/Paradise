/obj/item/bridge_capsule
	name = "bluespace bridge capsule"
	desc = "A bridge stored within a pocket of bluespace."
	icon_state = "bridge_capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "engineering=3;bluespace=3"
	new_attack_chain = TRUE
	var/used = FALSE
	var/thrown_dir

/obj/item/bridge_capsule/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("To use, activate it in-hand and throw it between the middle of the two areas you are trying to bridge.")
	. += SPAN_NOTICE("For best results, ensure the land on both sides of the span are smooth.")

/obj/item/bridge_capsule/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, dodgeable)
	. = ..()
	if(used)
		ADD_TRAIT(src, TRAIT_FLYING, "[UID()]")
		thrown_dir = get_dir(thrower, target)
		to_chat(thrower, SPAN_NOTICE("[src] hovers above the ground as it prepares to deploy..."))

/obj/item/bridge_capsule/activate_self(mob/user)
	. = ..()
	if(!used)
		loc.visible_message(SPAN_WARNING("[src] begins to shake. Stand back!"))
		used = TRUE
		addtimer(CALLBACK(src, PROC_REF(deploy)), 5 SECONDS)

/obj/item/bridge_capsule/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	. = ..()
	thrown_dir = throwingdatum.init_dir

/obj/item/bridge_capsule/proc/deploy()
	if(ismob(loc))
		to_chat(loc, SPAN_NOTICE("[src] stops shaking. Looks like it needs to be thrown to deploy."))
		used = FALSE
		return

	if(istype(loc, SSmapping.lavaland_theme?.primary_turf_type))
		loc.visible_message(SPAN_WARNING("[src] suddenly bursts!"))
		var/obj/effect/spawner/dynamic_bridge/capsule/spawner = new(loc, thrown_dir)
		var/result = spawner.attempt_bridge()
		var/fail_message = "[src] buzzes loudly and falls to the ground!"
		switch(result)
			if(BRIDGE_SPAWN_SUCCESS)
				qdel(src)
			if(BRIDGE_SPAWN_BAD_TERRAIN)
				loc.visible_message(SPAN_WARNING("[fail_message] It looks like the terrain here is too uneven for a bridge."))
				stop_flying()
			if(BRIDGE_SPAWN_TOO_NARROW)
				loc.visible_message(SPAN_WARNING("[fail_message] It looks like the span here is too narrow."))
				stop_flying()
			if(BRIDGE_SPAWN_TOO_WIDE)
				loc.visible_message(SPAN_WARNING("[fail_message] It looks like the span here is too wide."))
				stop_flying()

		qdel(spawner)
		return

	stop_flying()
	to_chat(loc, SPAN_NOTICE("[src] flutters to the ground, refusing to deploy. Maybe you can't do that here?"))

/obj/item/bridge_capsule/proc/stop_flying()
	REMOVE_TRAIT(src, TRAIT_FLYING, "[UID()]")
	// Easiest/fastest way to trigger chasms/lava underneath us to
	// determine if something needs to happen when we lose our trait
	if(isturf(loc))
		loc.process()
