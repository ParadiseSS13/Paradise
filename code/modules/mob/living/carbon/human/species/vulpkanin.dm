#define VULP_WHITE rgb(200, 5, 65, space = COLORSPACE_HSL)
// Black and black dilutions
#define VULP_SILVER rgb(200, 10, 35, space = COLORSPACE_HSL)
#define VULP_BLUE rgb(200, 10, 20, space = COLORSPACE_HSL)
#define VULP_BLACK rgb(10, 30, 5, space = COLORSPACE_HSL)
// Red and red dilutions
#define VULP_LILAC rgb(15, 30, 30, space = COLORSPACE_HSL)
#define VULP_YELLOW rgb(25, 50, 45, space = COLORSPACE_HSL)
#define VULP_APRICOT rgb(20, 90, 30, space = COLORSPACE_HSL)
#define VULP_RED rgb(15, 80, 10, space = COLORSPACE_HSL)

/datum/species/vulpkanin
	name = "Vulpkanin"
	name_plural = "Vulpkanin"
	icobase = 'icons/mob/human_races/r_vulpkanin.dmi'
	language = "Canilunzt"
	primitive_form = /datum/species/monkey/vulpkanin
	tail = "vulptail"
	unarmed_type = /datum/unarmed_attack/claws

	blurb = "Vulpkanin are bipedal canid-like beings from the Vazzend binary system, having been forced from their homeworld by a cataclysmic event and scattered throughout the Orion Sector. \
	While Vulpkanin are chiefly led by independent planetary governments, they also serve under a loose federation known as The Assembly.<br/><br/> \
	Their religious systems traditionally pay tribute to an all-infusing universal will called 'Racht'. \
	Vulpkanin groups are minor players in galactic affairs, as they are largely concerned with the restoration of their homeworld."

	species_traits = list(LIPS)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_TAIL | TAIL_WAGGING | TAIL_OVERLAPPED | HAS_HEAD_ACCESSORY | HAS_MARKINGS | HAS_SKIN_COLOR
	dietflags = DIET_OMNI
	hunger_drain = 0.11
	taste_sensitivity = TASTE_SENSITIVITY_SHARP
	reagent_tag = PROCESS_ORG

	flesh_color = "#966464"
	base_color = "#CF4D2F"
	butt_sprite = "vulp"

	scream_verb = "yelps"

	meat_type = /obj/item/food/meat/human
	skinned_type = /obj/item/stack/sheet/fur
	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/vulpkanin,
		"lungs" =    /obj/item/organ/internal/lungs/vulpkanin,
		"liver" =    /obj/item/organ/internal/liver/vulpkanin,
		"kidneys" =  /obj/item/organ/internal/kidneys/vulpkanin,
		"brain" =    /obj/item/organ/internal/brain/vulpkanin,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/vulpkanin /*Most Vulpkanin see in full colour as a result of genetic augmentation, although it cost them their darksight (darksight = 2)
															unless they choose otherwise by selecting the colourblind disability in character creation (darksight = 8 but colourblind).*/
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

	plushie_type = /obj/item/toy/plushie/red_fox

/datum/species/vulpkanin/handle_death(gibbed, mob/living/carbon/human/H)
	H.stop_tail_wagging()

/datum/species/vulpkanin/generate_random_appearance(prosthesis_prob = 5)
	var/datum/character_save/appearance = new
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
	var/pattern = pickweight(list("points" = 3,
		"tiger" = 1, // make tiger pattern rarer, more of a tajaran thing
		"solid" = 3,
		"other" = 3))
	appearance.s_colour = randomize_body_color(pattern)
	var/secondary_body_color = get_color_counterpart(appearance.s_colour)

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
	appearance.body_accessory = null
	var/random_body_accessory = randomize_body_accessory(100, pattern)
	if(random_body_accessory != "None")
		appearance.body_accessory = random_body_accessory
	appearance.ha_style = randomize_head_accessory(100, pattern)
	appearance.hacc_colour = randomize_head_accessory_color("None", secondary_body_color)

	// Markings.
	appearance.m_styles["body"] = randomize_body_markings(100, pattern)
	appearance.m_colours["body"] = randomize_body_markings_color(appearance.m_styles["body"], secondary_body_color, appearance.s_tone)
	appearance.m_styles["head"] = randomize_head_markings(100, pattern)
	appearance.m_colours["head"] = randomize_head_markings_color(appearance.m_styles["head"], secondary_body_color)
	appearance.m_styles["tail"] = randomize_tail_markings(100, appearance.body_accessory ? appearance.body_accessory : null, pattern)
	appearance.m_colours["tail"] = randomize_tail_markings_color(appearance.m_styles["tail"], secondary_body_color)

	return appearance

/datum/species/vulpkanin/randomize_eye_color()
	return tint_color_hsl(pickweight(list(
		COLOR_BROWN_ORANGE = 40,
		COLOR_AMBER = 20,
		COLOR_BABY_BLUE = 15,
		COLOR_SILVER = 15,
		COLOR_PALE_BTL_GREEN = 9,
		rand_hex_color() = 1,
		)))

/datum/species/vulpkanin/randomize_body_color(pattern)
	if(prob(2))
		return rgb(rand(0, 360), rand(0, 90), rand(30, 50), space = COLORSPACE_HSL)
	var/list/possible_colors = list(VULP_SILVER, VULP_BLUE, VULP_BLACK, VULP_LILAC, VULP_YELLOW, VULP_APRICOT, VULP_RED)
	if(pattern == "solid")
		possible_colors += VULP_WHITE
	return pick(possible_colors)

