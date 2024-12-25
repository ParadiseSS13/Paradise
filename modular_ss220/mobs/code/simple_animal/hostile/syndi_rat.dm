/mob/living/simple_animal/hostile/retaliate/syndirat
	name = "Синди-мышь"
	desc = "Мышь на службе синдиката?"
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	icon_state = "syndirat"
	icon_living = "syndirat"
	icon_dead = "syndirat_dead"
	icon_resting = "syndirat_sleep"
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "stamps on the"
	health = 50
	maxHealth = 50
	speak_chance = 2
	turns_per_move = 5
	pull_force = 1000
	density = 0
	ventcrawler = 2
	can_hide = 1
	can_collar = 1
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	see_in_dark = 6
	speak = list("Слава Синдикату!","Смерть НаноТрейзен!", "У вас есть сыр?")
	speak_emote = list("squeeks","squeaks","squiks")
	emote_hear = list("squeeks","squeaks","squiks")
	emote_see = list("runs in a circle", "shakes", "scritches at something")

	mob_size = MOB_SIZE_TINY // If theyre not at least small it doesnt seem like the treadmill works or makes sound
	pass_flags = PASSTABLE
	stop_automated_movement = 1

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	ranged =  1
	projectiletype = /obj/item/projectile/beam/disabler

	attack_sound = 'sound/weapons/punch1.ogg'
	talk_sound = list('modular_ss220/mobs/sound/creatures/rat_talk.ogg')
	damaged_sound = list('modular_ss220/mobs/sound/creatures/rat_wound.ogg')
	death_sound = 'modular_ss220/mobs/sound/creatures/rat_death.ogg'

	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	var/chew_probability = 1
	var/squeak_sound = 'sound/creatures/mousesqueak.ogg'

/mob/living/simple_animal/hostile/retaliate/syndirat/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/creatures/mousesqueak.ogg' = 1), 100, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a mouse or whatever

/mob/living/simple_animal/hostile/retaliate/syndirat/handle_automated_action()
	if(prob(chew_probability) && isturf(loc))
		var/turf/simulated/floor/F = get_turf(src)
		if(istype(F) && !F.intact)
			var/obj/structure/cable/C = locate() in F
			if(C && prob(15))
				if(C.get_available_power() && !HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
					visible_message(span_warning("[src] chews through [C]. It's toast!"))
					playsound(src, 'sound/effects/sparks2.ogg', 100, 1)
					toast() // mmmm toasty.
				else
					visible_message(span_warning("[src] chews through [C]."))
				investigate_log("was chewed through by a mouse at [COORD(F)]", "wires")
				C.deconstruct()

/mob/living/simple_animal/hostile/retaliate/syndirat/proc/toast()
	add_atom_colour("#3A3A3A", FIXED_COLOUR_PRIORITY)
	desc = "It's toast."
	death()

/mob/living/simple_animal/hostile/retaliate/syndirat/handle_automated_speech()
	..()
	if(prob(speak_chance) && !incapacitated())
		playsound(src, squeak_sound, 100, 1)

/mob/living/simple_animal/hostile/retaliate/syndirat/handle_automated_movement()
	. = ..()
	if(resting)
		if(prob(1))
			on_standing_up()
		else if(prob(5))
			custom_emote(2, "snuffles")
	else if(prob(0.5))
		on_lying_down()

/mob/living/simple_animal/hostile/retaliate/syndirat/Crossed(AM as mob|obj, oldloc)
	if(ishuman(AM))
		if(!stat)
			var/mob/M = AM
			to_chat(M, span_notice("[bicon(src)] Squeek!"))
	..()

/mob/living/simple_animal/hostile/retaliate/syndirat/emote(emote_key, type_override = 1, message, intentional, force_silence)
	if(stat != CONSCIOUS)
		return

	var/on_CD = 0
	emote_key = lowertext(emote_key)
	switch(emote_key)
		if("squeak")		//Mouse time
			on_CD = start_audio_emote_cooldown()
		else
			on_CD = 0

	if(!force_silence && on_CD == 1)
		return

	switch(emote_key)
		if("squeak")
			message = "[pick(emote_hear)]!"
			type_override = 2 //audible
			playsound(src, squeak_sound, 40, 1)
		if("help")
			to_chat(src, "scream, squeak")

	..()
