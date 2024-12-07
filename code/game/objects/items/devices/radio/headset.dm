/obj/item/radio/headset
	name = "radio headset"
	desc = "A small, head-mounted radio system for communicating quickly across long distances. There are two slots for encryption keys on the side."
	var/radio_desc = ""
	icon_state = "headset"
	item_state = "headset"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/ears.dmi', //We read you loud and skree-er.
		"Kidan" = 'icons/mob/clothing/species/kidan/ears.dmi'
		)
	materials = list(MAT_METAL = 200)
	canhear_range = 0 // can't hear headsets from very far away

	slot_flags = ITEM_SLOT_BOTH_EARS
	var/translate_binary = FALSE
	var/translate_hive = FALSE
	var/obj/item/encryptionkey/keyslot1 = null
	var/obj/item/encryptionkey/keyslot2 = null

	var/ks1type = null
	var/ks2type = null
	dog_fashion = null
	requires_tcomms = TRUE

/obj/item/radio/headset/New()
	..()
	internal_channels.Cut()

/obj/item/radio/headset/Initialize(mapload)
	. = ..()

	if(ks1type)
		keyslot1 = new ks1type(src)
		if(keyslot1.syndie)
			syndiekey = keyslot1
	if(ks2type)
		keyslot2 = new ks2type(src)
		if(keyslot2.syndie)
			syndiekey = keyslot2

	recalculateChannels(TRUE)

/obj/item/radio/headset/Destroy()
	QDEL_NULL(keyslot1)
	QDEL_NULL(keyslot2)
	QDEL_NULL(syndiekey)
	return ..()

/obj/item/radio/headset/examine(mob/user)
	. = ..()
	if(in_range(src, user) && radio_desc)
		. += "The following channels are available:"
		. += radio_desc

/obj/item/radio/headset/handle_message_mode(mob/living/M as mob, list/message_pieces, channel)
	if(channel == "special")
		if(translate_binary)
			var/datum/language/binary = GLOB.all_languages["Robot Talk"]
			binary.broadcast(M, strip_prefixes(multilingual_to_message(message_pieces)))
			return RADIO_CONNECTION_NON_STANDARD
		if(translate_hive)
			var/datum/language/hivemind = GLOB.all_languages["Hivemind"]
			hivemind.broadcast(M, strip_prefixes(multilingual_to_message(message_pieces)))
			return RADIO_CONNECTION_NON_STANDARD
		return RADIO_CONNECTION_FAIL

	return ..()

/obj/item/radio/headset/is_listening()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.l_ear == src || H.r_ear == src)
			return ..()
	else if(isanimal(loc) || isAI(loc))
		return ..()

	return FALSE

/obj/item/radio/headset/alt
	name = "bowman headset"
	desc = "An unmarked tactical headset fitted with electronic ear protection systems. There are two slots for encryption keys on the side."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/alt/deathsquad
	name = "\improper Deathsquad headset"
	desc = "A custom-built tactical headset used exclusively by Nanotrasen black-ops units. Protects against loud noises and doesn't require a telecom core."
	requires_tcomms = FALSE
	instant = TRUE
	freqlock = TRUE

/obj/item/radio/headset/alt/deathsquad/Initialize(mapload)
	. = ..()
	set_frequency(DTH_FREQ)

/obj/item/radio/headset/syndicate
	origin_tech = "syndicate=3"
	ks1type = /obj/item/encryptionkey/syndicate/nukeops
	requires_tcomms = FALSE
	instant = TRUE // Work instantly if there are no comms
	freqlock = TRUE

/// undisguised bowman with flash protection
/obj/item/radio/headset/syndicate/alt
	name = "syndicate headset"
	desc = "An intimidating tactical headset in Syndicate colors. Fitted with a hacked encryption system providing access to most Nanotrasen channels. Protects against loud noises."
	flags = EARBANGPROTECT
	origin_tech = "syndicate=3"
	icon_state = "syndie_headset"
	item_state = "syndie_headset"

