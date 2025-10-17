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
		/mob/living/simple_animal/hostile/poison/bees,
	)

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!")

	plushie_type = /obj/item/toy/plushie/red_fox

/datum/species/vulpkanin/handle_death(gibbed, mob/living/carbon/human/H)
	H.stop_tail_wagging()
