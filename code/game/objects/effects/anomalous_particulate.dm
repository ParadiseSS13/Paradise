
/// The number of anomalous particulate gatherings per objective
#define NUM_ANOM_PER_OBJ 5

/datum/anomalous_particulate_tracker
	/// The total number of gatherings that have been drained, for tracking.
	var/num_drained = 0
	/// List of tracked influences (reality smashes)
	var/list/obj/effect/anomalous_particulate/smashes = list()
	/// List of minds with the objective to get particulate
	var/list/datum/mind/tracked_objectiveholders = list()

/datum/anomalous_particulate_tracker/Destroy(force)
	if(GLOB.anomaly_smash_track == src)
		stack_trace("[type] was deleted. Antagonists may no longer access any particulate. Fix it, or call coder support.")
		message_admins("The [type] was deleted. Antagonists may no longer access any particulate. Fix it, or call coder support.")
	QDEL_LIST_CONTENTS(smashes)
	tracked_objectiveholders.Cut()
	return ..()

/**
 * Generates a set amount of reality smashes
 * based on the number of already existing smashes
 * and the number of minds we're tracking.
 */
/datum/anomalous_particulate_tracker/proc/generate_new_influences()
	var/how_many_can_we_make = 0
	for(var/antag_number in 1 to length(tracked_objectiveholders))
		how_many_can_we_make += max(NUM_ANOM_PER_OBJ - antag_number + 1, 1)

	var/location_sanity = 0
	while((length(smashes) + num_drained) < how_many_can_we_make && location_sanity < 100)
		var/turf/chosen_location = get_safe_random_station_turf_equal_weight()

		// We don't want them close to each other - at least 1 tile of separation
		var/list/nearby_things = range(1, chosen_location)
		var/obj/effect/anomalous_particulate/what_if_i_have_one = locate() in nearby_things
		var/obj/effect/visible_anomalous_particulate/what_if_i_had_one_but_its_used = locate() in nearby_things
		if(what_if_i_have_one || what_if_i_had_one_but_its_used)
			location_sanity++
			continue

		new /obj/effect/anomalous_particulate(chosen_location)

/**
 * Adds a mind to the list of people that need things spawned
 *
 * Use this whenever you want to add someone to the list
 */
/datum/anomalous_particulate_tracker/proc/add_tracked_mind(datum/mind/obj_mind)
	tracked_objectiveholders |= obj_mind

	// If our holder is on station, generate some new influences
	if(ishuman(obj_mind.current) && is_teleport_allowed(obj_mind.current.z))
		generate_new_influences()

/**
 * Removes a mind from the list of people that need things spawned
 *
 * Use this whenever you want to remove someone from the list
 */
/datum/anomalous_particulate_tracker/proc/remove_tracked_mind(datum/mind/obj_mind)
	tracked_objectiveholders -= obj_mind

#define BLUESPACE 1
#define GRAV 2
#define PYRO 3
#define FLUX 4
#define VORTEX 5
#define CRYO 6

/obj/effect/visible_anomalous_particulate
	name = "cloud of anomalous particulate"
	icon_state = "particulate_cloud"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	alpha = 0
	invisibility = INVISIBILITY_LEVEL_TWO
	/// The effect on examine
	var/examine_effect
	/// The effect on touch / bump
	var/bump_effect
	/// The effect passively
	var/process_effect

/*
 * What does this do?
 * First, we choose a sprite for the texture, and rotate it.
 * Next, a shape. Also potentially rotated.
 * Finally, a transparent overlay to apply over the first texture.
 * After that we queue up the fade in and effects
 */
