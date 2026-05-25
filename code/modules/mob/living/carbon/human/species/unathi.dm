/datum/species/unathi
	name = "Unathi"
	name_plural = "Unathi"
	article_override = "a"  // it's pronounced "you-nah-thee"
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	language = "Sinta'unathi"
	tail = "sogtail"
	unarmed_type = /datum/unarmed_attack/claws
	primitive_form = /datum/species/monkey/unathi

	blurb = "Unathi are a scaled species of reptilian beings from the desert world of Moghes, within the Uuosa-Eso system. \
	Organizing themselves in highly competitive feudal kingdoms, the Unathi lack any sort of wide-scale unification, and their culture and history consist of centuries of internal conflict and struggle.<br/><br/> \
	Despite clans having a sizeable military force, inter-clan rivalries and constant civil war prevent the Unathi from achieving much more in the wider galactic scene."

	species_traits = list(LIPS)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_REPTILE
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_TAIL | HAS_HEAD_ACCESSORY | HAS_BODY_MARKINGS | HAS_HEAD_MARKINGS | HAS_SKIN_COLOR | HAS_ALT_HEADS | TAIL_WAGGING | TAIL_OVERLAPPED
	dietflags = DIET_CARN
	taste_sensitivity = TASTE_SENSITIVITY_SHARP

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 140 //Default 120

	heat_level_1 = 505 //Default 360 - Higher is better
	heat_level_2 = 540 //Default 400
	heat_level_3 = 600 //Default 460

	flesh_color = "#34AF10"
	reagent_tag = PROCESS_ORG
	base_color = "#066000"
	//Default styles for created mobs.
	default_headacc = "Simple"
	default_headacc_colour = "#404040"
	male_scream_sound = 'sound/effects/unathiscream.ogg' // credits to skyrat [https://github.com/Skyrat-SS13/Skyrat-tg/pull/892]
	female_scream_sound = 'sound/effects/unathiscream.ogg'
	butt_sprite = "unathi"

	meat_type = /obj/item/food/meat/human
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/unathi,
		"lungs" =    /obj/item/organ/internal/lungs/unathi,
		"liver" =    /obj/item/organ/internal/liver/unathi,
		"kidneys" =  /obj/item/organ/internal/kidneys/unathi,
		"brain" =    /obj/item/organ/internal/brain/unathi,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/unathi //3 darksight.
		)
	allowed_consumed_mobs = list(
		/mob/living/basic/mouse,
		/mob/living/basic/lizard,
		/mob/living/basic/chick,
		/mob/living/basic/chicken,
		/mob/living/basic/crab,
		/mob/living/basic/butterfly,
		/mob/living/simple_animal/parrot,
		/mob/living/basic/bee,
		/mob/living/basic/isopod/small,
	)

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!")
	autohiss_basic_map = list(
			"s" = list("ss", "sss", "ssss")
		)
	autohiss_extra_map = list(
			"x" = list("ks", "kss", "ksss")
		)
	autohiss_exempt = list("Sinta'unathi")

	plushie_type = /obj/item/toy/plushie/lizardplushie

/datum/species/unathi/on_species_gain(mob/living/carbon/human/H)
	..()
	var/datum/action/innate/unathi_ignite/fire = new()
	fire.Grant(H)

/datum/species/unathi/on_species_loss(mob/living/carbon/human/H)
	..()
	for(var/datum/action/innate/unathi_ignite/fire in H.actions)
		fire.Remove(H)

/datum/action/innate/unathi_ignite
	name = "Ignite"
	desc = "A fire forms in your mouth, fierce enough to... light a cigarette. Requires you to drink welding fuel beforehand."
	button_icon = 'icons/obj/cigarettes.dmi'
	button_icon_state = "match_unathi"
	var/cooldown = 0
	var/cooldown_duration = 20 SECONDS
	var/welding_fuel_used = 3 //one sip, with less strict timing
	check_flags = AB_CHECK_HANDS_BLOCKED

/datum/action/innate/unathi_ignite/Activate()
	var/mob/living/carbon/human/user = owner
	if(world.time <= cooldown)
		to_chat(user, SPAN_WARNING("Your throat hurts too much to do it right now. Wait [round((cooldown - world.time) / 10)] seconds and try again."))
		return
	if(!welding_fuel_used || user.reagents.has_reagent("fuel", welding_fuel_used))
		if(ismask(user.wear_mask))
			var/obj/item/clothing/mask/worn_mask = user.wear_mask
			if((user.head?.flags_cover & HEADCOVERSMOUTH) || (worn_mask.flags_cover & MASKCOVERSMOUTH) && !worn_mask.up)
				to_chat(user, SPAN_WARNING("Your mouth is covered."))
				return
		var/obj/item/match/unathi/fire = new(user.loc, src)
		if(user.put_in_hands(fire))
			to_chat(user, SPAN_NOTICE("You ignite a small flame in your mouth."))
			user.reagents.remove_reagent("fuel", 50) //slightly high, but I'd rather avoid it being TOO spammable.
			cooldown = world.time + cooldown_duration
		else
			qdel(fire)
			to_chat(user, SPAN_WARNING("You don't have any free hands."))
	else
		to_chat(user, SPAN_WARNING("You need to drink welding fuel first."))

/datum/species/unathi/handle_death(gibbed, mob/living/carbon/human/H)
	H.stop_tail_wagging()

