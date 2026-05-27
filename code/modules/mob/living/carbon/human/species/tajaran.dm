#define TAJARAN_WHITE rgb(200, 5, 65, space = COLORSPACE_HSL)
#define TAJARAN_BLUE rgb(200, 10, 30, space = COLORSPACE_HSL)
#define TAJARAN_BLACK rgb(10, 40, 5, space = COLORSPACE_HSL)
#define TAJARAN_BROWN rgb(15, 80, 10, space = COLORSPACE_HSL)
#define TAJARAN_RED rgb(20, 90, 30, space = COLORSPACE_HSL)
#define TAJARAN_CREAM rgb(25, 40, 45, space = COLORSPACE_HSL)

/datum/species/tajaran
	name = "Tajaran"
	name_plural = "Tajaran"
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	language = "Siik'tajr"
	tail = "tajtail"
	unarmed_type = /datum/unarmed_attack/claws

	blurb = "Tajaran hail from the mineral-rich arctic moon of Ahdomai. \
	Currently a minor player within the Orion Sector, Adhomai is only loosely united by an alliance of Tajaran clans following their rebellion against the tyrannical Overseers.<br/><br/> \
	The teachings of S'randarr and solar iconography dominate their religious practices, \
	and Tajaran often speak in the third person due to the lack of first-person references in their native tongue."

	cold_level_1 = 240
	cold_level_2 = 180
	cold_level_3 = 100

	heat_level_1 = 340
	heat_level_2 = 380
	heat_level_3 = 440

	primitive_form = /datum/species/monkey/tajaran

	species_traits = list(LIPS)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_TAIL | HAS_HEAD_ACCESSORY | HAS_MARKINGS | HAS_SKIN_COLOR | TAIL_WAGGING | TAIL_OVERLAPPED
	dietflags = DIET_OMNI
	taste_sensitivity = TASTE_SENSITIVITY_SHARP
	reagent_tag = PROCESS_ORG

	flesh_color = "#b5a69b"
	base_color = "#424242"
	butt_sprite = "tajaran"

	meat_type = /obj/item/food/meat/human
	skinned_type = /obj/item/stack/sheet/fur
	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/tajaran,
		"lungs" =    /obj/item/organ/internal/lungs/tajaran,
		"liver" =    /obj/item/organ/internal/liver/tajaran,
		"kidneys" =  /obj/item/organ/internal/kidneys/tajaran,
		"brain" =    /obj/item/organ/internal/brain/tajaran,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/tajaran /*Most Tajara see in full colour as a result of genetic augmentation, although it cost them their darksight (darksight = 2)
															unless they choose otherwise by selecting the colourblind disability in character creation (darksight = 8 but colourblind).*/
		)

	allowed_consumed_mobs = list(
		/mob/living/basic/mouse,
		/mob/living/basic/chick,
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
			"r" = list("rr", "rrr", "rrrr")
		)
	autohiss_exempt = list("Siik'tajr")

	plushie_type = /obj/item/toy/plushie/grey_cat

/datum/species/tajaran/handle_death(gibbed, mob/living/carbon/human/H)
	H.stop_tail_wagging()

