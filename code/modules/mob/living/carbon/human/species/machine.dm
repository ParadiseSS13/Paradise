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
	brute_mod = 2.28 // 100% * 2.28 * 0.66 (robolimbs) ~= 150%
	burn_mod = 2.28  // So they take 50% extra damage from brute/burn overall
	tox_mod = 0
	clone_mod = 0
	oxy_mod = 0
	death_message = "gives one shrill beep before falling limp, their monitor flashing blue before completely shutting off..."

	species_traits = list(IS_WHITELISTED, NO_BREATHE, NO_SCAN, NO_INTORGANS, NO_PAIN, NO_DNA, RADIMMUNE, VIRUSIMMUNE, NOTRANSSTING)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | HAS_HEAD_MARKINGS | HAS_HEAD_ACCESSORY | ALL_RPARTS
	dietflags = 0		//IPCs can't eat, so no diet
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE
	blood_color = "#1F181F"
	flesh_color = "#AAAAAA"

	blood_color = "#3C3C3C"
	exotic_blood = "oil"
	blood_damage_type = STAMINA

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
	mutantears = /obj/item/organ/internal/ears/microphone
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

	var/datum/action/innate/change_monitor/monitor

/datum/species/machine/on_species_gain(mob/living/carbon/human/H)
	..()
	monitor = new()
	monitor.Grant(H)

/datum/species/machine/on_species_loss(mob/living/carbon/human/H)
	..()
	if(monitor)
		monitor.Remove(H)

/datum/species/machine/handle_death(mob/living/carbon/human/H)
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	if(!head_organ)
		return
	head_organ.h_style = "Bald"
	head_organ.f_style = "Shaved"
	spawn(100)
		if(H && head_organ)
			H.update_hair()
			H.update_fhair()

// Allows IPC's to change their monitor display
/datum/action/innate/change_monitor
	name = "Change Monitor"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "scan_mode"

/datum/action/innate/change_monitor/Activate()
	var/mob/living/carbon/human/H = owner
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")

	if(!head_organ) //If the rock'em-sock'em robot's head came off during a fight, they shouldn't be able to change their screen/optics.
		to_chat(H, "<span class='warning'>Where's your head at? Can't change your monitor/display without one.</span>")
		return

	var/datum/robolimb/robohead = all_robolimbs[head_organ.model]
	if(!head_organ)
		return
	if(!robohead.is_monitor) //If they've got a prosthetic head and it isn't a monitor, they've no screen to adjust. Instead, let them change the colour of their optics!
		var/optic_colour = input(H, "Select optic colour", H.m_colours["head"]) as color|null
		if(H.incapacitated())
			to_chat(H, "<span class='warning'>You were interrupted while changing the colour of your optics.</span>")
			return
		if(optic_colour)
			H.change_markings(optic_colour, "head")

	else if(robohead.is_monitor) //Means that the character's head is a monitor (has a screen). Time to customize.
		var/list/hair = list()
		for(var/i in GLOB.hair_styles_public_list)
			var/datum/sprite_accessory/hair/tmp_hair = GLOB.hair_styles_public_list[i]
			if((head_organ.dna.species.name in tmp_hair.species_allowed) && (robohead.company in tmp_hair.models_allowed)) //Populate the list of available monitor styles only with styles that the monitor-head is allowed to use.
				hair += i

		var/file = file2text("config/custom_sprites.txt")		//Pulls up the custom_sprites list
		var/lines = splittext(file, "\n")

		for(var/line in lines)									// Looks for lines set up as screen:ckey:screen_name
			var/list/Entry = splittext(line, ":")				// split lines
			for(var/i = 1 to Entry.len)
				Entry[i] = trim(Entry[i])						// Cleans up lines
				if(Entry.len != 3 || Entry[1] != "screen")		// Ignore entries that aren't for screens
					continue
				if(Entry[2] == H.ckey)							// They're in the list? Custom sprite time, var and icon change required
					hair += Entry[3]							// Adds custom screen to list

		var/new_style = input(H, "Select a monitor display", "Monitor Display", head_organ.h_style) as null|anything in hair
		var/new_color = input("Please select hair color.", "Monitor Color", head_organ.hair_colour) as null|color

		if(H.incapacitated())
			to_chat(H, "<span class='warning'>You were interrupted while changing your monitor display.</span>")
			return

		if(new_style)
			H.change_hair(new_style, 1)							// The 1 is to enable custom sprites
		if(new_color)
			H.change_hair_color(new_color)
