//Cat
/mob/living/simple_animal/pet/cat
	name = "cat"
	ventcrawler = 1
	desc = "Kitty!!"
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	icon_resting = "cat2_rest"
	gender = MALE
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows", "mews")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	mob_size = MOB_SIZE_SMALL
	simplespecies = /mob/living/simple_animal/pet/cat
	childtype = /mob/living/simple_animal/pet/cat/kitten
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 3)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target
	var/eats_mice = 1

//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/simple_animal/pet/cat/Runtime
	name = "Runtime"
	desc = "Awww, it's Runtime, the CMO's friendly pet cat. Well, except when you rub the cat's belly."
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	icon_resting = "cat_rest"
	gender = FEMALE
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID

/mob/living/simple_animal/pet/cat/handle_automated_action()
	..()

	//MICE!
	if(eats_mice && loc && isturf(loc) && !incapacitated())
		for(var/mob/living/simple_animal/mouse/M in view(1,src))
			if(!M.stat && Adjacent(M))
				custom_emote(1, "splats \the [M]!")
				M.splat()
				movement_target = null
				stop_automated_movement = 0
				break

	//attempt to mate
	make_babies()

/mob/living/simple_animal/pet/cat/handle_automated_movement()
	..()
	if(eats_mice && !incapacitated())
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/mob/living/simple_animal/mouse/snack in oview(src,3))
					if(isturf(snack.loc) && !snack.stat)
						movement_target = snack
						break
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src,movement_target,0,3)

/mob/living/simple_animal/pet/cat/Proc
	name = "Proc"

/mob/living/simple_animal/pet/cat/kitten
	name = "kitten"
	desc = "D'aaawwww"
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	icon_resting = null
	gender = NEUTER
	density = 0
	pass_flags = PASSMOB

/mob/living/simple_animal/pet/cat/Syndi
	name = "SyndiCat"
	desc = "It's a SyndiCat droid."
	icon_state = "Syndicat"
	icon_living = "Syndicat"
	icon_dead = "Syndicat_dead"
	icon_resting = "Syndicat_rest"
	gender = FEMALE
	flags = NO_BREATHE
	faction = list("syndicate")
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	eats_mice = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	/mob/living/simple_animal/pet/cat/ascendant
		name = "Ascendant Cat"
		desc = "It appears this cat has ascended to a godlike form. It'd be best to stay on it's good side."
		health = 2000
		maxHealth = 2000
		unsuitable_atmos_damage = 0


	/mob/living/simple_animal/pet/cat/ascendant/Life()
		..()
		if(stat)
			return
		if(health < maxHealth)
			adjustBruteLoss(-2) //Some life regen. Not too much, but it should not be too easy to defeat, either.

	/mob/living/simple_animal/pet/cat/ascendant/New()
		. = ..()

		AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport/cat(null))
		AddSpell(new /obj/effect/proc_holder/spell/fireball/cat(null))
		AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/repulse/cat(null))
		AddSpell(new /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech/cat(null))
		AddSpell(new /obj/effect/proc_holder/spell/targeted/lightning/cat(null))
		AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock/cat(null))

	// Ascendant Spells. Slightly modified wizard spells, removing cooldowns and changing invocations. GODLIKE CREATURS DONT NEED COOLDOWNS!
	/obj/effect/proc_holder/spell/targeted/area_teleport/teleport/cat
		cooldown_min = 0
		charge_max = 5
		name = "Ascendant Warp"
		desc = "Allows you to warp across the station, into any room you wish."
		invocation = "MROWWW- *poof*"
		clothes_req = 0

	/obj/effect/proc_holder/spell/fireball/cat
		cooldown_min = 0
		charge_max = 5
		name = "Ascendant Fireball"
		desc = "This spell sends a fireball towards whatever unlucky thing called upon your wrath"
		invocation = "HSSSSSSS"
		clothes_req = 0

	/obj/effect/proc_holder/spell/aoe_turf/repulse/cat
		cooldown_min = 5
		charge_max = 5
		name = "Ascendant Shockwave"
		desc = "This spell sends anything near you tumbling away in a shockwave of pure energy"
		invocation = "MROWWW... HSSSSSSSSSSS!"
		clothes_req = 0

	/obj/effect/proc_holder/spell/targeted/emplosion/disable_tech/cat
		cooldown_min = 0
		charge_max = 5
		name = "Ascendant Overload"
		desc = "Overloads nearby technology"
		invocation = "MROWWW... mrowwww. MEOW!"
		clothes_req = 0

	/obj/effect/proc_holder/spell/targeted/lightning/cat
		cooldown_min = 0
		charge_max = 0
		name = "Ascendant Smite"
		desc = "Smite your foes with lightning!"
		invocation = "HSSSSS.... HSSSS!"
		clothes_req = 0

	/obj/effect/proc_holder/spell/aoe_turf/knock/cat
		cooldown_min = 0
		charge_max = 5
		name = "Ascendant Doorbell"
		desc = "Does the AI's main job for them."
		invocation = "Mrrow?"
		clothes_req = 0
