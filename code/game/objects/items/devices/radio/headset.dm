/obj/item/device/radio/headset
	name = "radio headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys."
	var/radio_desc = ""
	icon_state = "headset"
	item_state = "headset"
	materials = list(MAT_METAL=75)
	subspace_transmission = 1
	canhear_range = 0 // can't hear headsets from very far away

	slot_flags = SLOT_EARS
	var/translate_binary = 0
	var/translate_hive = 0
	var/obj/item/device/encryptionkey/keyslot1 = null
	var/obj/item/device/encryptionkey/keyslot2 = null

	var/ks1type = null
	var/ks2type = null

/obj/item/device/radio/headset/New()
	..()
	internal_channels.Cut()

/obj/item/device/radio/headset/initialize()
	..()

	if(ks1type)
		keyslot1 = new ks1type(src)
	if(ks2type)
		keyslot2 = new ks2type(src)

	recalculateChannels(1)

/obj/item/device/radio/headset/Destroy()
	if(keyslot1)
		qdel(keyslot1)
	if(keyslot2)
		qdel(keyslot2)
	keyslot1 = null
	keyslot2 = null
	return ..()

/obj/item/device/radio/headset/list_channels(var/mob/user)
	return list_secure_channels()

/obj/item/device/radio/headset/examine(mob/user, var/distance = -1)
	if(!(..(user, 1) && radio_desc))
		return

	to_chat(user, "The following channels are available:")
	to_chat(user, radio_desc)

/obj/item/device/radio/headset/handle_message_mode(mob/living/M as mob, message, channel)
	if(channel == "special")
		if(translate_binary)
			var/datum/language/binary = all_languages["Robot Talk"]
			binary.broadcast(M, message)
			return RADIO_CONNECTION_NON_SUBSPACE
		if(translate_hive)
			var/datum/language/hivemind = all_languages["Hivemind"]
			hivemind.broadcast(M, message)
			return RADIO_CONNECTION_NON_SUBSPACE
		return RADIO_CONNECTION_FAIL

	return ..()

/obj/item/device/radio/headset/receive_range(freq, level, aiOverride = 0)
	if(aiOverride)
		return ..(freq, level)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.l_ear == src || H.r_ear == src)
			return ..(freq, level)
	else if(isanimal(loc))
		// frankly, all the ones with inventory are small enough to not warrant snowflaking the slot check somehow
		return ..(freq, level)
	return -1

/obj/item/device/radio/headset/alt
	name = "bowman headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/device/radio/headset/syndicate
	origin_tech = "syndicate=3"
	syndie = 1
	ks1type = /obj/item/device/encryptionkey/syndicate

/obj/item/device/radio/headset/syndicate/alt //undisguised bowman with flash protection
	name = "syndicate headset"
	desc = "A syndicate headset that can be used to hear all radio frequencies. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	origin_tech = "syndicate=3"
	icon_state = "syndie_headset"
	item_state = "syndie_headset"

/obj/item/device/radio/headset/syndicate/syndteam
	ks1type = /obj/item/device/encryptionkey/syndteam

/obj/item/device/radio/headset/syndicate/alt/syndteam
	ks1type = /obj/item/device/encryptionkey/syndteam

/obj/item/device/radio/headset/binary
	origin_tech = "syndicate=3"
	ks1type = /obj/item/device/encryptionkey/binary

/obj/item/device/radio/headset/headset_sec
	name = "security radio headset"
	desc = "This is used by your elite security force."
	icon_state = "sec_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/headset_sec

/obj/item/device/radio/headset/headset_sec/alt
	name = "security bowman headset"
	desc = "This is used by your elite security force. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"

/obj/item/device/radio/headset/headset_eng
	name = "engineering radio headset"
	desc = "When the engineers wish to chat like girls."
	icon_state = "eng_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/headset_eng

/obj/item/device/radio/headset/headset_rob
	name = "robotics radio headset"
	desc = "Made specifically for the roboticists who cannot decide between departments."
	icon_state = "rob_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/headset_rob

/obj/item/device/radio/headset/headset_med
	name = "medical radio headset"
	desc = "A headset for the trained staff of the medbay."
	icon_state = "med_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/headset_med

/obj/item/device/radio/headset/headset_sci
	name = "science radio headset"
	desc = "A sciency headset. Like usual."
	icon_state = "sci_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/headset_sci

/obj/item/device/radio/headset/headset_medsci
	name = "medical research radio headset"
	desc = "A headset that is a result of the mating between medical and science."
	icon_state = "medsci_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/headset_medsci

/obj/item/device/radio/headset/headset_com
	name = "command radio headset"
	desc = "A headset with a commanding channel."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/headset_com

/obj/item/device/radio/headset/heads/captain
	name = "captain's headset"
	desc = "The headset of the boss."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/heads/captain

/obj/item/device/radio/headset/heads/captain/alt
	name = "\proper the captain's bowman headset"
	desc = "The headset of the boss. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/device/radio/headset/heads/rd
	name = "Research Director's headset"
	desc = "Headset of the researching God."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/heads/rd

/obj/item/device/radio/headset/heads/hos
	name = "head of security's headset"
	desc = "The headset of the man who protects your worthless lives."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/heads/hos

/obj/item/device/radio/headset/heads/hos/alt
	name = "\proper the head of security's bowman headset"
	desc = "The headset of the man in charge of keeping order and protecting the station. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/device/radio/headset/heads/ce
	name = "chief engineer's headset"
	desc = "The headset of the guy who is in charge of morons."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/heads/ce

