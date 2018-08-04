/datum/species/unathi
	name = "Unathi"
	name_plural = "Unathi"
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	language = "Sinta'unathi"
	tail = "sogtail"
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	unarmed_type = /datum/unarmed_attack/claws
	primitive_form = /datum/species/monkey/unathi

	blurb = "A heavily reptillian species, Unathi (or 'Sinta as they call themselves) hail from the \
	Uuosa-Eso system, which roughly translates to 'burning mother'.<br/><br/>Coming from a harsh, radioactive \
	desert planet, they mostly hold ideals of honesty, virtue, martial combat and bravery above all \
	else, frequently even their own lives. They prefer warmer temperatures than most species and \
	their native tongue is a heavy hissing laungage called Sinta'Unathi."

	species_traits = list(LIPS)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_TAIL | HAS_HEAD_ACCESSORY | HAS_BODY_MARKINGS | HAS_HEAD_MARKINGS | HAS_SKIN_COLOR | HAS_ALT_HEADS | TAIL_WAGGING
	dietflags = DIET_CARN

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 140 //Default 120

	heat_level_1 = 380 //Default 360 - Higher is better
	heat_level_2 = 420 //Default 400
	heat_level_3 = 480 //Default 460

	flesh_color = "#34AF10"
	reagent_tag = PROCESS_ORG
	base_color = "#066000"
	//Default styles for created mobs.
	default_headacc = "Simple"
	default_headacc_colour = "#404040"
	butt_sprite = "unathi"
	brute_mod = 1.05

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver/unathi,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/unathi //3 darksight.
		)

	allowed_consumed_mobs = list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/lizard, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken,
								 /mob/living/simple_animal/crab, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/parrot, /mob/living/simple_animal/tribble)

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!")

	var/datum/action/innate/tail_lash/lash


/datum/species/unathi/on_species_gain(mob/living/carbon/human/H)
	..()
	lash = new
	lash.Grant(H)

/datum/species/unathi/on_species_loss(mob/living/carbon/human/H)
	..()
	if(lash)
		lash.Remove(H)

/datum/action/innate/tail_lash
	name = "Tail lash"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "tail"
	check_flags = AB_CHECK_LYING | AB_CHECK_CONSCIOUS | AB_CHECK_STUNNED

/datum/action/innate/tail_lash/Activate()
	var/mob/living/carbon/human/user = owner
	if((user.restrained() && user.pulledby) || user.buckled)
		to_chat(user, "<span class='warning'>You need freedom of movement to tail lash!</span>")
		return
	if(user.getStaminaLoss() >= 50)
		to_chat(user, "<span class='warning'>Rest before tail lashing again!</span>")
		return
	for(var/mob/living/carbon/human/C in orange(1))
		var/obj/item/organ/external/E = C.get_organ(pick("l_leg", "r_leg", "l_foot", "r_foot", "groin"))
		if(E)
			user.changeNext_move(CLICK_CD_MELEE)
			user.visible_message("<span class='danger'>[user] smacks [C] in [E] with their tail! </span>", "<span class='danger'>You hit [C] in [E] with your tail!</span>")
			user.adjustStaminaLoss(15)
			C.apply_damage(5, BRUTE, E)
			user.spin(20, 1)
			playsound(user.loc, 'sound/weapons/slash.ogg', 50, 0)
			add_attack_logs(user, C, "tail whipped")
			if(user.restrained())
				if(prob(50))
					user.Weaken(5)
					user.visible_message("<span class='danger'>[user] loses [user.p_their()] balance!</span>", "<span class='danger'>You lose your balance!</span>")
					return
			if(user.getStaminaLoss() >= 60) //Bit higher as you don't need to start, just would need to keep going with the tail lash.
				to_chat(user, "<span class='warning'>You run out of momentum!</span>")
				return



/datum/species/unathi/handle_death(mob/living/carbon/human/H)
	H.stop_tail_wagging(1)
