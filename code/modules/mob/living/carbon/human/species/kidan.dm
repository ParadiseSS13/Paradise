/datum/species/kidan
	name = "Kidan"
	name_plural = "Kidan"
	icobase = 'icons/mob/human_races/r_kidan.dmi'
	language = "Chittin"
	meat_type = /obj/item/food/meat/human

	blurb = "The Kidan are ant-like beings possessing a hardened exoskeleton and strict adherence to social castes. \
	They originate from the planet Aurum — a barren bombarded world that suffered after the war with the Solar-Central Compact, having lost decisively after the Battle of Argos.<br/><br/> \
	They are relatively minor players in galactic affairs and presently suffer heavy sanctions from the SCC, \
	though they are tentatively re-establishing relations with other galactic powers, even after the crumbling of their once powerful empire."
	unarmed_type = /datum/unarmed_attack/claws

	brute_mod = 0.8
	hunger_drain = 0.15
	tox_mod = 1.7

	species_traits = list(NO_HAIR)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_BUG
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_HEAD_ACCESSORY | HAS_HEAD_MARKINGS | HAS_BODY_MARKINGS | HAS_BODYACC_COLOR | SHAVED
	eyes = "kidan_eyes_s"
	dietflags = DIET_HERB
	flesh_color = "#ba7814"
	blood_color = "#FB9800"
	reagent_tag = PROCESS_ORG
	//Default styles for created mobs.
	default_headacc = "Normal Antennae"
	butt_sprite = "kidan"

	meat_type = /obj/item/food/meat/human
	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/kidan,
		"lungs" =    /obj/item/organ/internal/lungs/kidan,
		"liver" =    /obj/item/organ/internal/liver/kidan,
		"kidneys" =  /obj/item/organ/internal/kidneys/kidan,
		"brain" =    /obj/item/organ/internal/brain/kidan,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/kidan, //Default darksight of 2.
		"lantern" =  /obj/item/organ/internal/lantern
		)

	allowed_consumed_mobs = list(/mob/living/basic/diona_nymph)

	suicide_messages = list(
		"is attempting to bite their antenna off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is cracking their exoskeleton!",
		"is stabbing themselves with their mandibles!",
		"is holding their breath!")
	autohiss_basic_map = list(
			"z" = list("zz", "zzz", "zzzz"),
			"v" = list("vv", "vvv", "vvvv")
		)
	autohiss_extra_map = list(
			"s" = list("z", "zs", "zzz", "zzsz")
		)
	autohiss_exempt = list("Chittin")

	plushie_type = /obj/item/toy/plushie/kidanplushie
