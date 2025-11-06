/datum/event/demon_incursion
	name = "demon incursion"
	/// Corresponds to the number of process() runs the event has lasted for. Roughly 2 minutes here.
	announceWhen = 60
	/// Corresponds to the number of process() runs the event has lasted for. Roughly 2 minutes here.
	endWhen = 60
	/// The name of the notification for dchat
	var/notify_title = "Demonic Incursion"
	/// The icon of the notification
	var/notify_image = "nether"
	/// List of portals
	var/list/portal_list = list()
	/// The target number of portals
	var/target_portals = 100

/datum/event/demon_incursion/setup()
	impact_area = findEventArea()

/datum/event/demon_incursion/start()
	if(isnull(impact_area))
		log_debug("No valid event areas could be generated for demonic incursion.")
	var/initial_portals = max(length(GLOB.crew_list) / 10, 1)
	target_portals = max(initial_portals * 10, 30)
	var/list/area_turfs = get_area_turfs(impact_area)
	var/notice_sent = FALSE
	while(length(area_turfs) && initial_portals > 0)
		var/turf/T = pick_n_take(area_turfs)
		if(T.is_blocked_turf(exclude_mobs = TRUE))
			continue

		// Give ghosts some time to jump there before it begins.
		var/image/alert_overlay = image('icons/mob/nest.dmi', notify_image)
		if(!notice_sent)
			notify_ghosts("\A [src] is about to open in [get_area(T)].", title = notify_title, source = T, alert_overlay = alert_overlay, flashwindow = FALSE, action = NOTIFY_FOLLOW)
			notice_sent = TRUE
		addtimer(CALLBACK(src, PROC_REF(spawn_portal), T), 4 SECONDS)

		// Energy overload; we mess with machines as an early warning and for extra spookiness.
		for(var/obj/machinery/M in range(8, T))
			INVOKE_ASYNC(M, TYPE_PROC_REF(/atom, get_spooked))

		initial_portals--

	if(initial_portals > 0)
		log_debug("demonic incursion failed to find a valid turf in [impact_area]")

	SSticker.record_biohazard_start(INCURSION_DEMONS)
	SSevents.biohazards_this_round += INCURSION_DEMONS

/datum/event/demon_incursion/proc/spawn_portal(location)
	var/obj/structure/spawner/nether/demon_incursion/new_portal = new /obj/structure/spawner/nether/demon_incursion(location)
	new_portal.linked_incursion = src
	portal_list += new_portal
	// Too many portals - make a bad thing happen
	if(length(portal_list) > target_portals)
		target_portals *= 2
		prepare_spawn_elite()

/datum/event/demon_incursion/proc/prepare_spawn_elite()
	var/obj/structure/spawner/nether/demon_incursion/elite_portal = pick(portal_list)
	elite_portal.visible_message("<span class='danger'>Something within [elite_portal] stirs...</span>")
	var/list/potentialspawns = list(/mob/living/simple_animal/hostile/asteroid/elite/broodmother,
		/mob/living/simple_animal/hostile/asteroid/elite/pandora,
		/mob/living/simple_animal/hostile/asteroid/elite/legionnaire,
		/mob/living/simple_animal/hostile/asteroid/elite/herald)
	var/selected_elite = pick(potentialspawns)
	addtimer(CALLBACK(src, PROC_REF(spawn_elite), null, elite_portal, selected_elite), 10 SECONDS)

/datum/event/demon_incursion/proc/spawn_elite(mob/dead/observer/elitemind, obj/structure/spawner/nether/demon_incursion/elite_portal, selected_elite)
	var/mob/living/simple_animal/hostile/asteroid/elite/created_mob = new selected_elite(elite_portal.loc)
	created_mob.faction = list("nether")
	elite_portal.visible_message("<span class='userdanger'>[created_mob] emerges from [elite_portal]!</span>")
	notify_ghosts("\A [created_mob] has emerged from an incursion portal in \the [get_area(src)]!", enter_link="<a href=byond://?src=[UID()];follow=1>(Click to help)</a>", source = created_mob, action = NOTIFY_FOLLOW)
	qdel(elite_portal)
	playsound(created_mob.loc,'sound/effects/phasein.ogg', 200, FALSE, 50, TRUE, TRUE)

/datum/event/demon_incursion/announce(false_alarm)
	var/area/target_area = impact_area
	if(!target_area)
		if(false_alarm)
			target_area = findEventArea()
			if(isnull(target_area))
				log_debug("Tried to announce a false-alarm tear without a valid area!")
				kill()
				return
		else
			log_debug("Tried to announce an incursion without a valid area!")
			kill()
			return

	GLOB.major_announcement.Announce("Major bluespace energy spike detected at [target_area.name]. Extradimensional intruder alert. All personnel must prevent the incursion before the station is destroyed.", "Demonic Incursion Alert", 'sound/effects/siren-spooky.ogg', new_sound2 = 'sound/AI/outbreak_demon.ogg')

