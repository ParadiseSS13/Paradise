/datum/species/skrell
	name = "Skrell"
	name_plural = "Skrell"
	max_age = 220 // they're just like space elves no way
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	language = "Qurvolious"
	primitive_form = /datum/species/monkey/skrell

	blurb = "Skrell are an amphibious species, that come from the planet Jargon 4, a humid planet filled with swamps and archipelagos. \
	Skrell are a highly advanced and logical race who live under the rule of the Qerr'Katish, the main governmental body.<br/><br/> \
	Skrell are herbivores and opulent in nature thanks to central tenets of the Skrellian religion. \
	While classically preferring diplomacy, the Skrell participate in the largest military alliance in the galaxy, the Solar-Central Compact."

	species_traits = list(LIPS, NO_HAIR)
	inherent_traits = list(TRAIT_NOFAT, TRAIT_WATERBREATH)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | HAS_BODY_MARKINGS | HAS_TAIL | TAIL_OVERLAPPED
	dietflags = DIET_HERB
	taste_sensitivity = TASTE_SENSITIVITY_DULL
	flesh_color = "#8CD7A3"
	blood_color = "#1D2CBF"
	base_color = "#38b661" //RGB: 56, 182, 97.
	default_hair_colour = "#38b661"
	eyes = "skrell_eyes_s"
	//Default styles for created mobs.
	default_hair = "Skrell Male Tentacles"
	reagent_tag = PROCESS_ORG
	butt_sprite = "skrell"

	meat_type = /obj/item/food/meat/human
	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/skrell,
		"lungs" =    /obj/item/organ/internal/lungs/skrell,
		"liver" =    /obj/item/organ/internal/liver/skrell,
		"kidneys" =  /obj/item/organ/internal/kidneys/skrell,
		"brain" =    /obj/item/organ/internal/brain/skrell,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/skrell, //Default darksight of 2.
		"headpocket" = /obj/item/organ/internal/headpocket
		)

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their thumbs into their eye sockets!",
		"is twisting their own neck!",
		"makes like a fish and suffocates!",
		"is strangling themselves with their own tendrils!")

	plushie_type = /obj/item/toy/plushie/skrellplushie

/datum/species/skrell/randomize_body_color()
	return rand_hex_color()

/datum/species/skrell/randomize_eye_color()
	return rgb(rand(200, 360), rand(70, 95), rand(0, 100), space = COLORSPACE_HSL)

/datum/species/skrell/randomize_hair_colors(datum/robolimb/robohead, body_color = COLOR_GRAY, skin_tone = null)
	var/list/hair_colors = list()

	// usually body color, sometimes hue variant, rarely fully random
	if(prob(80))
		hair_colors["h1"] = body_color
	else if(prob(80))
		hair_colors["h1"] = rgb(
			rand(0, 360),
			rgb2num(body_color, COLORSPACE_HSL)[2],
			rgb2num(body_color, COLORSPACE_HSL)[3],
			space = COLORSPACE_HSL)
	else
		hair_colors["h1"] = rand_hex_color()

	// usually matches body or hair color, sometimes hue variant, rarely fully random
	if(prob(80))
		if(prob(10))
			hair_colors["f1"] = rgb(
				rand(0, 360),
				rgb2num(body_color, COLORSPACE_HSL)[2],
				rgb2num(body_color, COLORSPACE_HSL)[3],
				space = COLORSPACE_HSL)
		else
			hair_colors["f1"] = body_color
	else if(prob(80))
		if(prob(10))
			hair_colors["f1"] = rgb(
				rand(0, 360),
				rgb2num(hair_colors["h1"], COLORSPACE_HSL)[2],
				rgb2num(hair_colors["h1"], COLORSPACE_HSL)[3],
				space = COLORSPACE_HSL)
		else
			hair_colors["f1"] = hair_colors["h1"]
	else
		hair_colors["f1"] = rand_hex_color()

	// accessory, if present, should be a contrasting color in hue and lightness
	var/contrasting_hue = rgb2num(hair_colors["h1"], COLORSPACE_HSL)[1]
	contrasting_hue += contrasting_hue < 180 ? 180 : -180
	var/darker = rgb2num(hair_colors["h1"], COLORSPACE_HSL)[3] > 50
	hair_colors["h2"] = tint_color_hsl(rgb(
		contrasting_hue,
		rand(10, 90),
		darker ? 10 : 90,
		space = COLORSPACE_HSL))

	// as above, should be contrasting color
	contrasting_hue = rgb2num(hair_colors["f1"], COLORSPACE_HSL)[1]
	contrasting_hue += contrasting_hue < 180 ? 180 : -180
	darker = rgb2num(hair_colors["f1"], COLORSPACE_HSL)[3] > 50
	hair_colors["f2"] = tint_color_hsl(rgb(
		contrasting_hue,
		rand(10, 90),
		darker ? 10 : 90,
		space = COLORSPACE_HSL))

	return hair_colors

/datum/species/skrell/randomize_body_markings(prob_to_apply = 15)
	return ..()

/datum/species/skrell/randomize_body_markings_color(body_markings = "None", body_color = null, skin_tone = null)
	return blood_color