/datum/species/vulpkanin/proc/get_color_counterpart(body_color)
	if(body_color == VULP_SILVER || body_color == VULP_BLUE || body_color == VULP_BLACK)
		return pick(VULP_LILAC, VULP_YELLOW, VULP_APRICOT, VULP_RED)
	if(body_color == VULP_LILAC || body_color == VULP_YELLOW || body_color == VULP_APRICOT || body_color == VULP_RED)
		return pick(VULP_SILVER, VULP_BLUE, VULP_BLACK)
	return VULP_WHITE

/datum/species/vulpkanin/randomize_hair_style(species_bald_prob = 40)
	return ..()

/datum/species/vulpkanin/randomize_hair_colors(datum/robolimb/robohead, body_color = VULP_BLACK, secondary_body_color = VULP_WHITE)
	var/list/hair_colors = list()
	if(prob(1))
		hair_colors["h1"] = rand_hex_color()
		if(prob(33))
			hair_colors["f1"] = pick(body_color, secondary_body_color)
		else if(prob(33))
			hair_colors["f1"] = rand_hex_color()
		else
			hair_colors["f1"] = hair_colors["h1"]
	else
		hair_colors["h1"] = pick(body_color, secondary_body_color)
		if(prob(1))
			hair_colors["f1"] = rand_hex_color()
		else
			hair_colors["f1"] = pick(body_color, secondary_body_color)
	hair_colors["h2"] = rand_hex_color()
	hair_colors["f2"] = rand_hex_color()

	return hair_colors

/datum/species/vulpkanin/randomize_body_accessory(prob_to_apply = 100, pattern = "other")
	if(pattern == "points")
		return pick("None", "Short Tail", "Straight Bushy Tail")
	if(pattern == "solid")
		return pick("None", "Bushy Tail", "Straight Bushy Tail", "Straight Tail", "Tiny Tail")
	return pick(list_valid_body_accessories(name))

/datum/species/vulpkanin/randomize_head_accessory(prob_to_apply = 100, pattern = "other")
	if(pattern == "points")
		return pick("Vulpkanin Nose", "Vulpkanin Nose Alt.")
	if(pattern == "solid")
		return "None"
	return pick(list_valid_head_accessories(name))

/datum/species/vulpkanin/randomize_head_accessory_color(head_accessory = "None", secondary_body_color = VULP_WHITE)
	return pick(secondary_body_color, VULP_WHITE)

/datum/species/vulpkanin/randomize_body_markings(prob_to_apply = 100, pattern = "other")
	if(pattern == "solid")
		return "None"
	if(pattern == "points")
		return pick(
		"Vulpkanin Points",
		"Vulpkanin Sharp Points",
		"Vulpkanin Points and Belly",
		"Vulpkanin Points and Belly Alt.",
		"Vulpkanin Points and Crest")
	if(pattern == "tiger")
		return "Tiger Body"
	var/list/possible_markings = list_valid_marking_styles("body", name)
	var/list/generic_markings = list_valid_marking_styles("body", "Human")
	var/list/exclusive_markings = possible_markings - generic_markings

	if(prob(50) && length(exclusive_markings))
		return pick(exclusive_markings - list("Tiger Body"))

	return pick(possible_markings - list("Tiger Body"))

/datum/species/vulpkanin/randomize_body_markings_color(body_markings = "None", secondary_body_color = VULP_WHITE, skin_tone = null)
	return pick(secondary_body_color, VULP_WHITE)

/datum/species/vulpkanin/randomize_head_markings(prob_to_apply = 100, pattern = "other")
	if(pattern == "solid")
		return "None"
	if(pattern == "points")
		return pick("Vulpkanin Points Head", "Vulpkanin Points Head 2")
	if(pattern == "tiger")
		return pick("Vulpkanin Tiger Head", "Vulpkanin Tiger Head and Face")
	return list_valid_marking_styles("head", name) - list("Vulpkanin Tiger Head", "Vulpkanin Tiger Head and Face")

/datum/species/vulpkanin/randomize_head_markings_color(head_markings = "None", secondary_body_color = VULP_WHITE)
	return pick(secondary_body_color, VULP_WHITE)

/datum/species/vulpkanin/randomize_tail_markings(prob_to_apply = 70, tail_type = null, pattern = "other")
	if(pattern == "solid")
		return "None"
	if(pattern == "points")
		if(tail_type == "Short Tail")
			return "Short Tail Tip"
		if(tail_type == "Straight Bushy Tail")
			return pick("Vulpkanin Bushy Straight Tail Fade", "Vulpkanin Bushy Straight Tail Tip")
		return pick("Vulpkanin Default Tail Fade", "Vulpkanin Default Tail Tip")

	return ..()

/datum/species/vulpkanin/randomize_tail_markings_color(tail_markings = "None", secondary_body_color = VULP_WHITE)
	return pick(secondary_body_color, VULP_WHITE)

#undef VULP_WHITE
#undef VULP_SILVER
#undef VULP_BLUE
#undef VULP_BLACK
#undef VULP_LILAC
#undef VULP_YELLOW
#undef VULP_APRICOT
#undef VULP_RED
