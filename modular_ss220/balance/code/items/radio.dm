/obj/item/radio
	/// Whether the radio respects common channel limitations
	var/respects_common_channel_limitations = TRUE

/obj/item/radio/handle_message_mode(mob/living/M, list/message_pieces, message_mode)
	var/datum/radio_frequency/channel = ..()
	if(!istype(channel))
		return channel // this will be handled
	
	// Check if the radio can send to common.
	var/sec_level_grants_common = SSsecurity_level.current_security_level.grants_common_channel_access()
	if(channel.frequency == PUB_FREQ && !sec_level_grants_common && has_limited_common_channel_access())
		return RADIO_CONNECTION_FAIL

	return channel

/obj/item/radio/emag_act(mob/user)
	..()
	if(emagged)
		to_chat(user, span_notice("[declent_ru(NOMINATIVE)] не реагирует. Видимо, модификация уже производилась."))
		return FALSE

	respects_common_channel_limitations = FALSE
	emagged = TRUE
	playsound(loc, 'sound/effects/sparks4.ogg', vol = 75, vary = TRUE)
	to_chat(user, span_notice("Вы отключаете ограничения на общий канал у [declent_ru(GENITIVE)]."))
	log_game("[key_name(user)] emagged [src]")
	return TRUE

/// Whether the radio has limited common channel access
/obj/item/radio/proc/has_limited_common_channel_access()
	return respects_common_channel_limitations

/obj/item/radio/headset/has_limited_common_channel_access()
	if(!respects_common_channel_limitations)
		return FALSE
	if(keyslot1 && keyslot1.grants_common_channel_access)
		return FALSE
	if(keyslot2 && keyslot2.grants_common_channel_access)
		return FALSE
	return TRUE

/obj/item/radio/borg/has_limited_common_channel_access()
	if(!respects_common_channel_limitations)
		return FALSE
	if(keyslot && keyslot.grants_common_channel_access)
		return FALSE
	return TRUE

/obj/item/radio/intercom
	canhear_range = 1
	respects_common_channel_limitations = FALSE

/obj/item/radio/intercom/department
	canhear_range = 1

/obj/item/radio/headset/chameleon
	respects_common_channel_limitations = FALSE

/obj/item/encryptionkey
	/// Whether the key grants access to the common channel
	var/grants_common_channel_access = FALSE

/obj/item/encryptionkey/heads
	grants_common_channel_access = TRUE

/obj/item/encryptionkey/headset_nct
	grants_common_channel_access = TRUE

/obj/item/encryptionkey/ert
	grants_common_channel_access = TRUE

/obj/item/encryptionkey/skrell
	grants_common_channel_access = TRUE

/obj/item/encryptionkey/centcom
	grants_common_channel_access = TRUE

/obj/item/encryptionkey/syndicate
	grants_common_channel_access = TRUE
