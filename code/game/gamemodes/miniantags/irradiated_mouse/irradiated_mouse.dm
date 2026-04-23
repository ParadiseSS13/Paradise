/datum/event/spawn_irradiated_mouse
	name = "Irradiated Mouse Spawn"
	noAutoEnd = TRUE
	nominal_severity = EVENT_LEVEL_MODERATE
	role_weights = list(ASSIGNMENT_CREW = 1, ASSIGNMENT_MEDICAL = 5)
	role_requirements = list(ASSIGNMENT_CREW = 10, ASSIGNMENT_MEDICAL = 1)

/datum/event/spawn_irradiated_mouse/start()
	INVOKE_ASYNC(src, PROC_REF(spawn_mouse))

/datum/event/spawn_irradiated_mouse/proc/spawn_mouse()
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as an irradiated mouse?", ROLE_IRRADIATED_MOUSE, TRUE, source = /mob/living/basic/mouse/irradiated_mouse)
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
	spawned_mouse.mind.wipe_memory()
	spawned_mouse.mind.assigned_role = SPECIAL_ROLE_IRRADIATED_MOUSE
	spawned_mouse.mind.special_role = SPECIAL_ROLE_IRRADIATED_MOUSE
	SEND_SOUND(spawned_mouse, sound('sound/items/geiger/ext1.ogg'))
	spawned_mouse.mind.add_mind_objective(/datum/objective/irradiated_mouse_objective)
	spawned_mouse.give_intro_text()

/datum/objective/irradiated_mouse_objective
	explanation_text = "Enjoy the remainder of your life the best you can! Whether by gorging on cheese, pestering the crew or exploring the station."
	completed = TRUE
	needs_target = FALSE


/mob/living/basic/mouse/irradiated_mouse
	desc = "It's a small, disease-ridden rodent... Thats glowing?"
	maxHealth = 150
	health = 150
	butcher_results = list(/obj/item/food/meat = 1, /obj/item/stack/sheet/mineral/uranium = 1)
	gold_core_spawnable = NO_SPAWN
	minimum_survivable_temperature = 0
	initial_traits = list(TRAIT_SHOCKIMMUNE, TRAIT_AI_PAUSED, TRAIT_RADIMMUNE) // shock immune so you can chew on those yummy wires
	mouse_color = "green"
	icon_state = "mouse_green"
	a_intent = INTENT_HARM

	var/available_upgrades = 0
	var/upgrade_cooldown_in_seconds = 120
	var/radiation_upgrades = 0
	var/speed_upgrades = 0
	var/damage_upgrades = 0
	var/level_cap = 3

	var/alpha_rad = 0
	var/beta_rad = 0
	var/gamma_rad = 0
	var/alpha_rad_per_level = 500
	var/beta_rad_per_level = 500
	var/gamma_rad_per_level = 0
	var/radiation_cooldown = 0.1
	var/produce_radioactive_sludge = FALSE

	var/speed_per_level = -0.5
	var/speed_capstone_alpha = 50

	var/has_exited_vents = FALSE
	var/seconds_time_till_death = 60 * 15

	var/datum/spell/irradiated_mouse_spell/upgrade_radiation/upgrade_radiation_spell
	var/datum/spell/irradiated_mouse_spell/upgrade_speed/upgrade_speed_spell
	var/datum/spell/irradiated_mouse_spell/upgrade_damage/upgrade_damage_spell

/mob/living/basic/mouse/irradiated_mouse/Initialize(mapload)
	. = ..()
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])

	upgrade_radiation_spell = new
	upgrade_speed_spell = new
	upgrade_damage_spell = new
	AddSpell(upgrade_radiation_spell)
	AddSpell(upgrade_speed_spell)
	AddSpell(upgrade_damage_spell)

/mob/living/basic/mouse/irradiated_mouse/proc/give_intro_text()
	var/list/messages = list()
	messages.Add(SPAN_USERDANGER("<center>You are an Irradiated Mouse!</center>"))
	messages.Add(SPAN_NOTICE("<center>Due to radioactive material laying around you've started rapidly mutating! Unfortunately this comes at the cost of your life, [SPAN_BOLDNOTICE("once you exit the vents you will have 15 minutes to live.")]"))
	messages.Add(mind.prepare_announce_objectives(FALSE))
	messages.Add("<center>[SPAN_MOTD("For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Irradiated_Mouse) ")]</center>")
	to_chat(src, chat_box_red(messages.Join("<br>")))

