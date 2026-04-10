/datum/event/demon_incursion
	name = "demon incursion"
	/// Corresponds to the number of process() runs the event has lasted for. Roughly 2 minutes here.
	announceWhen = 60
	noAutoEnd = TRUE
	role_weights = list(ASSIGNMENT_SECURITY = 4, ASSIGNMENT_CREW = 1, ASSIGNMENT_MEDICAL = 2)
	role_requirements = list(ASSIGNMENT_SECURITY = 3, ASSIGNMENT_CREW = 35, ASSIGNMENT_MEDICAL = 3)
	nominal_severity = EVENT_LEVEL_MAJOR
	/// The name of the notification for dchat
	var/notify_title = "Demonic Incursion"
	/// The icon of the notification
	var/notify_image = "nether"
	/// List of portals
	var/list/portal_list = list()
	/// The target number of portals
	var/target_portals = 100
	/// Toggled when the first portal is spawned
	var/spawned = FALSE


/datum/event/demon_incursion/tick()
	if(!length(portal_list) && spawned)
		kill()

// Costs are calculated independently of event
/datum/event/demon_incursion/event_resource_cost()
	return list()

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
	spawned = TRUE

/datum/event/demon_incursion/proc/prepare_spawn_elite()
	var/obj/structure/spawner/nether/demon_incursion/elite_portal = pick(portal_list)
	elite_portal.visible_message(SPAN_DANGER("Something within [elite_portal] stirs..."))
	var/list/potentialspawns = list(/mob/living/simple_animal/hostile/asteroid/elite/broodmother,
		/mob/living/simple_animal/hostile/asteroid/elite/pandora,
		/mob/living/simple_animal/hostile/asteroid/elite/legionnaire,
		/mob/living/simple_animal/hostile/asteroid/elite/herald)
	var/selected_elite = pick(potentialspawns)
	addtimer(CALLBACK(src, PROC_REF(spawn_elite), null, elite_portal, selected_elite), 10 SECONDS)

/datum/event/demon_incursion/proc/spawn_elite(mob/dead/observer/elitemind, obj/structure/spawner/nether/demon_incursion/elite_portal, selected_elite)
	var/mob/living/simple_animal/hostile/asteroid/elite/created_mob = new selected_elite(elite_portal.loc)
	created_mob.faction = list("nether")
	elite_portal.visible_message(SPAN_USERDANGER("[created_mob] emerges from [elite_portal]!"))
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
	mob_types = list(/mob/living/basic/netherworld/migo = 6, // Generic mobs - just run at the target
					/mob/living/basic/netherworld = 6,
					/mob/living/basic/netherworld/faithless = 6,
					/mob/living/basic/skeleton/incursion = 6,
					/mob/living/basic/netherworld/blankbody = 5,
					/mob/living/basic/hellhound/whelp = 5, // Specialized mobs - tank
					/mob/living/basic/skeleton/incursion/security = 5, // Specialized mobs - ranged
					/mob/living/basic/giant_spider/flesh_spider = 5, // Specialized mobs - poison/harasser
					/mob/living/basic/skeleton/incursion/reanimator = 4, // Specialized mobs - Summoner
					/mob/living/basic/skeleton/incursion/mobster = 1,) // Specialized mobs - ranged
	icon = 'icons/obj/structures/portal.dmi'
	icon_state = "portal"
	light_range = 4
	light_power = 2
	light_color = "#780606"
	spawner_type = /datum/component/spawner/demon_incursion_portal
	/// Mob types that cannot have a special variant - pretty much anything with a unique AI controller
	var/list/no_special_variants = list(
		/mob/living/basic/hellhound/whelp,
		/mob/living/basic/giant_spider/flesh_spider,
		/mob/living/basic/skeleton/incursion/security,
		/mob/living/basic/skeleton/incursion/mobster,
		/mob/living/basic/skeleton/incursion/reanimator)
	/// Chance that a mob type is special
	var/special_chance = 15
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
	var/spawn_rate = 45 SECONDS
	/// How many initial mobs does it spawn?
	var/initial_spawns_min = 1
	var/initial_spawns_max = 3
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
	AddComponent(/datum/component/event_tracker, EVENT_DEMONIC)