/obj/effect/visible_anomalous_particulate/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(show_presence)), 15 SECONDS)
	var/icon/our_icon
	switch(rand(1, 10)) // texture
		if(1 to 3)
			our_icon = icon('icons/effects/effects.dmi', "particulate_cloud")
		if(4 to 6)
			our_icon = icon('icons/effects/effects.dmi', "cryoanomaly")
		if(7 to 8)
			our_icon = icon('icons/effects/effects.dmi', "anom")
		if(9)
			our_icon = icon('icons/effects/effects.dmi', "void_conduit")
		if(10)
			our_icon = icon('icons/effects/effects.dmi', "static_base")

	var/icon/alpha_mask
	switch(rand(1, 8)) // shape
		if(1 to 6)
			alpha_mask = new('icons/effects/effects.dmi', "void_conduit")
		if(7)
			alpha_mask = new('icons/effects/effects.dmi', "cryoanomaly")
		if(8)
			alpha_mask = new('icons/effects/effects.dmi', "anom")
	switch(rand(1,8))
		if(1)
			alpha_mask.Turn(0)
		if(2)
			alpha_mask.Turn(90)
		if(3)
			alpha_mask.Turn(180)
		if(4)
			alpha_mask.Turn(270)
		if(5 to 8)
			alpha_mask.Turn(rand(1, 359))

	switch(rand(1,8))
		if(1)
			our_icon.Turn(0)
		if(2)
			our_icon.Turn(90)
		if(3)
			our_icon.Turn(180)
		if(4)
			our_icon.Turn(270)
		if(5 to 8)
			our_icon.Turn(rand(1, 359))

	our_icon.AddAlphaMask(alpha_mask) // Finally, let's mix in a distortion effect.
	icon = our_icon
	switch(rand(1,9))
		if(1)
			color = list(0.2,0.45,0,0, 0,1,0,0, 0,0,0.2,0, 0,0,0,1, 0,0,0,0) // green
		if(2)
			color = list(1,0,0,0, 0,0.4,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0) // purple per video 1
		if(3)
			color = list(0.4,0,0,0, 0,1.1,0,0, 0,0,1.65,0, -0.3,0.15,0,1, 0,0,0,0) // light blue
		if(4)
			color = list(0.5,1,0.9,0, 0,1,0,0, 0,0,0.5,0, 0,0,0,1, 0,0,0,0) // green blue
		if(5)
			color = list(0.8,0,0,0.35,0.2,0, 0.5,0,0.65,0.1,0,0) // red
		if(6)
			color = list(1.3,0,0,0, 0,1.65,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0) // green blue
		if(7)
			color = list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, (rand(1,100) / 100),(rand(1,100) / 100),(rand(1,100) / 100),1, 0,0,0,0) // random inverted
		if(8)
			color = list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0.8,0.85,0.95,1, 0,0,0,0) // cool inverted
		if(9)
			color = list((rand(1,100) / 100),0,0,0, 0,(rand(1,100) / 100),0,0, 0,0,(rand(1,100) / 100),0, 0,0,0,1, 0,0,0,0) // random normal

	var/mutable_appearance/theme_icon
	var/MA_alpha = pick(30, 40, 20, 25, 35, 10, 60)
	switch(rand(1, 5)) // final overlay effect
		if(1 to 3)
			theme_icon = mutable_appearance('icons/effects/effects.dmi', "static_base", FLOAT_LAYER - 1, alpha = MA_alpha,  appearance_flags = appearance_flags | RESET_TRANSFORM)
		if(4)
			theme_icon = mutable_appearance('icons/effects/effects.dmi', "emp_disable", FLOAT_LAYER - 1, alpha = MA_alpha,  appearance_flags = appearance_flags | RESET_TRANSFORM)
		if(5)
			theme_icon = mutable_appearance('icons/effects/effects.dmi', "anom", FLOAT_LAYER - 1, alpha = MA_alpha,  appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	var/matrix/M_three = matrix()
	switch(rand(1,8))
		if(1)
			M_three.Turn(0)
		if(2)
			M_three.Turn(90)
		if(3)
			M_three.Turn(180)
		if(4)
			M_three.Turn(270)
		if(5 to 8)
			M_three.Turn(rand(1, 359))

	theme_icon.transform = M_three
	overlays += theme_icon
	// Applies some random effects to the final image
	switch(rand(1,5))
		if(1)
			add_filter("distort_1", 3, motion_blur_filter(1, 1))
		if(2)
			add_filter("distort_2", 1, gauss_blur_filter(size = 0.5))
		if(3)
			add_filter("distort_3", 2, angular_blur_filter(size = 5))
		if(4)
			apply_wibbly_filters(src)
		if(5) // No visual effect
			alpha = 1
	alpha = 1 // Resets the alpha for the show_presence fade in
	alpha = 0


/obj/effect/visible_anomalous_particulate/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/*
 * Makes the influence fade in after 15 seconds.
 */
/obj/effect/visible_anomalous_particulate/proc/show_presence()
	invisibility = 0
	animate(src, alpha = 180, time = 15 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(fade_presence)), 15 SECONDS)
	configure_effects()

