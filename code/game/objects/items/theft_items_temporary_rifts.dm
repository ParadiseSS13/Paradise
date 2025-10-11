
/// The number of anomalous particulate gatherings per objective
#define NUM_ANOM_PER_OBJ 5

//qwertodo: Decide if you want brain damage, eye damage, burning if moving into it, radioactive, or a combination of these things


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
	for(var/heretic_number in 1 to length(tracked_objectiveholders))
		how_many_can_we_make += max(NUM_ANOM_PER_OBJ - heretic_number + 1, 1)

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
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "pierced_illusion" // qwertodo Temporary, will need it's own proper sprite in the event heretic does happen one day.
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	alpha = 0
	invisibility = INVISIBILITY_LEVEL_TWO
	/// The effect on examine
	var/examine_effect
	/// The effect on touch / bump
	var/bump_effect
	/// The effect passively
	var/process_effect

/obj/effect/visible_anomalous_particulate/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(show_presence)), 15 SECONDS)

/obj/effect/visible_anomalous_particulate/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/visible_anomalous_particulate/add_filter(name, priority, list/params)
	return

/*
 * Makes the influence fade in after 15 seconds.
 */
/obj/effect/visible_anomalous_particulate/proc/show_presence()
	invisibility = 0
	animate(src, alpha = 255, time = 15 SECONDS)
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
	// qwertodo: appropreate punishment for touching depending on type
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
				visible_message( "<span class='notice'>[src] A drop of blue particulate condenses into a shining crystal!</span>")
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
			if(prob(25))
				radiation_pulse(src, 600, ALPHA_RAD)
				radiation_pulse(src, 600, BETA_RAD)
				radiation_pulse(src, 600, GAMMA_RAD)

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
			removed.set_temperature(min(removed.temperature() + 40000 / heat_capacity, 1000))
		else
			removed.set_temperature(max(removed.temperature() - 40000 / heat_capacity, TCMB))
	env.merge(removed)

/obj/effect/visible_anomalous_particulate/add_fingerprint(mob/living/M, ignoregloves)
	return //No detective you can not scan the fucking influence to find out who touched it

#undef BLUESPACE
#undef GRAV
#undef PYRO
#undef FLUX
#undef CRYO
#undef VORTEX

/obj/effect/anomalous_particulate
	name = "cloud of anomalous particulate"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "reality_smash"
	anchored = TRUE
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
	return //No detective you can not scan the fucking influence to find out who touched it

/obj/effect/anomalous_particulate/attack_by(obj/item/attacking, mob/user, params)
	if(..())
		return FINISH_ATTACK
	// Using a codex will give you two knowledge points for draining.
	if(drain_with_device(user, attacking))
		return FINISH_ATTACK
	return ..()

/obj/effect/anomalous_particulate/proc/drain_with_device(mob/user, obj/item/ppp_processor/processor) //qwertodo: the item
	if(!istype(processor) || being_drained)
		return FALSE
	//qwertodo : tie to item here
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

// This device is used to analyze and trigger the particulate
/obj/item/ppp_processor
	name = "prototype portable particulate processor"
	desc = "The Prototype Portable Particulate Processor, or PPPProcessor, for short, is a device designed to energize, collect, \
	and process anomalous particulate"
	icon = 'icons/obj/theft_tools.dmi' //qwertodo: sprite
	icon_state = "PPP_Processor_0"
	force = 10
	throwforce = 10
	attack_verb = list("processes", "perforates", "pounds", "pastes", "prods", "punishes", "plows into", "pommels", "penetrates", "probes")
	new_attack_chain = TRUE
	/// How many clouds have been processed?
	var/clouds_processed = 0
	/// Have we used it in hand to fully process the particulate and eject the canisters?
	var/fully_processed_particulate = FALSE
	/// Are we possibly processing particularly powerful packets?
	var/presently_processing_particular_particultate = FALSE
	/// The soundloop we use.
	var/datum/looping_sound/kitchen/microwave/me_cro_wah_vey

