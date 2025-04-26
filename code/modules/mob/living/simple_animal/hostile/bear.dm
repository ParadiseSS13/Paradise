//Space bears!
/mob/living/simple_animal/hostile/bear
	name = "space bear"
	desc = "You don't need to be faster than a space bear, you just need to outrun your crewmates."
	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	icon_gib = "bear_gib"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak = list("RAWR!", "Rawr!", "GRR!", "Growl!")
	speak_emote = list("growls", "roars")
	emote_hear = list("rawrs", "grumbles", "grawls")
	emote_see = list("stares ferociously", "stomps")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/monstermeat/bearmeat = 5, /obj/item/clothing/head/bearpelt = 1)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	stop_automated_movement_when_pulled = FALSE
	maxHealth = 60
	health = 60
	obj_damage = 60
	melee_damage_lower = 20
	melee_damage_upper = 30
	attacktext = "mauls"
	friendly = "bear hugs"
	attack_sound = 'sound/weapons/genhit3.ogg'

	//Space bears aren't affected by atmos.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list("soviet")
	gold_core_spawnable = HOSTILE_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/hostile/bear/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE	//No drifting in space for space bears!

/mob/living/simple_animal/hostile/bear/black
	name = "black bear"
	icon_state = "black_bear"
	icon_living = "black_bear"
	icon_dead = "black_bear_dead"
	butcher_results = list(/obj/item/food/monstermeat/bearmeat = 5, /obj/item/clothing/head/bearpelt/black = 1)

/mob/living/simple_animal/hostile/bear/brown
	name = "brown bear"
	icon_state = "brown_bear"
	icon_living = "brown_bear"
	icon_dead = "brown_bear_dead"
	butcher_results = list(/obj/item/food/monstermeat/bearmeat = 5, /obj/item/clothing/head/bearpelt/brown = 1)

/mob/living/simple_animal/hostile/bear/polar
	name = "polar bear"
	desc = "Found in the most extreme climates, its insides won't protect you from that kind of cold."
	icon_state = "polar_bear"
	icon_living = "polar_bear"
	icon_dead = "polar_bear_dead"
	butcher_results = list(/obj/item/food/monstermeat/bearmeat = 5, /obj/item/clothing/head/bearpelt/polar = 1)

//SPACE BEARS! SQUEEEEEEEE~     OW! FUCK! IT BIT MY HAND OFF!!
/mob/living/simple_animal/hostile/bear/hudson
	name = "Hudson"
	desc = "Feared outlaw, this guy is one bad news bear." //I'm sorry...
	icon_state = "combat_bear"
	icon_living = "combat_bear"
	icon_dead = "combat_bear_dead"
	butcher_results = list(/obj/item/food/monstermeat/bearmeat = 5, /obj/item/clothing/head/bearpelt/brown = 1)

/mob/living/simple_animal/hostile/bear/hudson/Initialize(mapload)
	. = ..()
	var/unbearable_pun = pick("He's unbearably cute.", "It looks like he is a bearer of bad news.", "Sadly, he is bearly able to comprehend puns.")
	desc = "That's Hudson. " +  unbearable_pun // I am not sorry for this.