/obj/item/radio/headset/syndicate/syndteam
	ks1type = /obj/item/encryptionkey/syndteam

/obj/item/radio/headset/syndicate/alt/syndteam
	ks1type = /obj/item/encryptionkey/syndteam

/obj/item/radio/headset/syndicate/alt/nocommon
	name = "syndicate researcher headset"

/obj/item/radio/headset/syndicate/alt/nocommon/New()
	. = ..()
	set_frequency(SYND_FREQ)

/obj/item/radio/headset/soviet
	name = "soviet bowman headset"
	desc = "Used by U.S.S.P forces. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	origin_tech = "syndicate=3"
	icon_state = "soviet_headset"
	item_state = "soviet_headset"
	ks1type = /obj/item/encryptionkey/soviet
	requires_tcomms = FALSE

/obj/item/radio/headset/binary
	origin_tech = "syndicate=3"
	ks1type = /obj/item/encryptionkey/binary

/obj/item/radio/headset/headset_sec
	name = "security radio headset"
	desc = "A red & black radio headset used by Nanotrasen Asset Protection."
	icon_state = "sec_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_sec

/obj/item/radio/headset/headset_sec/alt
	name = "security bowman headset"
	desc = "A slick red & black tacticool headset with an attached microphone. Protects against loud noises."
	flags = EARBANGPROTECT
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"

/obj/item/radio/headset/headset_iaa
	name = "internal affairs radio headset"
	desc = "A comfy black headset used by Nanotrasen internal affairs."
	icon_state = "sec_headset"
	item_state = "sec_headset"
	ks2type = /obj/item/encryptionkey/headset_iaa

/obj/item/radio/headset/headset_iaa/alt
	name = "internal affairs bowman headset"
	desc = "A comfy tacticool headset used by Nanotrasen internal affairs. Protects against loud noises."
	flags = EARBANGPROTECT
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"

/obj/item/radio/headset/headset_eng
	name = "engineering radio headset"
	desc = "A brightly-colored radio headset used by Nanotrasen engineering staff."
	icon_state = "eng_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_eng

/obj/item/radio/headset/headset_rob
	name = "robotics radio headset"
	desc = "A special black headset used by Nanotrasen robotics staff."
	icon_state = "rob_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_rob

/obj/item/radio/headset/headset_med
	name = "medical radio headset"
	desc = "A sterile white radio headset used by Nanotrasen medical personnel."
	icon_state = "med_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_med

/obj/item/radio/headset/headset_med/para
	name = "paramedic radio headset"
	desc = "A sleek blue headset used by Nanotrasen paramedics."
	icon_state = "para_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_med/para

/obj/item/radio/headset/headset_sci
	name = "science radio headset"
	desc = "A purple-striped headset used by Nanotrasen research staff."
	icon_state = "sci_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_sci

/obj/item/radio/headset/headset_medsci
	name = "medical research radio headset"
	desc = "A cursed abomination of a radio headset, merging science and medical together."
	icon_state = "medsci_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_medsci

/obj/item/radio/headset/headset_com
	name = "command radio headset"
	desc = "A specialized radio headset used by generic command staff. You probably shouldn't be seeing this in-game. Make an issue report on github."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_com

/obj/item/radio/headset/heads/captain
	name = "captain's headset"
	desc = "An expensive blue & gold radio headset used by Nanotrasen station commanders."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/captain

/obj/item/radio/headset/heads/captain/alt
	name = "captain's bowman headset"
	desc = "An expensive blue & gold tactical headset used by Nanotrasen station commanders. Protects against loud noises."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/rd
	name = "research director's headset"
	desc = "A commanding purple headset used by Nanotrasen Research Directors."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/rd

/obj/item/radio/headset/heads/hos
	name = "head of security's headset"
	desc = "An intimidating radio headset used by senior Asset Proection personnel."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/hos