/obj/item/device/radio/headset/heads/cmo
	name = "chief medical officer's headset"
	desc = "The headset of the highly trained medical chief."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/heads/cmo

/obj/item/device/radio/headset/heads/hop
	name = "head of personnel's headset"
	desc = "The headset of the guy who will one day be captain."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/heads/hop

/obj/item/device/radio/headset/headset_cargo
	name = "supply radio headset"
	desc = "A headset used by the cargo department."
	icon_state = "cargo_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/headset_cargo

/obj/item/device/radio/headset/headset_cargo/mining
	name = "mining radio headset"
	desc = "Headset used by shaft miners."
	icon_state = "mine_headset"

/obj/item/device/radio/headset/headset_service
	name = "service radio headset"
	desc = "Headset used by the service staff, tasked with keeping the station full, happy and clean."
	icon_state = "srv_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/headset_service

/obj/item/device/radio/headset/heads/ntrep
	name = "nanotrasen representative's headset"
	desc = "The headset of the Nanotrasen Representative."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/heads/ntrep

/obj/item/device/radio/headset/heads/magistrate
	name = "magistrate's headset"
	desc = "The headset of the Magistrate."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/heads/magistrate

/obj/item/device/radio/headset/heads/magistrate/alt
	name = "\proper magistrate's bowman headset"
	desc = "The headset of the Magistrate. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/device/radio/headset/heads/blueshield
	name = "blueshield's headset"
	desc = "The headset of the Blueshield."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/heads/blueshield

/obj/item/device/radio/headset/heads/blueshield/alt
	name = "\proper blueshield's bowman headset"
	desc = "The headset of the Blueshield. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/device/radio/headset/ert
	name = "emergency response team headset"
	desc = "The headset of the boss's boss."
	icon_state = "com_headset"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/ert

/obj/item/device/radio/headset/ert/alt
	name = "\proper emergency response team's bowman headset"
	desc = "The headset of the boss. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/device/radio/headset/centcom
	name = "\proper centcom officer's bowman headset"
	desc = "The headset of final authority. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"
	ks2type = /obj/item/device/encryptionkey/centcom

/obj/item/device/radio/headset/heads/ai_integrated //No need to care about icons, it should be hidden inside the AI anyway.
	name = "\improper AI subspace transceiver"
	desc = "Integrated AI radio transceiver."
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "radio"
	item_state = "headset"
	ks2type = /obj/item/device/encryptionkey/heads/ai_integrated
	var/myAi = null    // Atlantis: Reference back to the AI which has this radio.
	var/disabledAi = 0 // Atlantis: Used to manually disable AI's integrated radio via intellicard menu.

/obj/item/device/radio/headset/heads/ai_integrated/receive_range(freq, level)
	if(disabledAi)
		return -1 //Transciever Disabled.
	return ..(freq, level, 1)

/obj/item/device/radio/headset/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.set_machine(src)
	if(!( istype(W, /obj/item/weapon/screwdriver) || (istype(W, /obj/item/device/encryptionkey/ ))))
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		if(keyslot1 || keyslot2)

			for(var/ch_name in channels)
				radio_controller.remove_object(src, radiochannels[ch_name])
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
		else
			to_chat(user, "This headset doesn't have any encryption keys!  How useless...")

	if(istype(W, /obj/item/device/encryptionkey/))
		if(keyslot1 && keyslot2)
			to_chat(user, "The headset can't hold another key!")
			return

		if(!keyslot1)
			user.drop_item()
			W.loc = src
			keyslot1 = W
		else
			user.drop_item()
			W.loc = src
			keyslot2 = W

		recalculateChannels()
	return


/obj/item/device/radio/headset/proc/recalculateChannels(var/setDescription = 0)
	src.channels = list()
	src.translate_binary = 0
	src.translate_hive = 0
	src.syndie = 0

	if(keyslot1)
		for(var/ch_name in keyslot1.channels)
			if(ch_name in src.channels)
				continue
			src.channels += ch_name
			src.channels[ch_name] = keyslot1.channels[ch_name]

		if(keyslot1.translate_binary)
			src.translate_binary = 1

		if(keyslot1.translate_hive)
			src.translate_hive = 1

		if(keyslot1.syndie)
			src.syndie = 1

	if(keyslot2)
		for(var/ch_name in keyslot2.channels)
			if(ch_name in src.channels)
				continue
			src.channels += ch_name
			src.channels[ch_name] = keyslot2.channels[ch_name]

		if(keyslot2.translate_binary)
			src.translate_binary = 1

		if(keyslot2.translate_hive)
			src.translate_hive = 1

		if(keyslot2.syndie)
			src.syndie = 1


	for(var/ch_name in channels)
		if(!radio_controller)
			src.name = "broken radio headset"
			return

		secure_radio_connections[ch_name] = radio_controller.add_object(src, radiochannels[ch_name],  RADIO_CHAT)

	if(setDescription)
		setupRadioDescription()

	return

/obj/item/device/radio/headset/proc/setupRadioDescription()
	var/radio_text = ""
	for(var/i = 1 to channels.len)
		var/channel = channels[i]
		var/key = get_radio_key_from_channel(channel)
		radio_text += "[key] - [channel]"
		if(i != channels.len)
			radio_text += ", "

	radio_desc = radio_text

/obj/item/device/radio/headset/proc/make_syndie() // Turns normal radios into Syndicate radios!
	qdel(keyslot1)
	keyslot1 = new /obj/item/device/encryptionkey/syndicate
	syndie = 1
	recalculateChannels()