/obj/structure/spawner/nether/demon_incursion
	name = "demonic portal"
	density = FALSE
	layer = ABOVE_LYING_MOB_LAYER // Portals are below living mobs, but layer over dead ones
	spawn_time = 5 SECONDS // Short spawn time initially, it gets updated after it spawns initial mobs
	max_mobs = 5 // We want a lot of mobs, but not too many
	max_integrity = 200
	mob_types = list(/mob/living/basic/netherworld/migo,
					/mob/living/basic/netherworld,
					/mob/living/basic/netherworld/blankbody,
					/mob/living/basic/hellhound,
					/mob/living/basic/skeleton,
					/mob/living/basic/netherworld/faithless)
	icon = 'icons/obj/structures/portal.dmi'
	icon_state = "portal"
	light_range = 4
	light_power = 2
	light_color = "#780606"
	spawner_type = /datum/component/spawner/demon_incursion_portal
	/// The event that spawned this portal
	var/datum/event/demon_incursion/linked_incursion
	/// Percentage chance that a portal will spread every time spread() is called
	var/portal_spread_chance = 50
	/// Lowest possible spread chance
	var/min_spread_chance = 10
	/// Lower bound for portal spreading
	var/portal_spread_cooldown_min = 3 MINUTES
	/// Upper bound for portal spreading
	var/portal_spread_cooldown_max = 4 MINUTES
	/// Time until next portal
	var/expansion_delay
	/// How fast does the portal spawn mobs after the initial spawns?
	var/spawn_rate = 30 SECONDS
	/// How many initial mobs does it spawn?
	var/initial_spawns_min = 1
	var/initial_spawns_max = 4
	/// Are we spawning initial mobs?
	var/spawning_initial_mobs = TRUE
	/// Current tile spread distance
	var/tile_spread = 1
	/// Max tile Spread distance
	var/tile_spread_max = 3
	/// Turf type that is spread by the portals
	var/turf_to_spread = /turf/simulated/floor/engine/cult/demon_incursion
	/// How long of a cooldown on portal repair
	var/portal_repair_cooldown = 15 SECONDS
	COOLDOWN_DECLARE(portal_repair)

/obj/structure/spawner/nether/demon_incursion/Initialize(mapload)
	. = ..()
	expansion_delay = rand(portal_spread_cooldown_min, portal_spread_cooldown_max)
	addtimer(CALLBACK(src, PROC_REF(spread)), expansion_delay)
	var/initial_spawns = rand(initial_spawns_min, initial_spawns_max)
	var/initial_spawn_time = spawn_time * initial_spawns - 1
	addtimer(CALLBACK(src, PROC_REF(stop_initial_mobs)), initial_spawn_time)
	if(turf_to_spread)
		spread_turf()
	SSticker.mode.incursion_portals += src

/obj/structure/spawner/nether/demon_incursion/examine(mob/user)
	. = ..()
	if(COOLDOWN_FINISHED(src, portal_repair) && obj_integrity < max_integrity)
		. += "<span class='warning'>Dark tendrils are stabilizing the portal!</span>"

/obj/structure/spawner/nether/demon_incursion/process()
	. = ..()
	if(!spawning_initial_mobs)
		update_spawn_time()
	if(!COOLDOWN_FINISHED(src, portal_repair))
		return
	if(obj_integrity >= max_integrity)
		return
	obj_integrity += 5
	new /obj/effect/temp_visual/heal(loc, COLOR_BLOOD_MACHINE)

/obj/structure/spawner/nether/demon_incursion/deconstruct(disassembled)
	var/datum/component/spawner/spawn_comp = GetComponent(/datum/component/spawner)
	for(var/mob/living/basic/summoned_mob in spawn_comp.spawned_mobs)
		if(prob(50))
			playsound(src, 'sound/magic/lightningbolt.ogg', 60, TRUE)
			Beam(summoned_mob, icon_state = "purple_lightning", icon = 'icons/effects/effects.dmi', time = 1 SECONDS)
			summoned_mob.addtimer(CALLBACK(summoned_mob, TYPE_PROC_REF(/mob/living/basic, gib)), 1 SECONDS)
	var/reward_type = pick(/obj/item/stack/ore/bluespace_crystal, /obj/item/stack/ore/palladium, /obj/item/stack/ore/platinum, /obj/item/stack/ore/iridium, /obj/item/stack/ore/diamond)
	var/obj/item/stack/ore/reward = new reward_type(loc)
	reward.amount = 2
	if(linked_incursion)
		linked_incursion.portal_list -= src
		if(!length(linked_incursion.portal_list))
			playsound(src, 'sound/misc/demon_dies.ogg', 100, TRUE, ignore_walls = TRUE)
	SSticker.mode.incursion_portals -= src
	return ..()