/obj/item/ppp_processor/Initialize(mapload)
	. = ..()
	me_cro_wah_vey = new /datum/looping_sound/kitchen/microwave(list(src), FALSE)

/obj/item/ppp_processor/Destroy()
	QDEL_NULL(me_cro_wah_vey)
	return ..()

/obj/item/ppp_processor/proc/collect()
	clouds_processed++
	update_icon()

/obj/item/ppp_processor/activate_self(mob/user)
	if(..())
		return
	if(fully_processed_particulate)
		to_chat(user, "<span class='notice'>[src] has already processed and ejected the samples. Just make sure to escape with it!</span>")
		return
	if(clouds_processed < 3)
		to_chat(user, "<span class='warning'>[src] has only [clouds_processed] out of 3 samples. You still need to collect more!</span>")
		return
	if(presently_processing_particular_particultate)
		to_chat(user, "<span class='warning'>[src] is presently processing particularly powerful packets of your particular particulate. Wait for it to finish before proceeding.</span>")
		return

	to_chat(user, "<span class='notice'>[src] is now processing the samples. Please hold as processing finishes, and be aware it may eject collection canisters.</span>")
	if(me_cro_wah_vey)
		me_cro_wah_vey.start()
	addtimer(CALLBACK(src, PROC_REF(perfectly_processed), user), 15 SECONDS)
	presently_processing_particular_particultate = TRUE

/obj/item/ppp_processor/update_icon_state()
	. = ..()
	switch(clouds_processed)
		if(-1)
			icon_state = "PPP_Processor_-1"
		if(0)
			icon_state = "PPP_Processor_0"
		if(1)
			icon_state = "PPP_Processor_1"
		if(2)
			icon_state = "PPP_Processor_2"
		if(3)
			icon_state = "PPP_Processor_3"

/obj/item/ppp_processor/proc/perfectly_processed(mob/user)
	if(!QDELETED(user))
		to_chat(user, "<span class='notice'>[src] has perfectly processed the samples. You may now use the canisters however you wish. Ensure the processor gets back to us.</span>")
	me_cro_wah_vey.stop()
	presently_processing_particular_particultate = FALSE
	clouds_processed = -1
	fully_processed_particulate = TRUE
	update_icon()
	var/list/potential_grenade_rewards = list()
	potential_grenade_rewards += subtypesof(/obj/item/grenade/anomalous_canister)
	potential_grenade_rewards += /obj/item/grenade/anomalous_canister
	potential_grenade_rewards += /obj/effect/abstract/dummy_mini_spawner
	potential_grenade_rewards -= /obj/item/grenade/anomalous_canister/mini

	var/turf/our_turf = get_turf(src)
	our_turf.visible_message("<span class='warning'>Three containers are ejected out of [src].</span>")
	for(var/i in 1 to 3)
		var/obj/item/new_toy = pick_n_take(potential_grenade_rewards)
		new new_toy(get_turf(src))

/obj/item/clothing/glasses/hud/anomalous
	name = "anomalous particulate scanner HUD"
	desc = "A heads-up display that scans for anomalous particulate. Has a built in cham function, to help it blend in."
	icon_state = "sunhudmed"
	inhand_icon_state = "sunglasses"
	hud_types = DATA_HUD_ANOMALOUS
	flash_protect = FLASH_PROTECTION_FLASH // The revealed stuff often can cause eye flashes, safety first

	var/datum/action/item_action/chameleon_change/chameleon_action

/obj/item/clothing/glasses/hud/anomalous/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/glasses
	chameleon_action.chameleon_name = "HUD"
	chameleon_action.chameleon_blacklist = list()
	chameleon_action.initialize_disguises()

/obj/item/clothing/glasses/hud/anomalous/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/glasses/hud/anomalous/emp_act(severity)
	. = ..()
	chameleon_action.emp_randomise()