/*
 * Makes the influence fade out over 20 minutes.
 */
/obj/effect/visible_anomalous_particulate/proc/fade_presence()
	animate(src, alpha = 0, time = 20 MINUTES)
	QDEL_IN(src, 20 MINUTES)

/*
 * Sets up the effects for looking at it / bumping into it / aoe.
 */
/obj/effect/visible_anomalous_particulate/proc/configure_effects()
	examine_effect = pick(BLUESPACE, GRAV, PYRO, FLUX, VORTEX, CRYO)
	bump_effect = pick(BLUESPACE, GRAV, PYRO, FLUX, VORTEX, CRYO)
	process_effect = pick(BLUESPACE, GRAV, PYRO, FLUX, VORTEX, CRYO)
	if(process_effect == VORTEX)
		set_light(
		l_range = 7,
		l_power = -3,
		l_color = "#ddd6cf")
	START_PROCESSING(SSobj, src)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/visible_anomalous_particulate/proc/on_atom_entered(datum/source, atom/movable/entered)
	trigger_bump_effect(entered)

/obj/effect/visible_anomalous_particulate/Bump(atom/A)
	trigger_bump_effect(A)

/obj/effect/visible_anomalous_particulate/Bumped(atom/movable/AM)
	trigger_bump_effect(AM)

/obj/effect/visible_anomalous_particulate/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	trigger_bump_effect(user)
	return TRUE


/obj/effect/visible_anomalous_particulate/proc/trigger_bump_effect(atom/A)
	if(!isliving(A))
		return
	var/mob/living/victim = A
	switch(bump_effect)
		if(BLUESPACE) // Easy out of a department... but you'll be slow and unable to fight well for a minute.
			to_chat(victim, "<span class='userdanger'>You feel like everything around you is moving twice as fast!</span>")
			victim.apply_status_effect(STATUS_EFFECT_BLUESPACESLOWDOWN_LONG)
			victim.Slowed(1 MINUTES, 1)
			do_teleport(victim, get_turf(victim), 21, sound_in = 'sound/effects/phasein.ogg', safe_turf_pick = TRUE)
		if(GRAV) // Yeet
			to_chat(victim, "<span class='userdanger'>You bounce right off [src]!</span>")
			var/atom/target = get_edge_target_turf(victim, get_dir(src, get_step_away(victim, src)))
			victim.throw_at(target, 20, 3)
		if(PYRO) // I mean yeah, hot
			to_chat(victim, "<span class='danger'>[src] is perhaps a bit hot to the touch.</span>")
			victim.adjust_fire_stacks(12)
			victim.IgniteMob()
		if(FLUX) // Shock them... or charge the cell in the item they are holding!
			if(!ishuman(victim))
				victim.electrocute_act(20, src, flags = SHOCK_NOGLOVES)
				return
			var/list/hand_items = list(victim.get_active_hand(), victim.get_inactive_hand())
			var/charged_item = null
			for(var/obj/item in hand_items)
				if(istype(item, /obj/item/stock_parts/cell/))
					var/obj/item/stock_parts/cell/C = item
					C.charge = C.maxcharge
					charged_item = C
					break
				else if(item.contents)
					var/obj/I = null
					for(I in item.contents)
						if(istype(I, /obj/item/stock_parts/cell/))
							var/obj/item/stock_parts/cell/C = I
							C.charge = C.maxcharge
							item.update_icon()
							charged_item = item
							break
			if(!charged_item)
				victim.electrocute_act(20, src, flags = SHOCK_NOGLOVES)
				return
			to_chat(victim, "<span class='notice'>[charged_item] suddenly feels very warm!</span>")
		if(VORTEX) // sharp particulate
			to_chat(victim, "<span class='userdanger'>As you pass through [src], sharp particulate cuts into you!</span>")
			victim.adjustBruteLoss(30)
		if(CRYO) // slowdown via cold
			to_chat(victim, "<span class='userdanger'>As you pass through [src], you feel quite cold!</span>")
			victim.adjust_bodytemperature(-230)