/obj/item/radio/headset/heads/hos/alt
	name = "head of security's bowman headset"
	desc = "An intimidating tactical headset used by senior Asset Protection personnel. Protects against loud noises."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/ce
	name = "chief engineer's headset"
	desc = "A robust radio headset used by high-ranking Nanotrasen engineers."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/ce

/obj/item/radio/headset/heads/cmo
	name = "chief medical officer's headset"
	desc = "A refined radio headset used by high-ranking Nanotrasen medical personnel."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/cmo

/obj/item/radio/headset/heads/hop
	name = "head of personnel's headset"
	desc = "A comfortable blue headset used by Nanotrasen bureaucrats."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/hop

/obj/item/radio/headset/heads/qm
	name = "quartermaster's headset"
	desc = "A scratched-up radio headset used by senior Nanotrasen logistics personnel. Smells strongly of tobacco and gun oil."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/qm

/obj/item/radio/headset/headset_cargo
	name = "supply radio headset"
	desc = "A comfy brown headset used by Nanotrasen logistics employees."
	icon_state = "cargo_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_cargo

/obj/item/radio/headset/headset_cargo/mining
	name = "mining radio headset"
	desc = "A rugged, high-power headset used by Nanotrasen mining teams."
	icon_state = "mine_headset"

/obj/item/radio/headset/headset_cargo/expedition
	name = "expedition radio headset"
	desc = "A high-power radio headset used by Nanotrasen's deep-space exploration and salvage units."
	icon_state = "mine_headset"

/obj/item/radio/headset/headset_service
	name = "service radio headset"
	desc = "A green radio headset used by Nanotrasen's service division."
	icon_state = "srv_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/headset_service

/obj/item/radio/headset/heads/ntrep
	name = "nanotrasen representative's headset"
	desc = "An embellished radio headset used by Nanotrasen corporate reps."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/ntrep

/obj/item/radio/headset/heads/magistrate
	name = "magistrate's headset"
	desc = "A well-polished radio headset used by senior Nanotrasen legal specialists."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/magistrate

/obj/item/radio/headset/heads/magistrate/alt
	name = "magistrate's bowman headset"
	desc = "A tactical headset used by Nanotrasen magistrates."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/blueshield
	name = "blueshield's headset"
	desc = "The headset of the Blueshield."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/blueshield

/obj/item/radio/headset/heads/blueshield/alt
	name = "blueshield's bowman headset"
	desc = "A cobalt-blue tactical headset used by Nanotrasen's Blueshield bodyguard corps. Protects against loud noises."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/ert
	name = "emergency response team headset"
	desc = "An ergonomic headset used by Nanotrasen-affiliated PMC units."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/ert
	freqlock = TRUE

/obj/item/radio/headset/ert/alt
	name = "emergency response team's bowman headset"
	desc = "An ergonomic tactical headset used by Nanotrasen-affiliated PMCs. Protects against loud noises."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/ert/alt/solgov
	name = "\improper Trans-Solar Marine Corps bowman headset"
	desc = "An ergonomic combat headset used by the TSMC. Protects against loud noises."

/obj/item/radio/headset/ert/alt/solgovviper
	name = "\improper 3rd SOD bowman headset"
	desc = "A custom-fitted headset used by the commandos of the Federal Army's renowned 3rd Special Operations Detachment, more commonly known as the Vipers."

/obj/item/radio/headset/ert/alt/commander
	name = "ERT commander's bowman headset"
	desc = "An advanced tactical headset used by high-ranking Nanotrasen PMCs. Equipped with an advanced transmission array and ear protection."
	requires_tcomms = FALSE
	instant = TRUE

/obj/item/radio/headset/ert/alt/commander/solgov
	name = "\improper Trans-Solar Marine Corps officer's bowman headset"
	desc = "An ergonomic combat headset used by the TSMC. This model is equipped with an extra-strength transmitter for barking orders."

/obj/item/radio/headset/centcom
	name = "centcom officer's bowman headset"
	desc = "A very rare, very expensive tactical headset used by Nanotrasen upper management. Fitted with an advanced transmitter array that doesn't require a telecom core, and protects against loud noises."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"
	ks2type = /obj/item/encryptionkey/centcom
	requires_tcomms = FALSE
	instant = TRUE