/obj/structure/spawner/nether/demon_incursion/event_cost()
	. = list()
	if(is_station_level((get_turf(src)).z))
		return list(ASSIGNMENT_SECURITY = 1, ASSIGNMENT_CREW = 5, ASSIGNMENT_MEDICAL = 1)

/obj/structure/spawner/nether/demon_incursion/Destroy()
	if(linked_incursion)
		linked_incursion.portal_list -= src
	. = ..()

/obj/structure/spawner/nether/demon_incursion/examine(mob/user)
	. = ..()
	if(COOLDOWN_FINISHED(src, portal_repair) && obj_integrity < max_integrity)
		. += SPAN_WARNING("Dark tendrils are stabilizing the portal!")

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
	if(created_mob.type in no_special_variants)
		return
	if(!(new_mob.basic_mob_flags & DEL_ON_DEATH))
		new_mob.AddComponent(/datum/component/incursion_mob_death)
	if(!prob(special_chance))
		return
	var/special_type = pick("grappler", "enflamed", "hastened", "electrified", "juggernaut")
	switch(special_type)
		if("grappler")
			new_mob.AddComponent(/datum/component/ranged_attacks, projectile_type = /obj/projectile/energy/demonic_grappler, burst_shots = 1, projectile_sound = 'sound/weapons/wave.ogg')
			new_mob.name = "grappling " + new_mob.name
			new_mob.ai_controller = new /datum/ai_controller/basic_controller/incursion/ranged(new_mob)
			new_mob.update_appearance(UPDATE_NAME)
			new_mob.color = "#5494DA"
		if("enflamed")
			new_mob.AddComponent(/datum/component/ranged_attacks, projectile_type = /obj/projectile/magic/fireball/small, burst_shots = 1, projectile_sound = 'sound/magic/fireball.ogg')
			new_mob.name = "enflamed " + new_mob.name
			new_mob.ai_controller = new /datum/ai_controller/basic_controller/incursion/ranged(new_mob)
			new_mob.update_appearance(UPDATE_NAME)
			new_mob.color = "#d4341f"
		if("hastened")
			new_mob.name = "hastened " + new_mob.name
			new_mob.update_appearance(UPDATE_NAME)
			new_mob.color = "#1fd437"
			new_mob.speed = -1
		if("electrified")
			new_mob.AddComponent(/datum/component/ranged_attacks, projectile_type = /obj/projectile/energy/demonic_shocker, burst_shots = 1, projectile_sound = 'sound/weapons/taser.ogg')
			new_mob.name = "electrified " + new_mob.name
			ADD_TRAIT(new_mob, TRAIT_SHOCKIMMUNE, "electrified")
			new_mob.ai_controller = new /datum/ai_controller/basic_controller/incursion/ranged(new_mob)
			new_mob.update_appearance(UPDATE_NAME)
			new_mob.color = "#fcf7f6"
		if("juggernaut")
			new_mob.name = "juggernaut " + new_mob.name
			new_mob.ai_controller = new /datum/ai_controller/basic_controller/incursion/juggernaut(new_mob)
			new_mob.health = new_mob.health * 2
			new_mob.maxHealth = new_mob.maxHealth * 2
			new_mob.speed += 6
			new_mob.environment_smash = ENVIRONMENT_SMASH_WALLS // Puny wall.
			new_mob.update_appearance(UPDATE_NAME)
			new_mob.color = "#292827"

/obj/structure/spawner/nether/demon_incursion/attacked_by(obj/item/attacker, mob/living/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_SPAWNER_SET_TARGET, user)

/obj/structure/spawner/nether/demon_incursion/bullet_act(obj/projectile/P)
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