/datum/species/unathi/ashwalker
	name = "Ash Walker"
	name_plural = "Ash Walkers"
	sprite_sheet_name = "Unathi" // We have the same sprite sheets as unathi
	article_override = null

	blurb = "These reptillian creatures appear to be related to the Unathi, but seem significantly less evolved. \
	They roam the wastes of Lavaland, worshipping a dead city and capturing unsuspecting miners."

	default_language = "Sinta'unathi"

	speed_mod = -0.80
	species_traits = list(LIPS, NOT_SELECTABLE)
	inherent_traits = list(TRAIT_CHUNKYFINGERS)

	// same as unathi's organs, aside for the lungs as they need to be able to breathe on lavaland.
	has_organ = list(
		"heart"		= /obj/item/organ/internal/heart/unathi,
		"lungs"		= /obj/item/organ/internal/lungs/unathi/ash_walker,
		"liver"		= /obj/item/organ/internal/liver/unathi,
		"kidneys"	= /obj/item/organ/internal/kidneys/unathi,
		"brain"		= /obj/item/organ/internal/brain/unathi,
		"appendix"	= /obj/item/organ/internal/appendix,
		"eyes"		= /obj/item/organ/internal/eyes/unathi
	)

/datum/species/unathi/ashwalker/on_species_gain(mob/living/carbon/human/H)
	..()
	for(var/datum/action/innate/unathi_ignite/fire in H.actions)
		fire.Remove(H)
	var/datum/action/innate/unathi_ignite/ash_walker/fire = new()
	fire.Grant(H)
	H.faction |= "ashwalker"

/datum/species/unathi/ashwalker/on_species_loss(mob/living/carbon/human/H)
	..()
	for(var/datum/action/innate/unathi_ignite/ash_walker/fire in H.actions)
		fire.Remove(H)
	H.faction -= "ashwalker"

/datum/species/unathi/ashwalker/movement_delay(mob/living/carbon/human/H)
	. = ..()
	var/turf/our_turf = get_turf(H)
	if(!is_mining_level(our_turf.z))
		. -= speed_mod

/datum/action/innate/unathi_ignite/ash_walker
	desc = "You form a fire in your mouth, fierce enough to... light a cigarette."
	cooldown_duration = 3 MINUTES
	welding_fuel_used = 0 // Ash walkers dont need welding fuel to use ignite

/datum/species/unathi/randomize_body_color()
	if(prob(20))
		return rgb(rand(0, 150), rand(0, 20), rand(5, 10), space = COLORSPACE_HSL) // black-ish
	return rgb(rand(0, 150), rand(50, 95), rand(20, 30), space = COLORSPACE_HSL) // clay-ish

/datum/species/unathi/randomize_eye_color()
	if(prob(60))
		return ..()
	return tint_color_hsl(pick(COLOR_AMBER, COLOR_CULT_RED))

/datum/species/unathi/randomize_hair_style(datum/robolimb/robohead, species_bald_prob = 80)
	return ..()

/datum/species/unathi/randomize_facial_hair_style(datum/robolimb/robohead, species_shaved_prob = 40)
	return ..()

/datum/species/unathi/randomize_hair_colors(datum/robolimb/robohead, body_color = null, skin_tone = null)
	var/list/hair_colors = list()
	if(!body_color)
		body_color = COLOR_BROWN_ORANGE
	var/keratin_color = pick(COLOR_BEIGE, COLOR_GRAY15)
	for(var/hair_part in list("h1", "h2", "f1", "f2"))
		if(prob(1))
			hair_colors[hair_part] = rand_hex_color()
		else
			hair_colors[hair_part] = pick(body_color, keratin_color)

	return hair_colors

/datum/species/unathi/randomize_head_accessory(prob_to_apply = 90)
	return ..()

/datum/species/unathi/randomize_head_accessory_color(head_accessory = "None", body_color = null, hair_color = null)
	if(prob(90))
		return pick(COLOR_BEIGE, COLOR_GRAY15)
	if(prob(60))
		return hair_color
	return body_color

/datum/species/unathi/randomize_body_markings(prob_to_apply = 50)
	return ..()

/datum/species/unathi/randomize_body_markings_color(body_markings = "None", body_color = COLOR_BROWN_ORANGE, skin_tone = null)
	var/list/possible_markings = list_valid_marking_styles("body", name)
	var/list/generic_markings = list_valid_marking_styles("body", "Human")
	var/list/exclusive_markings = possible_markings - generic_markings

	if(body_markings in exclusive_markings)
		var/list/intermediary_color = rgb2num(body_color, COLORSPACE_HSL)
		intermediary_color[3] = clamp(intermediary_color[3] + rand(-30, 30), 0, 100)
		return rgb(intermediary_color[1], intermediary_color[2], intermediary_color[3], space = COLORSPACE_HSL)
	return ..()

/datum/species/unathi/randomize_head_markings(prob_to_apply = 50)
	return ..()

/datum/species/unathi/randomize_head_markings_color(head_markings = "None", body_color = null)
	if(!body_color)
		body_color = COLOR_BROWN_ORANGE

	var/list/intermediary_color = rgb2num(body_color, COLORSPACE_HSL)
	intermediary_color[3] = clamp(intermediary_color[3] + rand(-30, 30), 0, 100)
	return rgb(intermediary_color[1], intermediary_color[2], intermediary_color[3], space = COLORSPACE_HSL)