/obj/effect/visible_anomalous_particulate/examine(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	if(hasHUD(user, ANOMALOUS_HUD))
		to_chat(user, "<span class='warning'>Your protective gear shields you from the anomalous effects. Best not to look at it without them.</span>")
		return

	var/mob/living/carbon/human/victim = user
	switch(examine_effect)
		if(BLUESPACE) // Just a slowdown in spacetime
			to_chat(victim, "<span class='userdanger'>[src] really begins to draw in your focus, time slips on by around you...</span>")
			victim.apply_status_effect(STATUS_EFFECT_BLUESPACESLOWDOWN)
			victim.Slowed(15 SECONDS, 1)
		if(GRAV) // bonk to the head
			to_chat(victim, "<span class='userdanger'>Your head hurts just looking at [src]!</span>")
			victim.adjustBrainLoss(10)
		if(PYRO) // Just a nice warm glow
			to_chat(victim, "<span class='notice'>[src] gives off a nice warm glow.</span>")
		if(FLUX) // Emp yourself. This can be considered a benefit.
			to_chat(victim, "<span class='userdanger'>As you focus on [src], a shock travels through you and your electronics!</span>")
			victim.emp_act(EMP_LIGHT)
		if(VORTEX) // Darkness consumes you. Or your vision, for a moment
			to_chat(victim, "<span class='userdanger'>[src] is so dark that... everything else kinda is.</span>")
			victim.AdjustEyeBlind(5 SECONDS)
		if(CRYO) // A cool refresher. Though a bit toxic.
			to_chat(victim, "<span class='warning'>A cool feeling passes through you, closing your wounds. Feels... a bit off though...</span>")
			victim.adjustBruteLoss(-10)
			victim.adjustFireLoss(-20)
			victim.adjustToxLoss(15)
			victim.adjust_bodytemperature(-75)

/obj/effect/visible_anomalous_particulate/process()
	var/turf/our_turf = get_turf(src)
	var/area/to_be_modified = get_area(our_turf)
	switch(process_effect)
		if(BLUESPACE) // Condense a crystal now and then
			if(prob(2))
				visible_message( "<span class='notice'>A drop of blue particulate from [src] condenses into a shining crystal.</span>")
				new /obj/item/stack/ore/bluespace_crystal/refined(get_turf(src))
		if(GRAV) // Nice gravity. Invert it.
			if(prob(1))
				if(has_gravity(src, our_turf))
					to_be_modified.gravitychange(FALSE, to_be_modified)
				else
					to_be_modified.gravitychange(TRUE, to_be_modified)
		if(PYRO) // Keeps the room warm
			var/datum/milla_safe/visible_anomalous_particulate/milla = new()
			milla.invoke_async(src)
		if(FLUX) // Science we need like 10 power cells please
			if(to_be_modified.apc)
				var/obj/machinery/power/apc/A = to_be_modified.apc[1]
				if(A.operating && A.cell)
					A.cell.charge = max(0, A.cell.charge - 25)
					if(A.charging == APC_FULLY_CHARGED) // If the cell was full
						A.charging = APC_IS_CHARGING // It's no longer full
		// Vortex just has darkness, no process needed
		if(CRYO) // A cool blue glow. AKA a radioactive one.
			if(prob(33))
				radiation_pulse(src, 1600, ALPHA_RAD)
				radiation_pulse(src, 1600, BETA_RAD)
				radiation_pulse(src, 1600, GAMMA_RAD)

/datum/milla_safe/visible_anomalous_particulate

/datum/milla_safe/visible_anomalous_particulate/on_run(obj/effect/visible_anomalous_particulate/source)
	var/turf/simulated/L = get_turf(source)
	if(!istype(L))
		return
	var/datum/gas_mixture/env = get_turf_air(L)
	if(env.temperature() == 60 + T0C)
		return
	var/transfer_moles = 0.25 * env.total_moles()

	var/datum/gas_mixture/removed = env.remove(transfer_moles)

	if(!removed)
		return
	var/heat_capacity = removed.heat_capacity()

	if(heat_capacity)
		if(removed.temperature() < 60 + T0C)
			removed.set_temperature(min(removed.temperature() + 80000 / heat_capacity, 1000))
		else
			removed.set_temperature(max(removed.temperature() - 80000 / heat_capacity, TCMB))
	env.merge(removed)

/obj/effect/visible_anomalous_particulate/add_fingerprint(mob/living/M, ignoregloves)
	return // No detective you can not scan the fucking influence to find out who touched it

#undef BLUESPACE
#undef GRAV
#undef PYRO
#undef FLUX
#undef CRYO
#undef VORTEX

/obj/effect/anomalous_particulate
	name = "cloud of anomalous particulate"
	icon_state = "hud_anom"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_LEVEL_TWO
	hud_possible = list(ANOMALOUS_HUD)
	/// Whether we're currently being drained or not.
	var/being_drained = FALSE

/obj/effect/anomalous_particulate/Initialize(mapload)
	. = ..()
	GLOB.anomaly_smash_track.smashes += src
	prepare_huds()
	for(var/datum/atom_hud/data/anomalous/a_hud in GLOB.huds)
		a_hud.add_to_hud(src)
	do_hud_stuff()

/obj/effect/anomalous_particulate/Destroy()
	GLOB.anomaly_smash_track.smashes -= src
	return ..()

/obj/effect/anomalous_particulate/add_fingerprint(mob/living/M, ignoregloves)
	return // No detective you can not scan the fucking influence to find out who touched it

/obj/effect/anomalous_particulate/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK
	if(drain_with_device(user, attacking))
		return FINISH_ATTACK
	return ..()

/obj/effect/anomalous_particulate/proc/drain_with_device(mob/user, obj/item/ppp_processor/processor)
	if(!istype(processor) || being_drained)
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(drain_influence), user, processor)
	return TRUE

