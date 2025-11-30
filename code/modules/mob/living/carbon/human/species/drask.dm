/datum/species/drask
	name = "Drask"
	name_plural = "Drask"
	max_age = 500
	icobase = 'icons/mob/human_races/r_drask.dmi'
	language = "Orluum"
	eyes = "drask_eyes_s"

	speech_sounds = list('sound/voice/drasktalk.ogg')
	speech_chance = 20
	male_scream_sound = 'sound/voice/drasktalk2.ogg'
	female_scream_sound = 'sound/voice/drasktalk2.ogg'
	male_cough_sounds = 'sound/voice/draskcough.ogg'
	female_cough_sounds = 'sound/voice/draskcough.ogg'
	male_sneeze_sound = 'sound/voice/drasksneeze.ogg'
	female_sneeze_sound = 'sound/voice/drasksneeze.ogg'

	//exotic_blood = "cryoxadone"
	body_temperature = 273

	blurb = "Drask are cold-bodied humanoids from the ice world of Hoorlm, contained within a black hole system. \
	Operating in enclaves run by elders, Drasks are biologically immortal and place great societal value in patience.<br/><br/> \
	Drask traditionally pay homage to their planet as their birth deity, with many modern Drask viewing space travel a patron saint. \
	Drasks wield little influence on the galaxy in a traditional sense and have slowly begun to become more prevalent outside their origin system thanks to alien contact."

	suicide_messages = list(
		"is self-warming with friction!",
		"is jamming fingers through their big eyes!",
		"is sucking in warm air!",
		"is holding their breath!")

	plushie_type = /obj/item/toy/plushie/draskplushie

	species_traits = list(LIPS, NO_HAIR)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT
	bodyflags = HAS_SKIN_TONE | HAS_BODY_MARKINGS | BALD | SHAVED
	dietflags = DIET_OMNI

	cold_level_1 = -1 //Default 260 - Lower is better
	cold_level_2 = -1 //Default 200
	cold_level_3 = -1 //Default 120
	coldmod = -1

	heat_level_1 = 310 //Default 370 - Higher is better
	heat_level_2 = 340 //Default 400
	heat_level_3 = 400 //Default 460
	heatmod = 3 // 3 * more damage from body temp

	flesh_color = "#a3d4eb"
	reagent_tag = PROCESS_ORG
	base_color = "#a3d4eb"
	blood_color = "#a3d4eb"
	butt_sprite = "drask"

	meat_type = /obj/item/food/meat/human
	has_organ = list(
		"heart" =      				/obj/item/organ/internal/heart/drask,
		"lungs" =     				/obj/item/organ/internal/lungs/drask,
		"liver" =      /obj/item/organ/internal/liver/drask,
		"eyes" =     				/obj/item/organ/internal/eyes/drask, //5 darksight.
		"brain" =  					/obj/item/organ/internal/brain/drask
		)
	autohiss_basic_map = list(
			"o" = list ("oo", "ooo"),
			"u" = list ("uu", "uuu")
		)
	autohiss_extra_map = list(
			"m" = list ("mm", "mmm")
		)
	autohiss_exempt = list("Orluum")

/datum/species/drask/do_compressor_grind(mob/living/carbon/human/H)
	new /obj/item/soap(H.loc)
