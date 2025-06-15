/datum/event/demon_incursion
	name = "demon incursion"
	announceWhen = 15
	endWhen = 45
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
	var/initial_portals = max(length(GLOB.clients) / 10, 1)
	target_portals = initial_portals * 10
	var/list/area_turfs = get_area_turfs(impact_area)
	while(length(area_turfs) && initial_portals > 0)
		var/turf/T = pick_n_take(area_turfs)
		if(T.is_blocked_turf(exclude_mobs = TRUE))
			continue

		// Give ghosts some time to jump there before it begins.
		var/image/alert_overlay = image('icons/mob/nest.dmi', notify_image)
		notify_ghosts("\A [src] is about to open in [get_area(T)].", title = notify_title, source = T, alert_overlay = alert_overlay, flashwindow = FALSE, action = NOTIFY_FOLLOW)
		addtimer(CALLBACK(src, PROC_REF(spawn_portal), T), 4 SECONDS)

		// Energy overload; we mess with machines as an early warning and for extra spookiness.
		for(var/obj/machinery/M in range(8, T))
			INVOKE_ASYNC(M, TYPE_PROC_REF(/atom, get_spooked))

		initial_portals--

	if(initial_portals > 0)
		log_debug("demonic incursion failed to find a valid turf in [impact_area]")

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
			log_debug("Tried to announce a tear without a valid area!")
			kill()
			return

	GLOB.major_announcement.Announce("Major bluespace energy spike detected at [target_area.name]. Extradimensional intruder alert. All personnel must prevent the incursion before the station is destroyed.", "Demonic Incursion Alert", 'sound/effects/siren-spooky.ogg', new_sound2 = 'sound/AI/outbreak_demon.ogg')

/obj/structure/spawner/nether/demon_incursion
	name = "demonic portal"
	density = FALSE
	spawn_time = 5 SECONDS // Short spawn time initially, it gets updated after it spawns initial mobs
	max_mobs = 6 // We want a lot of mobs, but not too many
	max_integrity = 200
	mob_types = list(/mob/living/basic/netherworld/migo,
					/mob/living/basic/netherworld,
					/mob/living/basic/netherworld/blankbody,
					/mob/living/basic/hostile/hellhound,
					/mob/living/basic/hostile/skeleton,
					/mob/living/basic/netherworld/faithless)
	/// The event that spawned this portal
	var/datum/event/demon_incursion/linked_incursion
	/// Percentage chance that a portal will spread every time spread() is called
	var/portal_spread_chance = 50
	/// Lower bound for portal spreading
	var/portal_spread_cooldown_min = 3 MINUTES
	/// Upper bound for portal spreading
	var/portal_spread_cooldown_max = 5 MINUTES
	/// Time until next portal
	var/expansion_delay
	/// How fast does the portal spawn mobs after the initial spawns?
	var/spawn_rate = 75 SECONDS
	/// How many initial mobs does it spawn?
	var/initial_spawns_min = 1
	var/initial_spawns_max = 4

/obj/structure/spawner/nether/demon_incursion/Initialize(mapload)
	. = ..()
	expansion_delay = rand(portal_spread_cooldown_min, portal_spread_cooldown_max)
	addtimer(CALLBACK(src, PROC_REF(spread)), expansion_delay)
	var/initial_spawns = rand(initial_spawns_min, initial_spawns_max)
	var/initial_spawn_time = spawn_time * initial_spawns - 1
	addtimer(CALLBACK(src, PROC_REF(stop_initial_mobs)), initial_spawn_time)

/obj/structure/spawner/nether/demon_incursion/deconstruct(disassembled)
	var/reward_type = pick(/obj/item/stack/ore/bluespace_crystal, /obj/item/stack/ore/palladium, /obj/item/stack/ore/platinum, /obj/item/stack/ore/iridium, /obj/item/stack/ore/diamond)
	new reward_type(loc)
	return ..()

/obj/structure/spawner/nether/demon_incursion/Destroy()
	. = ..()
	if(linked_incursion)
		linked_incursion.portal_list -= src

/obj/structure/spawner/nether/demon_incursion/on_mob_spawn(mob/created_mob)
	. = ..()
	created_mob.Move(get_step(created_mob.loc, pick(GLOB.alldirs)))

/obj/structure/spawner/nether/demon_incursion/attacked_by(obj/item/attacker, mob/living/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_SPAWNER_SET_TARGET, user)

/obj/structure/spawner/nether/demon_incursion/bullet_act(obj/item/projectile/P)
	. = ..()
	if(P.firer)
		SEND_SIGNAL(src, COMSIG_SPAWNER_SET_TARGET, P.firer)

/obj/structure/spawner/nether/demon_incursion/proc/spread()
	if(!prob(portal_spread_chance))
		expansion_delay = rand(portal_spread_cooldown_min, portal_spread_cooldown_max)
		addtimer(CALLBACK(src, PROC_REF(spread)), expansion_delay)
		return
	var/list/spawnable_turfs = list()
	for(var/turf/simulated/floor/possible_loc in orange(8, src.loc))
		if(!istype(possible_loc))
			continue
		if(possible_loc.is_blocked_turf(exclude_mobs = TRUE))
			continue
		if(locate(/obj/structure/spawner/nether/demon_incursion) in possible_loc)
			continue
		spawnable_turfs += possible_loc
	if(!spawnable_turfs)
		return
	var/turf/spawn_loc = pick_n_take(spawnable_turfs)
	linked_incursion.spawn_portal(spawn_loc)
	expansion_delay = rand(portal_spread_cooldown_min, portal_spread_cooldown_max)
	addtimer(CALLBACK(src, PROC_REF(spread)), expansion_delay)
	return

/obj/structure/spawner/nether/demon_incursion/proc/stop_initial_mobs()
	var/datum/component/spawner/spawn_comp = GetComponent(/datum/component/spawner)
	spawn_comp.spawn_time = spawn_rate
	spawn_time = spawn_rate