/**
 * Begin to drain the influence, setting being_drained,
 * registering an examine signal, and beginning a do_after.
 *
 * If successful, the influence is drained and deleted.
 */
/obj/effect/anomalous_particulate/proc/drain_influence(mob/living/user, obj/item/ppp_processor/processor)
	if(processor.clouds_processed >= 3)
		to_chat(user, "<span class='warning'>Your PPPProcessor is full!</span>")
		return
	if(processor.clouds_processed == -1)
		to_chat(user, "<span class='warning'>Your PPPProcessor has no canisters to collect particulate with!</span>")
		return
	being_drained = TRUE
	to_chat(user, "<span class='notice'>Your PPPProcessor begins to energize and collect [src]...</span>")

	if(!do_after(user, 10 SECONDS, target = src, hidden = TRUE))
		being_drained = FALSE
		return

	// Aaand now we delete it
	after_drain(user, processor)

/**
 * Handle the effects of the drain.
 */
/obj/effect/anomalous_particulate/proc/after_drain(mob/living/user, obj/item/ppp_processor/processor)
	if(user)
		to_chat(user, "<span class='warning'>[src] begins to intensify!</span>")

	new /obj/effect/visible_anomalous_particulate(drop_location())

	processor.collect()
	if(processor.clouds_processed >= 3)
		to_chat(user, "<span class='notice'>[processor] has it's 3 canisters filled. Be sure to process the information!</span>")

	GLOB.anomaly_smash_track.num_drained++
	qdel(src)

#undef NUM_ANOM_PER_OBJ


