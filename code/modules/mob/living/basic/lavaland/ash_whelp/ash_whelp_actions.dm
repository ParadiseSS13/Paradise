/datum/action/cooldown/mob_cooldown/fire_breath
	name = "Fire Breath"
	button_icon_state = "fireball"
	desc = "Breathe a line of flames towards the target."
	cooldown_time = 3 SECONDS
	/// The range of the fire
	var/fire_range = 15
	/// The sound played when you use this ability
	var/fire_sound = 'sound/magic/fireball.ogg'
	/// Time to wait between spawning each fire turf
	var/fire_delay = 0.15 SECONDS
	/// How hot is our fire
	var/fire_temperature = 1000
	/// 'How much' fire do we expose the turf to?
	var/fire_volume = 50
	/// How much damage do you take when engulfed?
	var/fire_damage = 20
	/// How much damage to mechs take when engulfed?
	var/mech_damage = 45

/datum/action/cooldown/mob_cooldown/fire_breath/Activate(atom/target_atom)
	disable_cooldown_actions()
	attack_sequence(target_atom)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/// Apply our specific fire breathing shape, in proc form so we can override it in subtypes
/datum/action/cooldown/mob_cooldown/fire_breath/proc/attack_sequence(atom/target)
	playsound(owner.loc, fire_sound, 200, TRUE)
	fire_line(target)

/// Breathe fire in a line towards the target, optionally rotated at an offset from the target
/datum/action/cooldown/mob_cooldown/fire_breath/proc/fire_line(atom/target, offset)
	if(isnull(target))
		return
	var/turf/target_turf = get_ranged_target_turf_direct(owner, target, fire_range, offset)
	var/list/turfs = get_line(owner, target_turf) - get_turf(owner)
	INVOKE_ASYNC(src, PROC_REF(progressive_fire_line), turfs)

/// Creates fire with a delay on the list of targeted turfs
/datum/action/cooldown/mob_cooldown/fire_breath/proc/progressive_fire_line(list/burn_turfs)
	if(QDELETED(owner) || owner.stat == DEAD)
		return
	// Guys we have already hit, no double dipping
	var/list/hit_list = list(owner) // also don't burn ourselves
	for(var/turf/target_turf in burn_turfs)
		if(target_turf.is_blocked_turf(exclude_mobs = TRUE))
			return
		burn_turf(target_turf, hit_list, owner)
		sleep(fire_delay)

/// Finally spawn the actual fire, spawns the fire hotspot in case you want to recolour it or something
/datum/action/cooldown/mob_cooldown/fire_breath/proc/burn_turf(turf/fire_turf, list/hit_list, mob/living/source)
	var/obj/effect/hotspot/fire_hotspot = new /obj/effect/hotspot(fire_turf, fire_volume, fire_temperature)
	fire_hotspot.recolor()
	fire_turf.hotspot_expose(fire_temperature, fire_volume, TRUE)

	for(var/mob/living/barbecued in fire_turf.contents)
		if(barbecued in hit_list)
			continue
		hit_list |= barbecued
		on_burn_mob(barbecued, source)

	for(var/obj/mecha/robotron in fire_turf.contents)
		if(robotron in hit_list)
			continue
		hit_list |= robotron
		robotron.take_damage(mech_damage, BURN, FIRE)

	return fire_hotspot

/// Do something unpleasant to someone we set on fire
/datum/action/cooldown/mob_cooldown/fire_breath/proc/on_burn_mob(mob/living/barbecued, mob/living/source)
	if(fire_temperature <= TCMB)
		barbecued.apply_status_effect(/datum/status_effect/ice_block_talisman, 3 SECONDS)
		to_chat(barbecued, SPAN_USERDANGER("You're frozen solid by [source]'s icy breath!"))
	else
		to_chat(barbecued, SPAN_USERDANGER("You are burned by [source]'s fire breath!"))
		barbecued.adjustFireLoss(fire_damage)

/// Shoot three lines of fire in a sort of fork pattern approximating a cone
/datum/action/cooldown/mob_cooldown/fire_breath/cone
	name = "Fire Cone"
	desc = "Breathe several lines of fire directed at a target."
	/// The angles relative to the target that shoot lines of fire
	var/list/angles = list(-40, 0, 40)

/datum/action/cooldown/mob_cooldown/fire_breath/cone/attack_sequence(atom/target)
	playsound(owner.loc, fire_sound, 200, TRUE)
	for(var/offset in angles)
		fire_line(target, offset)

/// Shoot fire in a whole bunch of directions
/datum/action/cooldown/mob_cooldown/fire_breath/mass_fire
	name = "Mass Fire"
	button_icon = 'icons/effects/fire.dmi'
	button_icon_state = "light"
	desc = "Breathe flames in all directions."
	cooldown_time = 10.5 SECONDS
	click_to_activate = FALSE
	/// How many fire lines do we produce to turn a full circle?
	var/sectors = 12
	/// How long do we wait between each spin?
	var/breath_delay = 2.5 SECONDS
	/// How many full circles do we perform?
	var/total_spins = 3

