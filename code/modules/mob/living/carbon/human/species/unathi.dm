/datum/species/unathi
	name = "Unathi"
	name_plural = "Unathi"
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	language = "Sinta'unathi"
	tail = "sogtail"
	speech_sounds = list('sound/voice/unathitalk.mp3', 'sound/voice/unathitalk2.mp3', 'sound/voice/unathitalk4.mp3')
	speech_chance = 33
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	unarmed_type = /datum/unarmed_attack/claws
	primitive_form = /datum/species/monkey/unathi

	brute_mod = 0.9
	heatmod = 0.8
	coldmod = 1.2
	hunger_drain = 0.13

	blurb = "A heavily reptillian species, Unathi (or 'Sinta as they call themselves) hail from the \
	Uuosa-Eso system, which roughly translates to 'burning mother'.<br/><br/>Coming from a harsh, radioactive \
	desert planet, they mostly hold ideals of honesty, virtue, martial combat and bravery above all \
	else, frequently even their own lives. They prefer warmer temperatures than most species and \
	their native tongue is a heavy hissing laungage called Sinta'Unathi."

	species_traits = list(LIPS, PIERCEIMMUNE)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_TAIL | HAS_HEAD_ACCESSORY | HAS_BODY_MARKINGS | HAS_HEAD_MARKINGS | HAS_SKIN_COLOR | HAS_ALT_HEADS | TAIL_WAGGING
	taste_sensitivity = TASTE_SENSITIVITY_SHARP

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 140 //Default 120

	heat_level_1 = 380 //Default 360 - Higher is better
	heat_level_2 = 420 //Default 400
	heat_level_3 = 480 //Default 460

	blood_species = "Unathi"
	flesh_color = "#34AF10"
	reagent_tag = PROCESS_ORG
	base_color = "#066000"
	//Default styles for created mobs.
	default_headacc = "Simple"
	default_headacc_colour = "#404040"
	butt_sprite = "unathi"
	male_scream_sound = "u_mscream"
	female_scream_sound = "u_fscream"
	male_sneeze_sound = 'sound/goonstation/voice/unathi/m_u_sneeze.ogg'
	female_sneeze_sound = 'sound/goonstation/voice/unathi/f_u_sneeze.ogg'

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/unathi,
		"lungs" =    /obj/item/organ/internal/lungs/unathi,
		"liver" =    /obj/item/organ/internal/liver/unathi,
		"kidneys" =  /obj/item/organ/internal/kidneys/unathi,
		"brain" =    /obj/item/organ/internal/brain/unathi,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/unathi //3 darksight.
		)

	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest),
		"groin" =  list("path" = /obj/item/organ/external/groin),
		"head" =   list("path" = /obj/item/organ/external/head),
		"l_arm" =  list("path" = /obj/item/organ/external/arm),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right),
		"l_leg" =  list("path" = /obj/item/organ/external/leg),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right),
		"l_hand" = list("path" = /obj/item/organ/external/hand),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right),
		"l_foot" = list("path" = /obj/item/organ/external/foot),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right),
		"tail" =   list("path" = /obj/item/organ/external/tail/unathi))

	allowed_consumed_mobs = list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/lizard, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken,
								 /mob/living/simple_animal/crab, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/parrot, /mob/living/simple_animal/tribble)

	suicide_messages = list(
		"пытается откусить себе язык!",
		"вонзает когти себе в глазницы!",
		"сворачивает себе шею!",
		"задерживает дыхание!")

	disliked_food = VEGETABLES | FRUIT | GRAIN | SUGAR | JUNKFOOD
	liked_food = MEAT | RAW | EGG | GROSS

/datum/action/innate/tail_lash
	name = "Взмах хвостом"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "tail"
	check_flags = AB_CHECK_LYING | AB_CHECK_CONSCIOUS | AB_CHECK_STUNNED

/datum/action/innate/tail_lash/Trigger()
	if(IsAvailable(show_message = TRUE))
		..()

