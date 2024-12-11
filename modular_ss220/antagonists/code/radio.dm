// =============== FREQUENCE ===============
// Часть модуля кода частот в /datum/modpack/antagonists/initialize()


/datum/controller/subsystem/blackbox/LogBroadcast(freq)
	if(sealed)
		return
	switch(freq)
		if(VOX_RAID_FREQ)
			record_feedback("tally", "radio_usage", 1, "voxcom")
	. = ..()


// =============== HEADSETS ===============

/obj/item/radio/headset/vox
	name = "vox headset"
	desc = "Наушник дальней связи для поддержания связи со стаей."
	origin_tech = "syndicate=3"
	ks1type = /obj/item/encryptionkey/vox
	requires_tcomms = FALSE
	instant = TRUE // Work instantly if there are no comms
	freqlock = TRUE
	frequency = VOX_RAID_FREQ

/obj/item/radio/headset/vox/alt
	name = "vox protect headset"
	desc = "Наушник дальней связи для поддержания связи со стаей. Защищает ушные раковины от громких звуков"
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"
	origin_tech = "syndicate=3"
	flags = EARBANGPROTECT

/obj/item/encryptionkey/vox
	name = "syndicate encryption key"
	icon = 'modular_ss220/antagonists/icons/trader_machine.dmi'
	icon_state = "vox_key"
	channels = list("VoxCom" = 1, "Syndicate" = 1)
	origin_tech = "syndicate=3"
	syndie = TRUE
