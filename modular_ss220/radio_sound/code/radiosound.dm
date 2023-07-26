/obj/item/radio/headset
	var/radiosound = 'modular_ss220/radio_sound/sound/common.ogg'

/obj/item/radio/headset/syndicate //disguised to look like a normal headset for stealth ops
	radiosound = 'modular_ss220/radio_sound/sound/syndie.ogg'

/obj/item/radio/headset/headset_sec
	radiosound = 'modular_ss220/radio_sound/sound/security.ogg'

/obj/item/radio/headset/talk_into(mob/living/M as mob, list/message_pieces, channel, verbage = "says")
	if(!on)
		return FALSE // the device has to be on

	if(radiosound && listening)
		playsound(M, radiosound, rand(20, 30))
	. = ..()
