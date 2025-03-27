/mob/living/simple_animal/hostile/scarybat
	name = "space bats"
	desc = "A swarm of cute little blood sucking bats that looks pretty pissed."
	icon = 'icons/mob/bats.dmi'
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_chance = 0
	turns_per_move = 3
	butcher_results = list(/obj/item/food/meat = 1)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	speed = 4
	maxHealth = 20
	health = 20
	mob_size = MOB_SIZE_TINY
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	emote_taunt = list("flutters")
	taunt_chance = 20

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

//	break_stuff_probability = 2

	faction = list("scarybat")
	gold_core_spawnable = HOSTILE_SPAWN

	initial_traits = list(TRAIT_FLYING)

/mob/living/simple_animal/hostile/scarybat/Initialize(mapload, mob/living/L)
	. = ..()
	if(istype(L))
		faction += "\ref[L]"

/mob/living/simple_animal/hostile/scarybat/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return ..()	//No drifting in space for space carp!	//original comments do not steal

/mob/living/simple_animal/hostile/scarybat/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(15))
			L.Stun(2 SECONDS)
			L.visible_message("<span class='danger'>\the [src] scares \the [L]!</span>")


//This mob is for the admin-only ancient vampire, DO NOT USE ELSEWHERE
/mob/living/simple_animal/hostile/scarybat/adminvampire
	name = "bat swarm"
	desc = "A swarm of vicious, angry-looking space bats."
	speed = 1
	harm_intent_damage = 25
	maxHealth = 300
	melee_damage_lower = 10
	melee_damage_upper = 30
	a_intent = INTENT_HARM
	pass_flags = PASSTABLE
	universal_speak = TRUE
	universal_understand = TRUE
	gold_core_spawnable = NO_SPAWN //badmin only
