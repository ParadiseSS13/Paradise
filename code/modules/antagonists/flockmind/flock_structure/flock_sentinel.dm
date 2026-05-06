#define NOT_CHARGED -1
#define LOSING_CHARGE 0
#define CHARGING 1
#define CHARGED 2

/obj/structure/flock/sentinel
	name = "glowing pylon"
	desc = "A glowing pylon of sorts, faint sparks are jumping inside of it."
	flock_desc = "A charged pylon, capable of sending disorienting arcs of electricity at enemies. Consumes 20 compute."
	icon_state = "sentinel"

	max_integrity = 80

	flock_id = "Sentinel"
	active_bandwidth_cost = 20

	resource_cost = 150

	/// Attacks require charging
	var/datum/point_holder/charge
	/// Charge gained per second while a target is in range
	var/charge_per_second = 10
	/// Trend of charge.
	var/charge_status = NOT_CHARGED
	/// Turret range
	var/range = 4
	/// Damage per zap.
	var/damage_per_zap = 5

/obj/structure/flock/sentinel/Initialize(mapload, joinflock)
	charge = new
	charge.set_max_points(100)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/flock/sentinel/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(charge)
	return ..()

/obj/structure/flock/sentinel/process(delta_time)
	if(isnull(flock))
		set_active(FALSE)
		return PROCESS_KILL

	// Check if the flock can continue to run the sentinel
	if(active)
		if(flock.available_bandwidth() < 0)
			set_active(FALSE)
	else
		if(flock.can_afford(active_bandwidth_cost))
			set_active(TRUE)

	if(!active)
		if(charge.has_points())
			charge.adjust_points((charge_per_second / 2) * delta_time)
			update_info_tag()
			charge_status = LOSING_CHARGE
		else
			charge_status = NOT_CHARGED
			update_appearance(UPDATE_ICON_STATE)
		return

	// Gain more charge
	if(charge_status != CHARGED)
		charge.adjust_points(charge_per_second * delta_time)
		update_info_tag()
		if(charge.has_points(100))
			charge_status = CHARGED
			update_appearance(UPDATE_ICON_STATE)
		else if(charge_status != CHARGING)
			charge_status = CHARGING
			update_appearance(UPDATE_ICON_STATE)
		return

	// If the flock has no enemies, don't bother getting a target.
	if(!length(flock.enemies))
		return

	// Select target
	var/mob/target
	for(var/mob/living/L in viewers(range, src))

		if(HAS_TRAIT(L, TRAIT_SHOCKED_BY_SENTINEL) || !flock.is_mob_enemy(L))
			continue

		if(L.stat != CONSCIOUS || L.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB))
			continue

		target = L
		break

	// No target, abort.
	if(isnull(target))
		return

	charge_status = CHARGING
	charge.adjust_points(-100)
	update_info_tag()

	tesla_zap_target(src, target, TESLA_MOB_DAMAGE_TO_POWER(damage_per_zap))
	addtimer(TRAIT_CALLBACK_REMOVE(target, TRAIT_SHOCKED_BY_SENTINEL, ref(src)), 2 SECONDS)

	target.visible_message(
		span_danger("<b>[target]</b> is struck by a bolt of energy arcing off of <b>[src]</b>."),
		blind_message = span_hear("You hear a loud electrical crackle."),
	)

	log_combat(src, target, "fires at", addition = "owned by [flock.name]")

	var/list/hit_mobs = list(target)
	var/mob/previous_hit = target
	var/end_of_chain = TRUE

	for(var/i in 1 to 3)
		end_of_chain = TRUE

		for(var/mob/living/M in viewers(2, get_turf(previous_hit)))
			if((M in hit_mobs) || !flock.is_mob_enemy(M))
				continue

			if(M.stat == DEAD || M.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB))
				continue

			end_of_chain = FALSE

			hit_mobs += M
			tesla_zap_target(previous_hit, M, TESLA_MOB_DAMAGE_TO_POWER(damage_per_zap * 0.66))
			target.visible_message(
				span_danger("<b>[M]</b> is struck by a bolt of energy arcing off of <b>[previous_hit]</b>."),
				blind_message = span_hear("You hear a loud electrical crackle."),
			)

			previous_hit = M
			log_combat(src, target, "damages with an arc chain", addition = "owned by [flock.name]")
			break

		if(end_of_chain)
			break

/obj/structure/flock/sentinel/update_icon_state()
	if(!active || charge_status == NOT_CHARGED)
		icon_state = "sentinel"
	else
		icon_state = "sentinel"
	return ..()

/obj/structure/flock/sentinel/flock_structure_examine(mob/user)
	var/charge_status_str
	switch (charge_status)
		if (NOT_CHARGED)
			charge_status_str = "Idle"
		if (LOSING_CHARGE)
			charge_status_str = "Losing charge"
		if (CHARGING)
			charge_status_str = "Charging"
		if (CHARGED)
			charge_status_str = "Charged"

	return list(
		span_flocksay("<b>Status:</b> [charge_status_str]"),
		span_flocksay("<b>Charge Percentage: [charge.has_points()]%"),
	)

/obj/structure/flock/sentinel/update_info_tag()
	info_tag.set_text("Charge: [charge.has_points()]%")

#undef NOT_CHARGED
#undef LOSING_CHARGE
#undef CHARGING
#undef CHARGED