// The parent anomalous grenade type. Spawns a random anomaly.
/obj/item/grenade/anomalous_canister
	name = "anomalous particulate canister"
	desc = "This canister can be set off to unleash an anomaly." //qwertodo: improve
	icon_state = "anomalous_canister"
	inhand_icon_state = "emp"
	origin_tech = "magnets=3;combat=2" //qwertodo: buff a little
	/// The type of anomaly the canister will spawn.
	var/obj/effect/anomaly/anomaly_type
	/// The lifetime of the anomaly.
	var/anomaly_lifetime = 45 SECONDS
	/// How many anomalies the grenade will spawn
	var/number_of_anomalies = 1

/obj/item/grenade/anomalous_canister/Initialize(mapload)
	. = ..()
	anomaly_type = pick(subtypesof(/obj/effect/anomaly))

/obj/item/grenade/anomalous_canister/prime()
	update_mob()
	for(var/i in 1 to number_of_anomalies)
		var/obj/effect/anomaly/A = new anomaly_type(get_turf(src), anomaly_lifetime, FALSE)
		A.anomalous_canister_setup()
	qdel(src)

/obj/item/grenade/anomalous_canister/dual_core
	name = "dual clouded anomalous particulate canister"
	desc = "Two smaller clouds of particulate are in this canister."
	icon_state = "anomalous_canister_dual"
	number_of_anomalies = 2
	anomaly_lifetime = 30 SECONDS

/obj/item/grenade/anomalous_canister/condensed
	name = "condesed anomalous particulate canister"
	desc = "A large cloud of resiliant particulate is in this canister."
	icon_state = "anomalous_canister_condensed"
	anomaly_lifetime = 90 SECONDS

/obj/item/grenade/anomalous_canister/stabilized
	name = "stabilized anomalous particulate canister"
	desc = "The cloud of this particulate has stabilized enough for the computer to predict the anomaly it will condense into..."
	icon_state = "anomalous_canister_stable"

/obj/item/grenade/anomalous_canister/stabilized/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The predicted result is for the cloud to condense into \an [anomaly_type::name]!</span>"

/obj/effect/abstract/dummy_mini_spawner

/obj/effect/abstract/dummy_mini_spawner/Initialize(mapload)
	. = ..()
	var/turf/our_turf = get_turf(src)
	our_turf.visible_message("<span class='warning'>One of the containers splits into 3 smaller capsules!</span>")
	for(var/i in 1 to 3)
		new /obj/item/grenade/anomalous_canister/mini(our_turf)
	return INITIALIZE_HINT_QDEL

/obj/item/grenade/anomalous_canister/mini
	name = "miniture anomalous particulate canister"
	desc = "This small sphere contains a small cloud of particulate. Likely won't form an anomally, but should still have a noticable impact"
	icon_state = "anomalous_canister_mini"

