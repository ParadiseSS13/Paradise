//Space bears!
/mob/living/simple_animal/hostile/bear
	name = "space bear"
	desc = "You don't need to be faster than a space bear, you just need to outrun your crewmates."
	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	icon_gib = "bear_gib"
	speak = list("RAWR!","Rawr!","GRR!","Growl!")
	speak_emote = list("growls", "roars")
	emote_hear = list("rawrs","grumbles","grawls")
	emote_see = list("stares ferociously", "stomps")
	tts_seed = "Shaker"
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/bearmeat= 5, /obj/item/clothing/head/bearpelt = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	stop_automated_movement_when_pulled = 0
	maxHealth = 60
	health = 60
	blood_volume = BLOOD_VOLUME_NORMAL
	obj_damage = 60
	melee_damage_lower = 20
	melee_damage_upper = 30
	attacktext = "терзает"
	death_sound = 'sound/creatures/bear_death.ogg'
	talk_sound = list('sound/creatures/bear_talk1.ogg', 'sound/creatures/bear_talk2.ogg', 'sound/creatures/bear_talk3.ogg')
	damaged_sound = list('sound/creatures/bear_onerawr1.ogg', 'sound/creatures/bear_onerawr2.ogg', 'sound/creatures/bear_onerawr3.ogg')
	var/trigger_sound = 'sound/creatures/bear_rawr.ogg'
	friendly = "bear hugs"
	attack_sound = 'sound/weapons/genhit3.ogg'
	footstep_type = FOOTSTEP_MOB_CLAW

	//Space bears aren't affected by atmos.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list("russian")
	gold_core_spawnable = HOSTILE_SPAWN

/mob/living/simple_animal/hostile/bear/handle_automated_movement()
	if(..())
		playsound(src, src.trigger_sound, 40, 1)

//SPACE BEARS! SQUEEEEEEEE~     OW! FUCK! IT BIT MY HAND OFF!!
/mob/living/simple_animal/hostile/bear/Hudson
	name = "Hudson"
	desc = "Feared outlaw, this guy is one bad news bear." //I'm sorry...

/mob/living/simple_animal/hostile/bear/Hudson/New()
	..()
	var/unbearable_pun = pick("He's unbearably cute.", "It looks like he is a bearer of bad news.", "Sadly, he is bearly able to comprehend puns.")
	desc = "That's Hudson. " +  unbearable_pun// I am not sorry for this.

/mob/living/simple_animal/hostile/bear/Move()
	..()
	if(stat != DEAD)
		if(loc && istype(loc,/turf/space))
			icon_state = "[icon_living]"
		else
			icon_state = "[icon_living]floor"

/mob/living/simple_animal/hostile/bear/Process_Spacemove(var/movement_dir = 0)
	return 1	//No drifting in space for space bears!

/mob/living/simple_animal/hostile/bear/brown
	icon_state = "brownbear"
	icon_living = "brownbear"
	icon_dead = "brownbear_dead"
	icon_gib = "brownbear_gib"
