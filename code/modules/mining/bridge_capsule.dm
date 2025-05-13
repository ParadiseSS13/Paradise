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
	. += "<span class='notice'>To use, activate it in-hand and throw it between the middle of the two areas you are trying to bridge.</span>"
	. += "<span class='notice'>For best results, ensure the land on both sides of the span are smooth.</span>"

/obj/item/bridge_capsule/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, dodgeable)
	. = ..()
	if(used)
		ADD_TRAIT(src, TRAIT_FLYING, "[UID()]")
		thrown_dir = get_dir(thrower, target)
		to_chat(thrower, "<span class='notice'>[src] hovers above the ground as it prepares to deploy...</span>")

/obj/item/bridge_capsule/activate_self(mob/user)
	. = ..()
	if(!used)
		loc.visible_message("<span class='warning'>[src] begins to shake. Stand back!</span>")
		used = TRUE
		addtimer(CALLBACK(src, PROC_REF(deploy)), 5 SECONDS)

/obj/item/bridge_capsule/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	. = ..()
	thrown_dir = throwingdatum.init_dir

/obj/item/bridge_capsule/proc/deploy()
	if(ismob(loc))
		to_chat(loc, "<span class='notice'>[src] stops shaking. Looks like it needs to be thrown to deploy.</span>")
		used = FALSE
		return

	if(istype(loc, SSmapping.lavaland_theme?.primary_turf_type))
		loc.visible_message("<span class='warning'>[src] suddenly bursts!</span>")
		var/obj/effect/spawner/dynamic_bridge/capsule/spawner = new(loc, thrown_dir)
		var/result = spawner.attempt_bridge()
		var/fail_message = "[src] buzzes loudly and falls to the ground!"
		switch(result)
			if(BRIDGE_SPAWN_SUCCESS)
				qdel(src)
			if(BRIDGE_SPAWN_BAD_TERRAIN)
				loc.visible_message("<span class='warning'>[fail_message] It looks like the terrain here is too uneven for a bridge.</span>")
				stop_flying()
			if(BRIDGE_SPAWN_TOO_NARROW)
				loc.visible_message("<span class='warning'>[fail_message] It looks like the span here is too narrow.</span>")
				stop_flying()
			if(BRIDGE_SPAWN_TOO_WIDE)
				loc.visible_message("<span class='warning'>[fail_message] It looks like the span here is too wide.</span>")
				stop_flying()

		qdel(spawner)
		return

	stop_flying()
	to_chat(loc, "<span class='notice'>[src] flutters to the ground, refusing to deploy. Maybe you can't do that here?</span>")

/obj/item/bridge_capsule/proc/stop_flying()
	REMOVE_TRAIT(src, TRAIT_FLYING, "[UID()]")
	// Easiest/fastest way to trigger chasms/lava underneath us to
	// determine if something needs to happen when we lose our trait
	if(isturf(loc))
		loc.process()