/datum/action/cooldown/mob_cooldown/fire_breath/mass_fire/Activate(atom/target_atom)
	target_atom = get_step(owner, owner.dir) // Just shoot it forwards, we don't need to click on someone forthis one
	return ..()

/datum/action/cooldown/mob_cooldown/fire_breath/mass_fire/attack_sequence(atom/target)
	var/queued_spins = 0
	for(var/i in 1 to total_spins)
		var/delay = queued_spins * breath_delay
		queued_spins++
		addtimer(CALLBACK(src, PROC_REF(fire_spin), target, queued_spins), delay)

/// Breathe fire in a circle, with a slight angle offset based on which of our several circles it is
/datum/action/cooldown/mob_cooldown/fire_breath/mass_fire/proc/fire_spin(target, spin_count)
	if(QDELETED(owner) || owner.stat == DEAD)
		return // Too dead to spin
	playsound(owner.loc, fire_sound, 200, TRUE)
	var/angle_increment = 360 / sectors
	var/additional_offset = spin_count * angle_increment / 2
	for(var/i in 1 to sectors)
		fire_line(target, (angle_increment * i) + (additional_offset))

/// Breathe "fire" in a line (it's freezing cold)
/datum/action/cooldown/mob_cooldown/fire_breath/ice
	name = "Ice Breath"
	desc = "Fire a cold line of fire towards the enemy!"
	cooldown_time = 6 SECONDS
	fire_range = 7
	fire_damage = 10
	fire_delay = 0.85 DECISECONDS
	fire_temperature = TCMB
	/// Time to warn people about what we are doing
	var/forecast_delay = 0.6 SECONDS
	/// What turf are we aiming at?
	var/turf/target_turf
	/// Overlay we show when we're about to fire
	var/image/forecast_overlay
	/// Icon state used foroverlay
	var/forecast_overlay_state = "ice_whelp_telegraph_dir"

/datum/action/cooldown/mob_cooldown/fire_breath/ice/New(Target, original)
	. = ..()
	forecast_overlay = image('icons/mob/lavaland/lavaland_monsters.dmi', forecast_overlay_state)

/// Apply our specific fire breathing shape, in proc form so we can override it in subtypes
/datum/action/cooldown/mob_cooldown/fire_breath/ice/attack_sequence(atom/target)
	target_turf = get_turf(target)
	INVOKE_ASYNC(src, PROC_REF(attack_forecast))

/// Charge up before we breathe fire
/datum/action/cooldown/mob_cooldown/fire_breath/ice/proc/attack_forecast()
	owner.face_atom(target_turf)
	owner.Shake(pixelshiftx = 1, pixelshifty = 0, duration = forecast_delay)
	forecast_overlay.dir = (get_dir(owner, target_turf))
	owner.add_overlay(forecast_overlay)
	var/succeeded = do_after(owner, delay = forecast_delay, target = owner, hidden = TRUE)
	owner.cut_overlay(forecast_overlay)
	if(succeeded)
		playsound(owner.loc, fire_sound, 200, TRUE)
		breath_attack()

/// Actually breathe fire
/datum/action/cooldown/mob_cooldown/fire_breath/ice/proc/breath_attack()
	owner.face_atom(target_turf)
	fire_line(target_turf)
	target_turf = null

/// Breathe really cold fire an area around them
/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption
	name = "Ice Eruption"
	desc = "Unleash cold fire in all directions"
	button_icon = 'icons/effects/fire.dmi'
	button_icon_state = "light"
	click_to_activate = FALSE
	fire_range = 3
	forecast_delay = 1 SECONDS
	fire_delay = 1.5 DECISECONDS
	forecast_overlay_state = "ice_whelp_telegraph_all"

/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption/breath_attack()
	target_turf = null

	var/list/hit_list = list(owner)
	var/list/nearby_turfs = list()
	for(var/turf/simulated/floor/target_turf in circle_range(owner, fire_range))
		if(target_turf.is_blocked_turf(exclude_mobs = TRUE))
			continue
		var/turf_dist = get_dist(owner, target_turf)
		if(turf_dist == 0)
			continue
		LAZYADDASSOCLIST(nearby_turfs, "[turf_dist]", target_turf)

	for(var/i in 1 to fire_range)
		for(var/turf/simulated/floor/kindling as anything in nearby_turfs["[i]"])
			burn_turf(kindling, hit_list, owner)
		sleep(fire_delay)

///Fire subtype forash whelps
/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption/fire
	name = "Eruption"
	fire_temperature = 1000
