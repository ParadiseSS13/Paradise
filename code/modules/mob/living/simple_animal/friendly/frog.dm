/mob/living/simple_animal/frog
	name = "лягушка"
	real_name = "лягушка"
	desc = "Выглядит грустным не по средам и когда её не целуют."
	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "frog_dead"
	icon_resting = "frog"
	speak = list("Квак!","КУААК!","Квуак!")
	speak_emote = list("квак","куак","квуак")
	emote_hear = list("квак","куак","квуак")
	emote_see = list("лежит расслабленная", "увлажнена", "издает гортанные звуки", "лупает глазками")
	var/scream_sound = list ('sound/creatures/frog_scream_1.ogg','sound/creatures/frog_scream_2.ogg','sound/creatures/frog_scream_3.ogg')
	talk_sound = list('sound/creatures/frog_talk1.ogg', 'sound/creatures/frog_talk2.ogg')
	damaged_sound = list('sound/creatures/frog_damaged.ogg')
	death_sound = 'sound/creatures/frog_death.ogg'
	tts_seed = "pantheon"
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 10
	maxHealth = 10
	health = 10
	blood_volume = BLOOD_VOLUME_SURVIVE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/lizardmeat = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stamps on"
	density = 0
	ventcrawler = 2
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	layer = MOB_LAYER
	atmos_requirements = list("min_oxy" = 16, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_speak = 0
	can_hide = 1
	holder_type = /obj/item/holder/frog
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/frog/attack_hand(mob/living/carbon/human/M as mob)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
	..()

/mob/living/simple_animal/frog/Crossed(AM as mob|obj, oldloc)
	if(ishuman(AM))
		if(!stat)
			var/mob/M = AM
			to_chat(M, "<span class='notice'>[bicon(src)] квакнул!</span>")
	..()

/mob/living/simple_animal/frog/toxic
	name = "яркая лягушка"
	real_name = "яркая лягушка"
	desc = "Уникальная токсичная раскраска. Лучше не трогать голыми руками."
	icon_state = "rare_frog"
	icon_living = "rare_frog"
	icon_dead = "rare_frog_dead"
	icon_resting = "rare_frog"
	var/toxin_per_touch = 5
	var/toxin_type = "toxin"
	gold_core_spawnable = HOSTILE_SPAWN
	holder_type = /obj/item/holder/frog/toxic

/mob/living/simple_animal/frog/toxic/attack_hand(mob/living/carbon/human/H as mob)
	if(!istype(H.gloves, /obj/item/clothing/gloves))
		to_chat(H, "<span class='warning'>Дотронувшись до [src.name], ваша кожа начинает чесаться!</span>")
		toxin_affect(H)
		if(H.a_intent == INTENT_DISARM || H.a_intent == INTENT_HARM)
			..()
	else
		..()

/mob/living/simple_animal/frog/toxic/Crossed(AM as mob|obj, oldloc)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(!istype(H.shoes, /obj/item/clothing/shoes))
			toxin_affect(H)
			to_chat(H, "<span class='warning'>Ваши ступни начинают чесаться!</span>")
	..()

/mob/living/simple_animal/frog/toxic/proc/toxin_affect(mob/living/carbon/human/M as mob)
	if(M.reagents && !toxin_per_touch == 0)
		M.reagents.add_reagent(toxin_type, toxin_per_touch)

/mob/living/simple_animal/frog/scream
	name = "орущая лягушка"
	real_name = "орущая лягушка"
	desc = "Не любит когда на неё наступают. Используется в качестве наказания за проступки"
	var/squeak_sound = list ('sound/creatures/frog_scream1.ogg','sound/creatures/frog_scream2.ogg')
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/frog/scream/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, squeak_sound, 50, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a frog or whatever

/mob/living/simple_animal/frog/toxic/scream
	var/squeak_sound = list ('sound/creatures/frog_scream1.ogg','sound/creatures/frog_scream2.ogg')
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/frog/toxic/scream/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, squeak_sound, 50, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a frog or whatever

/mob/living/simple_animal/frog/handle_automated_movement()
	. = ..()
	if(!resting && !buckled)
		if(prob(1))
			custom_emote(1,"издаёт боевой клич!")
			playsound(src, pick(src.scream_sound), 50, TRUE)

/mob/living/simple_animal/frog/emote(act, m_type = 1, message = null, force)
	if(incapacitated())
		return

	var/on_CD = 0
	act = lowertext(act)
	switch(act)
		if("warcry")
			on_CD = handle_emote_CD()
		else
			on_CD = 0

	if(!force && on_CD == 1)
		return

	switch(act)
		if("warcry")
			message = "издаёт боевой клич!"
			m_type = 2 //audible
			playsound(src, pick(src.scream_sound), 50, TRUE)
		if("help")
			to_chat(src, "warcry")
	..()