/// No need to care about icons, it should be hidden inside the AI anyway.
/obj/item/radio/headset/heads/ai_integrated
	name = "\improper AI radio transceiver"
	desc = "Integrated AI radio transceiver."
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "radio"
	item_state = "headset"
	ks2type = /obj/item/encryptionkey/heads/ai_integrated
	var/myAi = null    // Atlantis: Reference back to the AI which has this radio.
	var/disabledAi = FALSE // Atlantis: Used to manually disable AI's integrated radio via intellicard menu.

/obj/item/radio/headset/heads/ai_integrated/is_listening()
	if(disabledAi)
		return FALSE
	return ..()

/obj/item/radio/headset/attackby(obj/item/key, mob/user)
	if(istype(key, /obj/item/encryptionkey/))

		if(keyslot1 && keyslot2)
			to_chat(user, "The headset can't hold another key!")
			return

		if(!user.unEquip(key))
			to_chat(user, "<span class='warning'>[key] is stuck to your hand, you can't insert it in [src].</span>")
			return

		key.forceMove(src)
		if(!keyslot1)
			keyslot1 = key
		else
			keyslot2 = key

		recalculateChannels()
		return

	return ..()

/obj/item/radio/headset/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return

	if(keyslot1 || keyslot2)

		for(var/ch_name in channels)
			SSradio.remove_object(src, SSradio.radiochannels[ch_name])
			secure_radio_connections[ch_name] = null

		if(keyslot1)
			var/turf/T = get_turf(user)
			if(T)
				keyslot1.loc = T
				keyslot1 = null
		if(keyslot2)
			var/turf/T = get_turf(user)
			if(T)
				keyslot2.loc = T
				keyslot2 = null

		recalculateChannels()
		to_chat(user, "You pop out the encryption keys in the headset!")
		I.play_tool_sound(user, I.tool_volume)
	else
		to_chat(user, "This headset doesn't have any encryption keys!  How useless...")

/obj/item/radio/headset/recalculateChannels(setDescription = FALSE)
	channels = list()
	translate_binary = FALSE
	translate_hive = FALSE
	syndiekey = null

	if(keyslot1)
		for(var/ch_name in keyslot1.channels)
			if(ch_name in channels)
				continue
			channels += ch_name
			channels[ch_name] = keyslot1.channels[ch_name]

		if(keyslot1.translate_binary)
			translate_binary = TRUE

		if(keyslot1.translate_hive)
			translate_hive = TRUE

		if(keyslot1.syndie)
			syndiekey = keyslot1

	if(keyslot2)
		for(var/ch_name in keyslot2.channels)
			if(ch_name in channels)
				continue
			channels += ch_name
			channels[ch_name] = keyslot2.channels[ch_name]

		if(keyslot2.translate_binary)
			translate_binary = TRUE

		if(keyslot2.translate_hive)
			translate_hive = TRUE

		if(keyslot2.syndie)
			syndiekey = keyslot2


	for(var/ch_name in channels)
		if(!SSradio)
			name = "broken radio headset"
			return

		secure_radio_connections[ch_name] = SSradio.add_object(src, SSradio.radiochannels[ch_name],  RADIO_CHAT)

	if(setDescription)
		setupRadioDescription()

	return

/obj/item/radio/headset/proc/setupRadioDescription()
	var/radio_text = ""
	for(var/i = 1 to length(channels))
		var/channel = channels[i]
		var/key = get_radio_key_from_channel(channel)
		radio_text += "[key] - [channel]"
		if(i != length(channels))
			radio_text += ", "

	radio_desc = radio_text

/obj/item/radio/headset/proc/make_syndie() // Turns normal radios into Syndicate radios!
	qdel(keyslot1)
	keyslot1 = new /obj/item/encryptionkey/syndicate
	syndiekey = keyslot1
	recalculateChannels()