/obj/structure/spawner/nether/demon_incursion/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armor_penetration_flat, armor_penetration_percentage)
	. = ..()
	COOLDOWN_START(src, portal_repair, portal_repair_cooldown)

/obj/structure/spawner/nether/demon_incursion/on_mob_spawn(mob/created_mob)
	. = ..()
	created_mob.Move(get_step(created_mob.loc, pick(GLOB.alldirs)))
	var/mob/living/basic/new_mob = created_mob
	if(!istype(new_mob, /mob/living/basic))
		return
	if(new_mob.basic_mob_flags & DEL_ON_DEATH)
		return
	new_mob.AddComponent(/datum/component/incursion_mob_death)

/obj/structure/spawner/nether/demon_incursion/attacked_by(obj/item/attacker, mob/living/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_SPAWNER_SET_TARGET, user)

/obj/structure/spawner/nether/demon_incursion/bullet_act(obj/item/projectile/P)
	. = ..()
	if(P.firer)
		SEND_SIGNAL(src, COMSIG_SPAWNER_SET_TARGET, P.firer)

/obj/structure/spawner/nether/demon_incursion/proc/update_spawn_time()
	var/datum/component/spawner/spawn_comp = GetComponent(/datum/component/spawner)
	var/spawn_increment = 0
	for(var/mob/living/mob as anything in spawn_comp.spawned_mobs)
		spawn_increment += 5 SECONDS
	spawn_comp.spawn_time = spawn_time + spawn_increment

/obj/structure/spawner/nether/demon_incursion/proc/spread()

	var/base_portal_count = max(length(GLOB.crew_list) / 10, 1)
	if(length(linked_incursion.portal_list) <= base_portal_count)
		portal_spread_chance = 100
	else
		// Spread chance runs on an exponential regression formula when above the base portal count.
		var/log_value = (50 - min_spread_chance) / (100 - min_spread_chance)
		var/midpoint = -(log(log_value) / base_portal_count)
		var/euler_exponent = 2.71828 ** (-midpoint * (length(linked_incursion.portal_list) - base_portal_count))
		portal_spread_chance = min_spread_chance + ((100 - min_spread_chance) * euler_exponent)
	expansion_delay = rand(portal_spread_cooldown_min, portal_spread_cooldown_max)
	if(!prob(portal_spread_chance))
		addtimer(CALLBACK(src, PROC_REF(spread)), expansion_delay)
		return
	var/list/spawnable_turfs = list()
	for(var/turf/simulated/floor/possible_loc in orange(8, src.loc))
		if(!istype(possible_loc))
			continue
		if(istype(get_area(possible_loc), /area/space))
			continue
		if(possible_loc.is_blocked_turf(exclude_mobs = TRUE))
			continue
		var/density_check = TRUE
		for(var/turf/possible_turf in view(3, possible_loc))
			if(locate(/obj/structure/spawner/nether/demon_incursion) in possible_turf)
				density_check = FALSE
				continue
		if(!density_check)
			continue
		spawnable_turfs += possible_loc
	if(!spawnable_turfs)
		return
	var/turf/spawn_loc = pick_n_take(spawnable_turfs)
	linked_incursion.spawn_portal(spawn_loc)
	addtimer(CALLBACK(src, PROC_REF(spread)), expansion_delay)
	return

/obj/structure/spawner/nether/demon_incursion/proc/stop_initial_mobs()
	spawning_initial_mobs = FALSE
	spawn_time = spawn_rate
	update_spawn_time()

/obj/structure/spawner/nether/demon_incursion/proc/spread_turf()
	for(var/turf/spread_turf in range(tile_spread, loc))
		if(isfloorturf(spread_turf) && !istype(spread_turf, turf_to_spread))
			spread_turf.ChangeTurf(turf_to_spread)
			Beam(spread_turf, icon_state = "sendbeam", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)
	if(tile_spread < tile_spread_max)
		tile_spread++
	addtimer(CALLBACK(src, PROC_REF(spread_turf)), spawn_rate)

/turf/simulated/floor/engine/cult/demon_incursion
	name = "hellish flooring"

/turf/simulated/floor/engine/cult/demon_incursion/Initialize(mapload)
	. = ..()
	icon_state = "culthell" // Cult floors auto adjust. This forces it to be the hell variant
