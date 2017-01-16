/mob/living/simple_animal/hostile/scarybat
	name = "space bats"
	desc = "A swarm of cute little blood sucking bats that looks pretty pissed."
	icon = 'icons/mob/bats.dmi'
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	speak_chance = 0
	turns_per_move = 3
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 1)
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 4
	maxHealth = 20
	health = 20
	mob_size = MOB_SIZE_TINY
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

//	break_stuff_probability = 2

	faction = list("scarybat")
	var/mob/living/owner
	gold_core_spawnable = CHEM_MOB_SPAWN_HOSTILE

/mob/living/simple_animal/hostile/scarybat/New(loc, mob/living/L as mob)
	..()
	if(istype(L))
		owner = L

/mob/living/simple_animal/hostile/scarybat/Process_Spacemove(var/check_drift = 0)
	return ..()	//No drifting in space for space carp!	//original comments do not steal

/mob/living/simple_animal/hostile/scarybat/FindTarget()
	. = ..()
	if(.)
		custom_emote(1, "flutters towards [.]")

/mob/living/simple_animal/hostile/scarybat/Found(var/atom/A)//This is here as a potential override to pick a specific target if available
	if(istype(A) && A == owner)
		return 0
	return ..()

/mob/living/simple_animal/hostile/scarybat/CanAttack(var/atom/the_target)//This is here as a potential override to pick a specific target if available
	if(istype(the_target) && the_target == owner)
		return 0
	return ..()

/mob/living/simple_animal/hostile/scarybat/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(15))
			L.Stun(1)
			L.visible_message("<span class='danger'>\the [src] scares \the [L]!</span>")