/datum/species/tajaran/generate_random_appearance(prosthesis_prob = 5, datum/character_save/appearance = null)
	if(!istype(appearance))
		appearance = new
	appearance.species = name

	// Gender.
	appearance.gender = randomize_gender()
	appearance.body_type = randomize_body_type(appearance.gender)

	// Prostheses / Alternate robotic parts
	if(prob(prosthesis_prob))
		var/list/prostheses = randomize_chassis_brands()
		for(var/organ_name in prostheses)
			var/datum/robolimb/one_prosthesis = prostheses[organ_name]
			appearance.organ_data[organ_name] = "cyborg"
			appearance.rlimb_data[organ_name] = one_prosthesis.company

	// This needs to go after prostheses
	var/datum/robolimb/robohead
	if(appearance.rlimb_data["head"] && (bodyflags & ALL_RPARTS))
		robohead = GLOB.all_robolimbs[appearance.rlimb_data["head"]]

	// Coloration.
	// Colors are almost all set in this proc, but other species procs are defined below to fail gracefully
	appearance.s_colour = randomize_body_color()
	var/secondary_body_color = TAJARAN_WHITE
	var/pattern = pick("points", "tiger", "patches", "solid", "other")
	if(pattern == "tiger")
		var/list/intermediary_color = rgb2num(appearance.s_colour, COLORSPACE_HSL)
		intermediary_color[3] = clamp(intermediary_color[3] - rand(10, 30), 0, 100)
		secondary_body_color = rgb(intermediary_color[1], intermediary_color[2], intermediary_color[3], space = COLORSPACE_HSL)
	if(appearance.s_colour == secondary_body_color)
		pattern = pick("points", "solid", "other")
		secondary_body_color = get_color_counterpart(TAJARAN_WHITE)
	if(prob(50) && appearance.body_type == FEMALE && pattern != "tiger") // torties
		secondary_body_color = get_color_counterpart(appearance.s_colour)

	// Eyes.
	appearance.e_colour = randomize_eye_color()

	// Hair.
	appearance.h_style = randomize_hair_style(robohead)
	appearance.f_style = randomize_facial_hair_style(robohead, gender = appearance.gender)
	var/list/hair_colors = randomize_hair_colors(robohead, appearance.s_colour, secondary_body_color)
	appearance.h_colour = hair_colors["h1"]
	appearance.h_sec_colour = hair_colors["h2"]
	appearance.f_colour = hair_colors["f1"]
	appearance.f_sec_colour = hair_colors["f2"]

	// Accessories.
	appearance.m_styles["tail"] = "None"
	appearance.body_accessory = randomize_body_accessory(100, pattern)
	appearance.ha_style = randomize_head_accessory(100, pattern)
	appearance.hacc_colour = secondary_body_color

	// Markings.
	appearance.m_styles["body"] = randomize_body_markings(100, pattern)
	appearance.m_colours["body"] = secondary_body_color
	appearance.m_styles["head"] = randomize_head_markings(100, null, pattern)
	appearance.m_colours["head"] = secondary_body_color
	appearance.m_styles["tail"] = randomize_tail_markings(100, appearance.body_accessory ? appearance.body_accessory : null, pattern)
	appearance.m_colours["tail"] = secondary_body_color

	return appearance

/datum/species/tajaran/randomize_eye_color()
	return tint_color_hsl(pickweight(list(
		COLOR_AMBER = 35,
		COLOR_PALE_BTL_GREEN = 35,
		COLOR_BABY_BLUE = 20,
		COLOR_BROWN_ORANGE = 9,
		rand_hex_color() = 1,
		)))

/datum/species/tajaran/randomize_body_color()
	return pick(
		TAJARAN_WHITE,
		TAJARAN_BLUE,
		TAJARAN_BLACK,
		TAJARAN_BROWN,
		TAJARAN_RED,
		TAJARAN_CREAM,
	)

/datum/species/tajaran/proc/get_color_counterpart(body_color)
	switch(body_color)
		if(TAJARAN_BLUE)
			return TAJARAN_CREAM
		if(TAJARAN_BLACK)
			return TAJARAN_RED
		if(TAJARAN_BROWN)
			return TAJARAN_RED
		if(TAJARAN_RED)
			return TAJARAN_BLACK
		if(TAJARAN_CREAM)
			return TAJARAN_BLUE
		if(TAJARAN_WHITE)
			return pick(
				TAJARAN_BLUE,
				TAJARAN_BLACK,
				TAJARAN_BROWN,
				TAJARAN_RED,
				TAJARAN_CREAM,
				)
	return TAJARAN_WHITE

/datum/species/tajaran/randomize_hair_style(species_bald_prob = 40)
	return ..()

/datum/species/tajaran/randomize_facial_hair_style(datum/robolimb/robohead, species_shaved_prob = 20, gender)
	if(gender != FEMALE || prob(20))
		return ..()
	return "None"

