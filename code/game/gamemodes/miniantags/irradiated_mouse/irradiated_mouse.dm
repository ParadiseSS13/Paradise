/datum/event/spawn_irradiated_mouse
	name = "Irradiated Mouse Spawn"
	noAutoEnd = TRUE
	nominal_severity = EVENT_LEVEL_MODERATE
	role_weights = list(ASSIGNMENT_CREW = 1, ASSIGNMENT_MEDICAL = 5)
	role_requirements = list(ASSIGNMENT_CREW = 10, ASSIGNMENT_MEDICAL = 1)

/datum/event/spawn_irradiated_mouse/start()
	INVOKE_ASYNC(src, PROC_REF(spawn_mouse))

/datum/event/spawn_irradiated_mouse/proc/spawn_mouse()
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as an irradiated mouse?", ROLE_IRRADIATED_MOUSE, TRUE, source = /mob/living/basic/mouse/)
	if(!length(candidates))
		kill()
		return
	var/mob/candidate = pick(candidates)
	//var/datum/mind/player_mind = new /datum/mind(candidate.key)
	var/obj/vents = get_valid_vent_spawns(TRUE, TRUE, 0)
	if (!length(vents))
		message_admins("Warning: No suitable vents detected for spawning an irradiated mouse.")
		return
	var/obj/vent = pick(vents)
	var/mob/living/basic/mouse/irradiated_mouse/spawned_mouse = new /mob/living/basic/mouse/irradiated_mouse(vent.loc)
	spawned_mouse.forceMove(vent)
	spawned_mouse.add_ventcrawl(vent)

	spawned_mouse.ckey = candidate.ckey
	dust_if_respawnable(spawned_mouse)
	spawned_mouse.mind = new
	spawned_mouse.mind.bind_to(spawned_mouse)
	spawned_mouse.mind.set_original_mob(spawned_mouse)






/mob/living/basic/mouse/irradiated_mouse
	desc = "It's a small, disease-ridden rodent... Thats glowing?"
	maxHealth = 150
	health = 150
	butcher_results = list(/obj/item/food/meat = 1, /obj/item/stack/sheet/mineral/uranium = 1)
	gold_core_spawnable = NO_SPAWN
	minimum_survivable_temperature = 0
	initial_traits = (TRAIT_SHOCKIMMUNE, TRAIT_AI_PAUSED) // shock immune so you can chew on those yummy wires
	var/radiation_upgrades = 0
	var/speed_upgrades = 0
	var/damage_upgrades = 0
	var/level_cap = 3
	var/alpha_rad = 0
	var/beta_rad = 0
	var/gamma_rad = 0
	var/alpha_rad_per_level = 200
	var/beta_rad_per_level = 100
	var/gamma_rad_per_level = 0
	var/radiation_cooldown = 0.1
	var/speed_per_level = -0.5
	var/speed_capstone_alpha = 100

/mob/living/basic/mouse/irradiated_mouse/Initialize(mapload)
	. = ..()
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])

	upgrade_radiation()
	upgrade_speed()
	upgrade_damage()

/mob/living/basic/mouse/irradiated_mouse/proc/upgrade_radiation()
	radiation_upgrades++
	alpha_rad = alpha_rad_per_level * radiation_upgrades
	beta_rad = beta_rad_per_level * radiation_upgrades
	gamma_rad = gamma_rad_per_level * radiation_upgrades

	DeleteComponentsType(/datum/component/inherent_radioactivity)
	AddComponent(/datum/component/inherent_radioactivity, alpha_rad, beta_rad, gamma_rad, radiation_cooldown)

/mob/living/basic/mouse/irradiated_mouse/proc/upgrade_speed()
	speed_upgrades++
	speed = initial(speed) + speed_per_level * speed_upgrades
	if(speed_upgrades > level_cap)
		alpha = speed_capstone_alpha

/mob/living/basic/mouse/irradiated_mouse/proc/upgrade_damage()
	damage_upgrades++
	melee_damage_lower = damage_upgrades * 5
	melee_damage_upper = melee_damage_lower + 5
	if(damage_upgrades > level_cap)
		environment_smash = ENVIRONMENT_SMASH_WALLS

/mob/living/basic/mouse/irradiated_mouse/proc/make_irradiated_mouse_antag()
	if(!mind)
		return
	mind.wipe_memory()
	mind.assigned_role = SPECIAL_ROLE_IRRADIATED_MOUSE
	mind.special_role = SPECIAL_ROLE_IRRADIATED_MOUSE
	SSticker.mode.traitors |= mind
