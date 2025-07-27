/mob/living/basic/scarybat
	name = "space bats"
	desc = "A swarm of cute little blood sucking bats that looks pretty pissed."
	icon = 'icons/mob/bats.dmi'
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	butcher_results = list(/obj/item/food/meat = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	speed = 4
	maxHealth = 20
	health = 20
	mob_size = MOB_SIZE_TINY
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attack_sound = 'sound/weapons/bite.ogg'
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0

	faction = list("scarybat")
	gold_core_spawnable = HOSTILE_SPAWN

	initial_traits = list(TRAIT_FLYING)

/mob/living/basic/scarybat/Initialize(mapload, mob/living/L)
	. = ..()
	AddComponent(/datum/component/aggro_emote, emote_list = list("flutters"), emote_chance = 20)
	if(istype(L))
		faction += "\ref[L]"

/mob/living/basic/scarybat/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	var/mob/living/L = target
	if(istype(L))
		if(prob(15))
			L.Stun(2 SECONDS)
			L.visible_message("<span class='danger'>\the [src] scares \the [L]!</span>")


// This mob is for the admin-only ancient vampire, DO NOT USE ELSEWHERE
/mob/living/basic/scarybat/adminvampire
	name = "bat swarm"
	desc = "A swarm of vicious, angry-looking space bats."
	speed = 1
	harm_intent_damage = 25
	maxHealth = 300
	melee_damage_upper = 30
	a_intent = INTENT_HARM
	pass_flags = PASSTABLE
	universal_speak = TRUE
	universal_understand = TRUE
	gold_core_spawnable = NO_SPAWN // badmin only
