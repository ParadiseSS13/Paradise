/obj/item/radio/borg/proc/make_syndie()
	qdel(keyslot)
	keyslot = new /obj/item/encryptionkey/syndicate
	syndiekey = keyslot
	syndie = TRUE
	recalculateChannels()
