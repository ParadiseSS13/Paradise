/datum/event/spawn_irradiated_mouse
	name = "Irradiated Mouse Spawn"
	noAutoEnd = TRUE
	nominal_severity = EVENT_LEVEL_MODERATE
	role_weights = list(ASSIGNMENT_CREW = 1, ASSIGNMENT_MEDICAL = 5)
	role_requirements = list(ASSIGNMENT_CREW = 10, ASSIGNMENT_MEDICAL = 1)

/datum/event/spawn_irradiated_mouse/start()
	INVOKE_ASYNC(src, PROC_REF(spawn_mouse))

/datum/event/spawn_irradiated_mouse/proc/spawn_mouse()
	// poll for ghosts
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as an irradiated mouse?", ROLE_IRRADIATED_MOUSE, TRUE, source = /mob/living/basic/mouse/irradiated_mouse)
	if(!length(candidates))
		kill()
		return

	var/mob/candidate = pick(candidates)
	var/obj/vents = get_valid_vent_spawns(TRUE, TRUE, 3) // find an unwelded vent with nobody nearby
	if(!length(vents))
		message_admins("Warning: No suitable vents detected for spawning an irradiated mouse.")
		return

	// pick a vent and spawn a mouse inside of it
	var/obj/vent = pick(vents)
	var/mob/living/basic/mouse/irradiated_mouse/spawned_mouse = new /mob/living/basic/mouse/irradiated_mouse(vent.loc)
	spawned_mouse.forceMove(vent)
	spawned_mouse.add_ventcrawl(vent)

	// put the ghost inside the mouse
	spawned_mouse.ckey = candidate.ckey
	dust_if_respawnable(spawned_mouse)

	// objectives
	spawned_mouse.mind = new
	spawned_mouse.mind.bind_to(spawned_mouse)
	spawned_mouse.mind.set_original_mob(spawned_mouse)
	spawned_mouse.mind.wipe_memory()
	spawned_mouse.mind.assigned_role = SPECIAL_ROLE_IRRADIATED_MOUSE
	spawned_mouse.mind.special_role = SPECIAL_ROLE_IRRADIATED_MOUSE
	SSticker.mode.traitors |= spawned_mouse.mind

	// start sound + intro message
	SEND_SOUND(spawned_mouse, sound('sound/items/geiger/ext1.ogg'))
	spawned_mouse.mind.add_mind_objective(/datum/objective/irradiated_mouse_objective)
	spawned_mouse.give_intro_text()

/datum/objective/irradiated_mouse_objective
	explanation_text = "Punish the tall ones who have hunted you with mousetraps for so long!"
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
	melee_damage_lower = 3
	melee_damage_upper = 5
	appearance_flags = LONG_GLIDE | PIXEL_SCALE
	attack_verb_simple = "bites"
	attack_verb_continuous = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	/// How many times have we bitten a valid mob (for upgrades).
	var/mousebites = 0
	/// How many bites are required per available upgrade.
	var/mousebites_per_upgrade = 8
	/// How many additional mousebites required we require on every levelup
	var/mousebite_increment = 1
	/// How much health do we gain/restore per upgrade.
	var/health_increase = 20
	/// How much do we resize per level gained.
	var/resize_factor = 1.1

	var/available_upgrades = 0

	/// The highest level a spell may be upgraded.
	var/level_cap = 4
	var/radiation_upgrades = 0
	var/speed_upgrades = 0
	var/damage_upgrades = 0

	/// What type of radiation are we currently giving off.
	var/radiation_level = ALPHA_RAD
	/// How intense is our radiation?
	var/radiation_amount = 100

	/// How much speed is increased (bigger negative = faster).
	var/speed_per_level = -0.4

	/// How much damage is increased ever level.
	var/damage_per_level = 3

	/// How much does cheese heal us?
	var/cheese_heal = 2

	var/datum/spell/irradiated_mouse_spell/upgrade_radiation/upgrade_radiation_spell
	var/datum/spell/irradiated_mouse_spell/upgrade_speed/upgrade_speed_spell
	var/datum/spell/irradiated_mouse_spell/upgrade_damage/upgrade_damage_spell

/mob/living/basic/mouse/irradiated_mouse/Initialize(mapload)
	. = ..()
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])

	upgrade_radiation_spell = new()
	upgrade_speed_spell = new()
	upgrade_damage_spell = new()
	AddSpell(upgrade_radiation_spell)
	AddSpell(upgrade_speed_spell)
	AddSpell(upgrade_damage_spell)

// irradiate anyone we bite
/mob/living/basic/mouse/irradiated_mouse/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		contaminate_target(target, src, radiation_amount, radiation_level)
		if(ishuman(L) && L.mind && !(L.stat & DEAD)) // Only living, sentient crew should qualify for this
			mousebites++
		else
			to_chat(src, SPAN_WARNING("You wont be able to obtain any usable biomatter from this one."))
		if(mousebites >= mousebites_per_upgrade)
			mousebites -= mousebites_per_upgrade
			available_upgrades++

