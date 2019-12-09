/datum/species/vulpkanin
	name = "Vulpkanin"
	name_plural = "Vulpkanin"
	icobase = 'icons/mob/human_races/r_vulpkanin.dmi'
	deform = 'icons/mob/human_races/r_vulpkanin.dmi'
	language = "Canilunzt"
	primitive_form = /datum/species/monkey/vulpkanin
	tail = "vulptail"
	skinned_type = /obj/item/stack/sheet/fur
	unarmed_type = /datum/unarmed_attack/claws

	blurb = "Vulpkanin are a species of sharp-witted canine-pideds residing on the planet Altam just barely within the \
	dual-star Vazzend system. Their politically de-centralized society and independent natures have led them to become a species and \
	culture both feared and respected for their scientific breakthroughs. Discovery, loyalty, and utilitarianism dominates their lifestyles \
	to the degree it can cause conflict with more rigorous and strict authorities. They speak a guttural language known as 'Canilunzt' \
    which has a heavy emphasis on utilizing tail positioning and ear twitches to communicate intent."

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

	allowed_consumed_mobs = list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/lizard, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken,
								 /mob/living/simple_animal/crab, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/parrot, /mob/living/simple_animal/tribble)

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!")

/datum/species/vulpkanin/handle_death(gibbed, mob/living/carbon/human/H)
	H.stop_tail_wagging(1)