/obj/item/grenade/anomalous_canister/mini/prime()
	update_mob()
	playsound(src, 'sound/magic/lightningbolt.ogg', 100, TRUE)
	switch(anomaly_type)
		if(/obj/effect/anomaly/bluespace) //Teleport and slow combat for 15
			if(!is_teleport_allowed(z))
				visible_message("<span class='warning'>[src]'s fragments begin rapidly vibrating and blink out of existence.</span>")
				qdel(src)
				return
			for(var/mob/living/L in range(7, src))
				do_teleport(L, get_turf(L), 7, sound_in = 'sound/effects/phasein.ogg')
				L.apply_status_effect(STATUS_EFFECT_BLUESPACESLOWDOWN)
		if(/obj/effect/anomaly/flux) // shock
			for(var/mob/living/L in view(7, src))
				L.Beam(get_turf(src), icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 5) //What? Why are we beaming from the mob to the turf? Turf to mob generates really odd results.
				L.electrocute_act(20, "electrical blast", flags = SHOCK_NOGLOVES)
				L.KnockDown(6 SECONDS)
		if(/obj/effect/anomaly/grav) // repulse
			var/list/thrownatoms = list()
			var/atom/throwtarget
			var/distfromcaster
			for(var/turf/T in range(7, src)) //Done this way so things don't get thrown all around hilariously.
				for(var/atom/movable/AM in T)
					thrownatoms += AM

			for(var/am in thrownatoms)
				var/atom/movable/AM = am
				if(AM == src || AM.anchored || AM.move_resist == INFINITY)
					continue

				throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(AM, src)))
				distfromcaster = get_dist(src, AM)
				if(distfromcaster == 0)
					if(isliving(AM))
						var/mob/living/M = AM
						M.Weaken(8 SECONDS)
						M.adjustBruteLoss(5)
						to_chat(M, "<span class='userdanger'>You're slammed into the floor by an anomalous force!</span>")
				else
					new /obj/effect/temp_visual/gravpush(get_turf(AM), get_dir(src, AM)) //created sparkles will disappear on their own
					if(isliving(AM))
						var/mob/living/M = AM
						M.Weaken(3 SECONDS)
						to_chat(M, "<span class='userdanger'>You're thrown back by a anomalous force!</span>")
					spawn(0)
						AM.throw_at(throwtarget, ((clamp((5 - (clamp(distfromcaster - 2, 0, distfromcaster))), 3, 5))), 1)//So stuff gets tossed around at the same time.
		if(/obj/effect/anomaly/pyro) // burn
			var/datum/gas_mixture/air = new()
			air.set_temperature(750)
			air.set_toxins(20)
			air.set_oxygen(20)
			var/turf/T = get_turf(src)
			T.blind_release_air(air)
			for(var/mob/living/L in view(7, src))
				L.adjust_fire_stacks(6)
				L.IgniteMob()
		if(/obj/effect/anomaly/cryo) // weaker anomaly grenade
			for(var/turf/simulated/floor/T in view(4, get_turf(src)))
				T.MakeSlippery(TURF_WET_ICE)
				for(var/mob/living/carbon/C in T)
					C.adjust_bodytemperature(-230)
					C.apply_status_effect(/datum/status_effect/freon)
		if(/obj/effect/anomaly/bhole) // big smoke that doesn't last as long as a smoke grenade
			var/datum/effect_system/smoke_spread/smoke
			smoke = new /datum/effect_system/smoke_spread/bad()
			smoke.set_up(20, FALSE, src)
			playsound(get_turf(src), 'sound/effects/smoke.ogg', 50, TRUE, -3)
			smoke.start()
	qdel(src)




/obj/item/paper/guides/antag/anomalous_particulate
	name = "Particulate gathering instructions"
	info = {"<b>Instructions on your new PPPProcessor and HUD</b><br>
	<br>
	First off, equip your glasses. You will need them to find the particulate. We heavily advise against losing them.<br>
	<br>
	This will allow you to identify the uncharged anomalous particulate aboard the station. It can be anywhere, stalk out rooms and or use cameras to find it.<br>
	<br>
	Afterwords, approach the particulate with the PPPProcessor, and use it on the particulate. It will charge and capture a sample of it.<br>
	<br>
	<b>Warning:</b> Charged particulate is dangerous. Wear the goggles and leave the area. Try not to get caught in doing so.<br>
	<br>
	After collecting 3 diffrent unique samples (We will not accept a sample another agent has collected), use the scanner in hand to begin processing the particulate.<br>
	<br>
	After a short processing period, processing will be complete and you can bring the processor back to us. Additionally, 3 collection cansiters should eject.<br>
	<br>
	Feel free to use the canisters however you wish, they should be effective weapons, though do write down the results for us.
	<br><hr>
	<font size =\"1\"><i>We are not liable for any health conditions you may recive from scanning particulate or using the canisters.</i></font>
"}

