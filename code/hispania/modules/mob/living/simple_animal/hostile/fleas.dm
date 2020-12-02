/mob/living/simple_animal/hostile/poison/fleas
	name = "bunch of space fleas"
	desc = "It is a lot of space fleas."
	icon = 'icons/hispania/mob/animals.dmi'
	icon_state = "fleas"
	health = 5
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	harm_intent_damage = 0.1
	melee_damage_lower = 0.1
	melee_damage_upper = 0.1
	mob_size = MOB_SIZE_TINY
	obj_damage = 0
	faction = list("hostile")
	maxHealth = 5
	turns_per_move = 5
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	loot = list(/obj/effect/decal/cleanable/insectguts)
	del_on_death = 1
	a_intent = INTENT_HARM
	attacktext = "stings"
	attack_sound = 'sound/weapons/bite.ogg'
	var/venom_per_bite = 15

/mob/living/simple_animal/hostile/poison/fleas/AttackingTarget()
	. = ..()
	if(. && venom_per_bite > 0 && iscarbon(target) && (!client || a_intent == INTENT_HARM))
		var/mob/living/carbon/C = target
		var/inject_target = pick("chest", "head")
		if(C.can_inject(null, 0, inject_target, 0))
			C.reagents.add_reagent("infected_blood", venom_per_bite)

/mob/living/simple_animal/hostile/poison/fleas/borg
	name = "bunch of robot fleas"
	desc = "It is a lot of robot fleas."
	icon_state = "borg_fleas"
	health = 10
	maxHealth = 10
	loot = list(/obj/effect/decal/cleanable/liquid_fuel)