/datum/species/tajaran/randomize_hair_colors(datum/robolimb/robohead, body_color = null, secondary_body_color = null)
	var/list/hair_colors = list()
	if(!body_color)
		body_color = TAJARAN_WHITE
	if(!secondary_body_color)
		secondary_body_color = get_color_counterpart(body_color)
	if(prob(1))
		hair_colors["h1"] = pick(rand_hex_color())
		if(prob(33))
			hair_colors["f1"] = pick(body_color, secondary_body_color)
		else if(prob(33))
			hair_colors["f1"] = pick(rand_hex_color())
		else
			hair_colors["f1"] = hair_colors["h1"]
	else
		hair_colors["h1"] = pick(body_color, secondary_body_color)
		if(prob(1))
			hair_colors["f1"] = pick(rand_hex_color())
		else
			hair_colors["f1"] = pick(body_color, secondary_body_color)
	hair_colors["h2"] = pick(rand_hex_color())
	hair_colors["f2"] = pick(rand_hex_color())

	return hair_colors

/datum/species/tajaran/randomize_body_accessory(prob_to_apply = 100, pattern = "other")
	if(pattern == "points")
		return "Short Tail"
	if(pattern == "tiger")
		return pick("None", "Striped Tail")
	return pick("Short Tail", "Tiny Tail", "None")

/datum/species/tajaran/randomize_head_accessory(prob_to_apply = 100, pattern = "other")
	if(pattern == "solid")
		return "None"
	if(pattern == "points")
		return "Tajaran Ears"
	if(pattern == "tiger")
		return pick("Tajaran Outer Ears", "Tajaran Nose")
	if(pattern == "patches")
		return pick("Tajaran Ears", "Tajaran Muzzle", "Tajaran Nose", "Tajaran Outer Ears")
	return pick(list_valid_head_accessories(name))

/datum/species/tajaran/randomize_head_accessory_color(head_accessory = "None", body_color = TAJARAN_WHITE)
	if(body_color == TAJARAN_WHITE)
		return TAJARAN_BLACK
	return get_color_counterpart(body_color)

/datum/species/tajaran/randomize_body_markings(prob_to_apply = 100, pattern = "other")
	if(pattern == "solid")
		return "None"
	if(pattern == "points")
		return "Tajaran Points"
	if(pattern == "tiger")
		return "Tiger Body"
	if(pattern == "patches")
		return "Tajaran Patches"
	var/list/possible_markings = list_valid_marking_styles("body", name)
	var/list/generic_markings = list_valid_marking_styles("body", "Human")
	var/list/exclusive_markings = possible_markings - generic_markings

	return pick(exclusive_markings - list("Tajaran Points", "Tiger Body", "Tajaran Patches"))

/datum/species/tajaran/randomize_body_markings_color(body_markings = "None", body_color = TAJARAN_WHITE, skin_tone = null)
	if(body_color == TAJARAN_WHITE)
		return TAJARAN_BLACK
	return get_color_counterpart(body_color)

/datum/species/tajaran/randomize_head_markings(prob_to_apply = 100, alt_head, pattern = "other")
	switch(pattern)
		if("points")
			return "Tajaran Points Head"
		if("tiger")
			return pick("Tajaran Tiger Head and Face", "Tajaran Tiger Head")
		if("patches")
			return "Tajaran Patches Head"
		if("soild")
			return "None"
	return pick(list_valid_marking_styles("head", name) - list("Tajaran Tiger Head and Face", "Tajaran Tiger Head"))

/datum/species/tajaran/randomize_head_markings_color(head_markings = "None", body_color = TAJARAN_WHITE)
	if(body_color == TAJARAN_WHITE)
		return TAJARAN_BLACK
	return get_color_counterpart(body_color)

/datum/species/tajaran/randomize_tail_markings(prob_to_apply = 70, tail_type = null, pattern = "other")
	if(pattern == "points")
		return "Short Tail Tip"
	if(pattern == "tiger")
		return tail_type == null ? "Tajaran Tail Stripes" : "None"
	if(pattern == "solid")
		return "None"
	if(tail_type == "Short Tail" && prob(50))
		return "Short Tail Tip"
	return ..()

/datum/species/tajaran/randomize_tail_markings_color(tail_markings = "None", body_color = TAJARAN_WHITE)
	if(body_color == TAJARAN_WHITE)
		return TAJARAN_BLACK
	return get_color_counterpart(body_color)

#undef TAJARAN_WHITE
#undef TAJARAN_BLACK
#undef TAJARAN_BLUE
#undef TAJARAN_BROWN
#undef TAJARAN_RED
#undef TAJARAN_CREAM