/mob/living/basic/mouse/irradiated_mouse/remove_ventcrawl()
	. = ..()
	if(!has_exited_vents)
		upgrade_radiation()
		upgrade_speed()
		upgrade_damage()
	has_exited_vents = TRUE

/mob/living/basic/mouse/irradiated_mouse/Life(seconds, times_fired)
	. = ..()
	if(!has_exited_vents)
		return
	log_debug("health: [health] seconds: [seconds] available_upgrades: [available_upgrades] ([upgrade_cooldown_in_seconds])s")

	adjustBruteLoss(maxHealth * seconds / seconds_time_till_death)

	upgrade_cooldown_in_seconds -= seconds
	if(upgrade_cooldown_in_seconds <= 0)
		upgrade_cooldown_in_seconds += 120
		available_upgrades++
		to_chat(src, SPAN_NOTICE("You have [available_upgrades] upgrades available."))

	if(!produce_radioactive_sludge)
		return

	var/chance = 50 - (health/maxHealth * 50)  // more likely as health drops, fastest you can get this is after 6 minutes, giving a 20% spawn chance per 2 seconds
	if(prob(chance))
		new /obj/effect/decal/cleanable/radioactive_sludge(get_turf(src))


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

/datum/spell/irradiated_mouse_spell/
	action_background_icon_state = "bg_irradiated_mouse"
	clothes_req = FALSE
	base_cooldown = 5 SECONDS

/datum/spell/irradiated_mouse_spell/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/irradiated_mouse_spell/proc/has_upgrades(mob/living/basic/mouse/irradiated_mouse/user)
	if(!user.available_upgrades)
		to_chat(user, SPAN_WARN("You dont have any available upgrades"))
		return FALSE
	return TRUE

/datum/spell/irradiated_mouse_spell/upgrade_radiation
	name = "Upgrade Radiation"
	desc = "Upgrade the amount of radiation you emit. You will start producing radioactive sludge at level 3."
	action_icon_state = "irradiated_mouse_radiation"

/datum/spell/irradiated_mouse_spell/upgrade_radiation/cast(list/targets, mob/living/basic/mouse/irradiated_mouse/user)
	. = ..()
	if(!has_upgrades(user))
		return

	user.available_upgrades--
	user.upgrade_radiation()
	if(user.radiation_upgrades > user.level_cap)
		user.RemoveSpell(user.upgrade_radiation_spell)
		user.produce_radioactive_sludge = TRUE

/datum/spell/irradiated_mouse_spell/upgrade_speed
	name = "Upgrade Speed"
	desc = "Upgrade your speed. You will become semi-transparent at level 3."
	action_icon_state = "irradiated_mouse_speed"

/datum/spell/irradiated_mouse_spell/upgrade_speed/cast(list/targets, mob/living/basic/mouse/irradiated_mouse/user)
	. = ..()
	if(!has_upgrades(user))
		return

	user.available_upgrades--
	user.upgrade_speed()
	if(user.speed_upgrades > user.level_cap)
		user.RemoveSpell(user.upgrade_speed_spell)

/datum/spell/irradiated_mouse_spell/upgrade_damage
	name = "Upgrade Damage"
	desc = "Upgrade your damage. You will become able to damage walls and windows at level 3."
	action_icon_state = "irradiated_mouse_damage"

/datum/spell/irradiated_mouse_spell/upgrade_damage/cast(list/targets, mob/living/basic/mouse/irradiated_mouse/user)
	. = ..()
	if(!has_upgrades(user))
		return

	user.available_upgrades--
	user.upgrade_damage()
	if(user.damage_upgrades > user.level_cap)
		user.RemoveSpell(user.upgrade_damage_spell)

/mob/living/basic/mouse/irradiated_mouse/death(gibbed)
	DeleteComponentsType(/datum/component/inherent_radioactivity)
	. = ..()

/mob/living/basic/mouse/irradiated_mouse/proc/make_irradiated_mouse_antag()
	if(!mind)
		return

	SSticker.mode.traitors |= mind
