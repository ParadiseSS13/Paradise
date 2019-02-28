/mob/living/simple_animal/hostile/zombie
	name = "Weak zombie"
	icon = 'icons/mob/human.dmi'
	icon_state = "zombie_s"
	icon_living = "zombie_s"
	icon_dead = "zombie_l"
	response_help = "gently prods"
	response_disarm = "shoves"
	response_harm = "bites"
	speed = 1
	turns_per_move = 2
	maxHealth = 30
	health = 30
	loot = list(/obj/effect/decal/cleanable/blood/gibs/)
	harm_intent_damage = 10
	obj_damage = 20
	melee_damage_lower = 7
	melee_damage_upper = 10
	attacktext = "bites"
	speak_emote = list("screams")
	universal_speak = 0
	universal_understand = 0
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
	see_in_dark = 0
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

/mob/living/simple_animal/hostile/zombie/Login()
	..()
	to_chat(src, "<b>You are a zombie, a new biological weapon. Your brain is dead and You only think about infecting and eating living people. Silicon are not living people, but you must destroy them if they try to hurt you.</b>")
