/client/proc/only_one()
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert("The game hasn't started yet!")
		return

	var/list/incompatible_species = list(/datum/species/plasmaman, /datum/species/vox)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !(H.client))
			continue
		if(is_special_character(H))
			continue
		if(is_type_in_list(H.dna.species, incompatible_species))
			H.set_species(/datum/species/human)
			var/datum/character_save/S = new	// Randomize appearance
			S.randomise()
			S.copy_to(H)

		SSticker.mode.traitors += H.mind
		H.mind.special_role = SPECIAL_ROLE_TRAITOR

		H.mind.add_mind_objective(/datum/objective/hijack)

		var/list/messages = list()
		messages.Add("<b>You are a Highlander. Kill all other Highlanders. There can be only one.</b>")
		messages.Add(H.mind.prepare_announce_objectives(FALSE))
		to_chat(H, chat_box_red(messages.Join("<br>")))

		for(var/obj/item/I in H)
			if(istype(I, /obj/item/bio_chip))
				continue
			qdel(I)

		H.equip_to_slot_or_del(new /obj/item/clothing/under/costume/kilt(H), ITEM_SLOT_JUMPSUIT)
		H.equip_to_slot_or_del(new /obj/item/radio/headset/heads/captain(H), ITEM_SLOT_LEFT_EAR)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), ITEM_SLOT_HEAD)
		H.equip_to_slot_or_del(new /obj/item/claymore/highlander(H), ITEM_SLOT_RIGHT_HAND)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), ITEM_SLOT_SHOES)
		H.equip_to_slot_or_del(new /obj/item/pinpointer(H.loc), ITEM_SLOT_LEFT_POCKET)

		var/obj/item/card/id/W = new(H)
		W.name = "[H.real_name]'s ID Card"
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Highlander"
		W.registered_name = H.real_name
		H.equip_to_slot_or_del(W, ITEM_SLOT_ID)
		H.dna.species.after_equip_job(null, H)
		H.regenerate_icons()

	message_admins("[key_name_admin(usr)] used THERE CAN BE ONLY ONE! -NO ATTACK LOGS WILL BE SENT TO ADMINS FROM THIS POINT FORTH-", 1)
	log_admin("[key_name(usr)] used there can be only one.")
	GLOB.nologevent = 1

	var/sound/music = sound('sound/music/thunderdome.ogg', channel = CHANNEL_ADMIN)
	for(var/mob/M in GLOB.player_list)
		if(M.client.prefs.sound & SOUND_MIDI)
			if(isnewplayer(M) && (M.client.prefs.sound & SOUND_LOBBY))
				M.stop_sound_channel(CHANNEL_LOBBYMUSIC)
			music.volume = 100 * M.client.prefs.get_channel_volume(CHANNEL_ADMIN)
			SEND_SOUND(M, music)

/client/proc/only_me()
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert("The game hasn't started yet!")
		return

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !(H.client)) continue
		if(is_special_character(H)) continue

		SSticker.mode.traitors += H.mind
		H.mind.special_role = "[H.real_name] Prime"

		H.mind.add_mind_objective(/datum/objective/hijackclone)

		var/list/messages = list()
		messages.Add("<b>You are the multiverse summoner. Activate your blade to summon copies of yourself from another universe to fight by your side.</b>")
		messages.Add(H.mind.prepare_announce_objectives(FALSE))
		to_chat(H, chat_box_red(messages.Join("<br>")))

		var/obj/item/slot_item_ID = H.get_item_by_slot(ITEM_SLOT_ID)
		qdel(slot_item_ID)
		var/obj/item/slot_item_hand = H.get_item_by_slot(ITEM_SLOT_RIGHT_HAND)
		H.drop_item_to_ground(slot_item_hand)

		var/obj/item/multisword/pure_evil/multi = new(H)
		H.equip_to_slot_or_del(multi, ITEM_SLOT_RIGHT_HAND)

		var/obj/item/card/id/W = new(H)
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Multiverse Summoner"
		W.registered_name = H.real_name
		W.update_label(H.real_name)
		H.equip_to_slot_or_del(W, ITEM_SLOT_ID)

		H.update_icons()

	message_admins("[key_name_admin(usr)] used THERE CAN BE ONLY ME! -NO ATTACK LOGS WILL BE SENT TO ADMINS FROM THIS POINT FORTH-", 1)
	log_admin("[key_name(usr)] used there can be only me.")
	GLOB.nologevent = 1

	var/sound/music = sound('sound/music/thunderdome.ogg', channel = CHANNEL_ADMIN)
	for(var/mob/M in GLOB.player_list)
		if(M.client.prefs.sound & SOUND_MIDI)
			if(isnewplayer(M) && (M.client.prefs.sound & SOUND_LOBBY))
				M.stop_sound_channel(CHANNEL_LOBBYMUSIC)
			music.volume = 100 * M.client.prefs.get_channel_volume(CHANNEL_ADMIN)
			SEND_SOUND(M, music)
