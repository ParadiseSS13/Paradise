/mob/living/simple_animal/hostile/drakehound_breacher
	name = "Drakehound Breacher"
	desc = "A unathi raider with a viscious streak."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "drakehound"
	icon_living = "drakehound"
	icon_dead = "drakehound_dead" // Does not actually exist. del_on_death.
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	speak_chance = 1
	turns_per_move = 3
	response_help = "pushes the"
	response_disarm = "shoves"
	response_harm = "slashes"
	speed = 0
	maxHealth = 100
	health = 100

	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	minbodytemp = 0

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speak_emote = list("hisses")
	loot = list(
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)
	del_on_death = TRUE
	faction = list("pirate")
	sentience_type = SENTIENCE_OTHER
	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/drakehound_breacher/Initialize(mapload)
	. = ..()
	if(prob(50))
		loot = list(
			/obj/item/salvage/loot/pirate,
			/obj/effect/decal/cleanable/blood/innards,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/gibspawner/generic,
			/obj/effect/gibspawner/generic)

/mob/living/simple_animal/hostile/drakehound_breacher/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/simple_animal/hostile/drakehound_breacher/ListTargetsLazy()
	return ListTargets()

/mob/living/simple_animal/hostile/drakehound_breacher/Aggro()
	. = ..()
	if(target)
		playsound(loc, 'sound/effects/unathihiss.ogg', 70, TRUE)
