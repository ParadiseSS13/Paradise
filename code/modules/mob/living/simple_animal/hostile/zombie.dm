/mob/living/simple_animal/hostile/zombie
	name = "zombie"
	icon = 'icons/mob/human.dmi'
	icon_state = "zombie_s"
	icon_living = "zombie_s"
	icon_dead = "zombie_l"
	response_help = "gently prods"
	response_disarm = "shoves"
	response_harm = "bites"
	speed = 1
	maxHealth = 400
	health = 400
	harm_intent_damage = 20
	obj_damage = 30
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "bites"
	speak_emote = list("screams")
	a_intent = INTENT_HARM
	attack_sound = 'sound/hallucinations/growl1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	heat_damage_per_tick = 20
	pressure_resistance = 50
	throw_pressure_limit = 60
	faction = list("hostile")
	status_flags = CANPUSH
	minbodytemp = 0
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	death_sound = 'sound/hallucinations/growl1.ogg'
	deathmessage = "explodes in a lot of blood"
	var/poison_per_bite = 10
	var/poison_type = "virush"

/mob/living/simple_animal/hostile/zombie/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent("virush", poison_per_bite)
			if(prob(poison_per_bite))
				to_chat(L, "<span class='danger'>You feel a lot of pain.</span>")
				L.reagents.add_reagent(poison_type, poison_per_bite)