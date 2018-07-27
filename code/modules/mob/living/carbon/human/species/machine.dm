/datum/species/machine
	name = "Machine"
	name_plural = "Machines"

	blurb = "Positronic intelligence really took off in the 26th century, and it is not uncommon to see independant, free-willed \
	robots on many human stations, particularly in fringe systems where standards are slightly lax and public opinion less relevant \
	to corporate operations. IPCs (Integrated Positronic Chassis) are a loose category of self-willed robots with a humanoid form, \
	generally self-owned after being 'born' into servitude; they are reliable and dedicated workers, albeit more than slightly \
	inhuman in outlook and perspective."

	icobase = 'icons/mob/human_races/r_machine.dmi'
	deform = 'icons/mob/human_races/r_machine.dmi'
	language = "Trinary"
	remains_type = /obj/effect/decal/remains/robot
	skinned_type = /obj/item/stack/sheet/metal // Let's grind up IPCs for station resources!

	eyes = "blank_eyes"
	brute_mod = 2.5 // 100% * 2.5 * 0.6 (robolimbs) ~= 150%
	burn_mod = 2.5  // So they take 50% extra damage from brute/burn overall.
	tox_mod = 0
	clone_mod = 0
	oxy_mod = 0
	death_message = "gives one shrill beep before falling limp, their monitor flashing blue before completely shutting off..."

	species_traits = list(IS_WHITELISTED, NO_BREATHE, NO_SCAN, NO_BLOOD, NO_PAIN, NO_DNA, RADIMMUNE, VIRUSIMMUNE, NOTRANSSTING)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | HAS_HEAD_MARKINGS | HAS_HEAD_ACCESSORY | ALL_RPARTS
	dietflags = 0		//IPCs can't eat, so no diet
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE
	blood_color = "#1F181F"
	flesh_color = "#AAAAAA"
	//Default styles for created mobs.
	default_hair = "Blue IPC Screen"
	can_revive_by_healing = 1
	has_gender = FALSE
	reagent_tag = PROCESS_SYN
	male_scream_sound = 'sound/goonstation/voice/robot_scream.ogg'
	female_scream_sound = 'sound/goonstation/voice/robot_scream.ogg'
	male_cough_sounds = list('sound/effects/mob_effects/m_machine_cougha.ogg','sound/effects/mob_effects/m_machine_coughb.ogg', 'sound/effects/mob_effects/m_machine_coughc.ogg')
	female_cough_sounds = list('sound/effects/mob_effects/f_machine_cougha.ogg','sound/effects/mob_effects/f_machine_coughb.ogg')
	male_sneeze_sound = 'sound/effects/mob_effects/machine_sneeze.ogg'
	female_sneeze_sound = 'sound/effects/mob_effects/f_machine_sneeze.ogg'
	butt_sprite = "machine"

	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/mmi_holder/posibrain,
		"cell" = /obj/item/organ/internal/cell,
		"optics" = /obj/item/organ/internal/eyes/optical_sensor, //Default darksight of 2.
		"charger" = /obj/item/organ/internal/cyberimp/arm/power_cord
		)

	vision_organ = /obj/item/organ/internal/eyes/optical_sensor
	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest/ipc),
		"groin" =  list("path" = /obj/item/organ/external/groin/ipc),
		"head" =   list("path" = /obj/item/organ/external/head/ipc),
		"l_arm" =  list("path" = /obj/item/organ/external/arm/ipc),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right/ipc),
		"l_leg" =  list("path" = /obj/item/organ/external/leg/ipc),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right/ipc),
		"l_hand" = list("path" = /obj/item/organ/external/hand/ipc),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right/ipc),
		"l_foot" = list("path" = /obj/item/organ/external/foot/ipc),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right/ipc)
		)

	suicide_messages = list(
		"is powering down!",
		"is smashing their own monitor!",
		"is twisting their own neck!",
		"is downloading extra RAM!",
		"is frying their own circuits!",
		"is blocking their ventilation port!")

	species_abilities = list(
		/mob/living/carbon/human/proc/change_monitor
		)

/datum/species/machine/handle_death(var/mob/living/carbon/human/H)
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	if(!head_organ)
		return
	head_organ.h_style = "Bald"
	head_organ.f_style = "Shaved"
	spawn(100)
		if(H)
			H.update_hair()
			H.update_fhair()