/mob/living/basic/mouse/irradiated_mouse/attack_hand(mob/living/carbon/human/M as mob)
	if(M.a_intent == INTENT_HELP)
		to_chat(M, SPAN_DANGER("Your hand burns as you try to grab onto the mouse!"))
		M.adjustFireLoss(5)
	..()

/mob/living/basic/mouse/irradiated_mouse/try_consume_cheese(obj/item/food/sliced/cheesewedge/cheese)

	visible_message(
		SPAN_NOTICE("[src] gorges on [cheese]."),
		SPAN_NOTICE("You gorge on [cheese][health < maxHealth ? ", restoring your health" : ""].")
	)

	qdel(cheese)

	// One can gorge on cheese without healing if they wish.
	if(health >= maxHealth)
		return
	adjustBruteLoss(-cheese_heal)

/mob/living/basic/mouse/irradiated_mouse/update_desc()
	. = ..()
	desc = initial(desc) // we dont want the standard description auto added by mice.

/mob/living/basic/mouse/irradiated_mouse/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Upgrades available:", "[format_si_suffix(available_upgrades)]")
	status_tab_data[++status_tab_data.len] = list("Bites until next upgrade:", "[format_si_suffix(mousebites_per_upgrade - mousebites)] bites")

/mob/living/basic/mouse/irradiated_mouse/proc/give_intro_text()
	var/list/messages = list()
	messages.Add(SPAN_USERDANGER("<center>You are an Irradiated Mouse!</center>"))
	messages.Add(SPAN_NOTICE("Due to your proximity to radioactive material laying around you've started rapidly mutating! You're slowly growing larger, meaner, and angrier! Its time to take it out on the crew for the years of being hunted by mousetraps!"))
	messages.Add(SPAN_SPECIALNOTICE("Your radioactive nature has made your body unstable! Bite crew to irradiate them and gain points towards useful upgrades."))
	messages.Add(SPAN_SPECIALNOTICE("Mindless bodies or corpses will not benefit you towards your upgrades."))
	messages.Add(SPAN_SPECIALNOTICE("As you upgrade yourself, you will slowly grow in size and health."))
	messages.Add(SPAN_SPECIALNOTICE("Be wary of mousetraps! They will kill you instantly."))
	messages.Add(mind.prepare_announce_objectives(FALSE))
	messages.Add(SPAN_MOTD("For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Irradiated_Mouse)"))
	to_chat(src, chat_box_red(messages.Join("<br>")))

/mob/living/basic/mouse/irradiated_mouse/proc/upgrade_radiation()
	radiation_upgrades++
	on_upgrade()
	radiation_amount += 100
	if(radiation_level < GAMMA_RAD)
		radiation_level = round_down(1 + (radiation_level / 2)) // One level up every two levels.
	if(!(radiation_level % 2))
		to_chat(src, SPAN_NOTICE("Your radiation becomes more lethal!"))

/mob/living/basic/mouse/irradiated_mouse/proc/upgrade_speed()
	speed_upgrades++
	on_upgrade()
	speed = initial(speed) + speed_per_level * speed_upgrades // This will tend towards a negative value (due to speed_per_level being negative) which is faster
	if(speed_upgrades == level_cap)
		RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement)) // Handles afterimages.

/mob/living/basic/mouse/irradiated_mouse/proc/upgrade_damage()
	damage_upgrades++
	on_upgrade()
	melee_damage_lower += damage_per_level
	melee_damage_upper = melee_damage_lower + 5
	if(damage_upgrades == level_cap) // Allows wall smashing at max level.
		environment_smash = ENVIRONMENT_SMASH_WALLS

/mob/living/basic/mouse/irradiated_mouse/proc/on_movement(mob/living/mob, atom/old_loc)
	if(stat != CONSCIOUS)
		return

	new /obj/effect/temp_visual/decoy/irradiated_mouse_afterimage(old_loc, mob)

/obj/effect/temp_visual/decoy/irradiated_mouse_afterimage
	duration = 0.75 SECONDS

/obj/effect/temp_visual/decoy/irradiated_mouse_afterimage/Initialize(mapload, atom/mimiced_atom)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = EASE_OUT) // Gradually fading out after image.

/mob/living/basic/mouse/irradiated_mouse/proc/on_upgrade()
	maxHealth += health_increase
	health += health_increase
	mousebites_per_upgrade += mousebite_increment
	update_health_hud()
	var/matrix/mouse_transform = matrix(transform)
	mouse_transform.Scale(resize_factor)
	animate(src, transform = mouse_transform, time = 1, pixel_y = pixel_y += 2, easing = EASE_IN|EASE_OUT)
	if(radiation_upgrades == level_cap && speed_upgrades == level_cap && damage_upgrades == level_cap)
		to_chat(src, SPAN_BOLDNOTICE("You feel like your fur is trying to slough off your body!"))
		AddSpell(new /datum/spell/mouse_sludge_ejection)
