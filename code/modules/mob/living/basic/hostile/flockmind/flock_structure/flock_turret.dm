/obj/structure/flock/gnesis_turret
	name = "spiky fluid vat"
	desc = "A vat of bubbling teal fluid, covered in hollow spikes."
	flock_desc = "A turret that fires gnesis-filled spikes at enemies, beginning their conversion to Flockbits. Consumes 50 bandwidth passively."
	icon_state = "teleblocker-off"

	max_integrity = 80

	flock_id = "Gnesis turret"
	resource_cost = 150
	active_bandwidth_cost = 50

	var/range = 8
	var/projectile_count = 4
	var/projectile_type = /obj/projectile/bullet/dart/piercing/gnesis

	var/mob/current_target

/obj/structure/flock/gnesis_turret/Initialize(mapload, datum/flock/join_flock)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/flock/gnesis_turret/Destroy()
	set_target(null)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/flock/gnesis_turret/update_icon_state()
	if(active)
		icon_state = "teleblocker-on"
	else
		icon_state = "teleblocker-off"
	. = ..()

// /obj/structure/flock/gnesis_turret/update_info_tag()
// 	info_tag.set_text("Gnesis: [reagents.total_volume]/[reagents.maximum_volume]")

/obj/structure/flock/gnesis_turret/process(delta_time)
	if(isnull(flock))
		set_active(FALSE)
		return PROCESS_KILL

	if(active)
		if(flock.available_bandwidth() < 0)
			set_active(FALSE)
	else
		if(flock.can_afford(active_bandwidth_cost))
			set_active(TRUE)

	if(!active)
		return

	if(isnull(current_target) || !is_valid_target(current_target))
		set_target(find_target())
		if(isnull(current_target))
			return

	fire()

/obj/structure/flock/gnesis_turret/proc/fire(bullets = src.projectile_count)
	if(isnull(current_target))
		return

	var/obj/projectile/boolet = new projectile_type
	boolet.preparePixelProjectile(current_target, loc, deviation = rand(-5, 5))
	boolet.firer = src
	boolet.fired_from = src
	boolet.ignored_factions = list(FACTION_FLOCK)
	boolet.fire()

	bullets--
	if(bullets)
		addtimer(CALLBACK(src, PROC_REF(fire), bullets), 0.1 SECONDS)

/obj/structure/flock/gnesis_turret/proc/find_target()
	var/list/targets = list()

	for(var/mob/living/L in viewers(range, src))
		if(is_valid_target(L))
			targets += L

	var/target = null
	var/target_dist = INFINITY
	for(var/mob/living/L as anything in targets)
		var/dist = get_dist(src, L)
		if(dist < target_dist)
			target = L
			target_dist = dist

	return target

/obj/structure/flock/gnesis_turret/proc/is_valid_target(mob/living/L)
	if(isflockmob(L))
		return FALSE

	if(L.stat != CONSCIOUS)
		return FALSE

	if(!flock.is_mob_enemy(L))
		return FALSE

	if(L.incapacitated(IGNORE_GRAB | IGNORE_RESTRAINTS))
		return FALSE

	if(!can_see(src, L, range))
		return FALSE

	return TRUE

/obj/structure/flock/gnesis_turret/proc/set_target(mob/new_target)
	if(current_target)
		UnregisterSignal(current_target, COMSIG_PARENT_QDELETING)

	current_target = new_target

	if(current_target)
		RegisterSignal(current_target, COMSIG_PARENT_QDELETING, PROC_REF(target_del))

/obj/structure/flock/gnesis_turret/proc/target_del(datum/source)
	SIGNAL_HANDLER

	set_target(null)

/obj/projectile/bullet/dart/piercing/gnesis
	name = "barbed crystalline spike"
	desc = "A hollow teal crystal, like some sort of weird alien syringe. It has a barbed tip. Nasty!"

/obj/projectile/bullet/dart/piercing/gnesis/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/gnesis, 2)

	// commented out until i rewrite embedding :)
	// embedding = list(
	// 	embed_chance = 25,
	// 	ignore_throwspeed_threshold = TRUE,
	// 	fall_chance = 1
	// )

// commented out until i rewrite embedding :)
// /obj/projectile/bullet/dart/piercing/gnesis/inject_hit_target(mob/living/carbon/hit)
// 	return // Don't instantly dump the payload, slowly inject it.