/datum/action/innate/tail_lash/Activate()
	var/mob/living/carbon/human/user = owner
	if((user.restrained() && user.pulledby) || user.buckled)
		to_chat(user, "<span class='warning'>Вам нужно больше свободы движений для взмаха хвостом!</span>")
		return
	if(user.getStaminaLoss() >= 50)
		to_chat(user, "<span class='warning'>Передохните перед повторным взмахом хвоста!</span>")
		return
	for(var/mob/living/carbon/human/C in orange(1))
		var/obj/item/organ/external/E = C.get_organ(pick("l_leg", "r_leg", "l_foot", "r_foot", "groin"))

		if(E)
			user.changeNext_move(CLICK_CD_MELEE) //User бьет С в Е. Сука... С - это цель. Е - это орган.
			user.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] хлещет хвостом [C.declent_ru(ACCUSATIVE)] по [E.declent_ru(DATIVE)]! </span>", "<span class='danger'>[pluralize_ru(user.gender,"Ты хлещешь","Вы хлещете")] хвостом [C.declent_ru(ACCUSATIVE)] по [E.declent_ru(DATIVE)]!</span>")
			user.adjustStaminaLoss(15)
			C.apply_damage(5, BRUTE, E)
			user.spin(20, 1)
			playsound(user.loc, 'sound/weapons/slash.ogg', 50, 0)
			add_attack_logs(user, C, "tail whipped")
			if(user.restrained())
				if(prob(50))
					user.Weaken(2)
					user.visible_message("<span class='danger'>[user.declent_ru(NOMINATIVE)] теря[pluralize_ru(user.gender,"ет","ют")] равновесие!</span>", "<span class='danger'>[pluralize_ru(user.gender,"Ты теряешь","Вы теряете")] равновесие!</span>")
					return
			if(user.getStaminaLoss() >= 60) //Bit higher as you don't need to start, just would need to keep going with the tail lash.
				to_chat(user, "<span class='warning'>Вы выбились из сил!</span>")
				return

/datum/action/innate/tail_lash/IsAvailable(show_message = FALSE)
	. = ..()
	var/mob/living/carbon/human/user = owner
	if(!user.bodyparts_by_name["tail"])
		if(show_message)
			to_chat(user, "<span class='warning'>У вас НЕТ ХВОСТА!</span>")
		return FALSE
	if(!istype(user.bodyparts_by_name["tail"], /obj/item/organ/external/tail/unathi))
		if(show_message)
			to_chat(user, "<span class='warning'>У вас слабый хвост!</span>")
		return FALSE
	return .

/datum/species/unathi/handle_death(gibbed, mob/living/carbon/human/H)
	H.stop_tail_wagging()

/datum/species/unathi/ashwalker
	name = "Ash Walker"
	name_plural = "Ash Walkers"

	blurb = "Пеплоходцы — рептильные гуманоиды, по-видимому, родственные унати. Но кажутся значительно менее развитыми. \
	Они бродят по пустошам Лаваленда, поклоняются мёртвому городу и ловят ничего не подозревающих шахтёров."

	language = "Sinta'unathi"
	default_language = "Sinta'unathi"

	speed_mod = -0.80
	species_traits = list(NOGUNS)

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/unathi,
		"lungs" =    /obj/item/organ/internal/lungs/unathi/ash_walker,
		"liver" =    /obj/item/organ/internal/liver/unathi,
		"kidneys" =  /obj/item/organ/internal/kidneys/unathi,
		"brain" =    /obj/item/organ/internal/brain/unathi,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/unathi
		)

/datum/species/unathi/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_wag
	H.verbs |= /mob/living/carbon/human/proc/emote_swag
	H.verbs |= /mob/living/carbon/human/proc/emote_hiss
	H.verbs |= /mob/living/carbon/human/proc/emote_roar
	H.verbs |= /mob/living/carbon/human/proc/emote_threat
	H.verbs |= /mob/living/carbon/human/proc/emote_whip
	H.verbs |= /mob/living/carbon/human/proc/emote_whips
	var/datum/action/innate/tail_lash/lash = locate() in H.actions
	if(!lash)
		lash = new
		lash.Grant(H)

/datum/species/unathi/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_wag
	H.verbs -= /mob/living/carbon/human/proc/emote_swag
	H.verbs -= /mob/living/carbon/human/proc/emote_hiss
	H.verbs -= /mob/living/carbon/human/proc/emote_roar
	H.verbs -= /mob/living/carbon/human/proc/emote_threat
	H.verbs -= /mob/living/carbon/human/proc/emote_whip
	H.verbs -= /mob/living/carbon/human/proc/emote_whips

	var/datum/action/innate/tail_lash/lash = locate() in H.actions
	if(lash)
		lash.Remove(H)

/datum/species/unathi/handle_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	..()
	if(H.reagents.get_reagent_amount("zessulblood") < 5)         //unique unathi chemical, heals over time and increases shock reduction for 20
		H.reagents.add_reagent("zessulblood", 1)
	switch(H.bodytemperature)
		if(200 to 260)
			H.EyeBlurry(3)
			if(prob(5))
				to_chat(H, "<span class='danger'>Здесь холодно, голова раскалывается...</span>")
		if(0 to 200)
			H.AdjustDrowsy(3)
			//"anabiosis. unathi falls asleep if body temp is too low" (с) captainnelly
			//sorry Nelly, no anabiosis for ya without proper temperature regulation system
			if(prob(5) && H.bodytemperature <= 170)
				H.AdjustSleeping(2)
				to_chat(H, "<span class='danger'>Слишком холодно, я засыпаю...</span>")
		else
			return
