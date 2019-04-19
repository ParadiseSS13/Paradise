/datum/species/drask
	name = "Drask"
	name_plural = "Drask"
	icobase = 'icons/mob/human_races/r_drask.dmi'
	deform = 'icons/mob/human_races/r_drask.dmi'
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

	burn_mod = 2
	//exotic_blood = "cryoxadone"
	body_temperature = 273

	blurb = "Hailing from Hoorlm, planet outside what is usually considered a habitable \
	orbit, the Drask evolved to live in extreme cold. Their strange bodies seem \
	to operate better the colder their surroundings are, and can regenerate rapidly \
	when breathing supercooled gas. <br/><br/> On their homeworld, the Drask live long lives \
	in their labyrinthine settlements, carved out beneath Hoorlm's icy surface, where the air \
	is of breathable density."

	suicide_messages = list(
		"is self-warming with friction!",
		"is jamming fingers through their big eyes!",
		"is sucking in warm air!",
		"is holding their breath!")

	species_traits = list(LIPS, IS_WHITELISTED)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT
	bodyflags = HAS_SKIN_TONE | HAS_BODY_MARKINGS
	has_gender = FALSE
	dietflags = DIET_OMNI

	cold_level_1 = -1 //Default 260 - Lower is better
	cold_level_2 = -1 //Default 200
	cold_level_3 = -1 //Default 120
	coldmod = -1

	heat_level_1 = 300 //Default 360 - Higher is better
	heat_level_2 = 340 //Default 400
	heat_level_3 = 400 //Default 460
	heatmod = 2

	flesh_color = "#a3d4eb"
	reagent_tag = PROCESS_ORG
	base_color = "#a3d4eb"
	blood_color = "#a3d4eb"
	butt_sprite = "drask"

	has_organ = list(
		"heart" =      				/obj/item/organ/internal/heart/drask,
		"lungs" =     				/obj/item/organ/internal/lungs/drask,
		"metabolic strainer" =      /obj/item/organ/internal/liver/drask,
		"eyes" =     				/obj/item/organ/internal/eyes/drask, //5 darksight.
		"brain" =  					/obj/item/organ/internal/brain/drask
		)
