GLOBAL_VAR_INIT(vox_raiders_radio_freq, PUBLIC_LOW_FREQ + rand(0, 8) * 2) //Random freq every round

/mob/living/carbon/human/proc/equip_vox_raider()
	equip_to_slot_or_del(new /obj/item/radio/headset(src), slot_r_ear) //radio hedset with common freq, for communicate with station
	var/obj/item/radio/R = new /obj/item/radio/headset(src)
	R.set_frequency(GLOB.vox_raiders_radio_freq) //radio hedset with random vox freq, for raders communication
	equip_to_slot_or_del(R, slot_l_ear)

	equip_to_slot_or_del(new /obj/item/clothing/under/vox/vox_robes(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/vox(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow/vox(src), slot_gloves)
	equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(src), slot_belt)
	equip_to_slot_or_del(new /obj/item/storage/backpack/alien/satchel(src), slot_back)
	equip_to_slot_or_del(new /obj/item/flashlight(src), slot_r_store)
	equip_to_slot_or_del(new /obj/item/melee/classic_baton/telescopic(src), slot_l_store)
	equip_to_slot_or_del(new /obj/item/tank/internals/nitrogen(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/clothing/mask/breath/vox(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/restraints/handcuffs/cable/zipties(src), slot_in_backpack)
	equip_to_slot_or_del(new /obj/item/restraints/handcuffs/cable/zipties(src), slot_in_backpack)

	var/obj/item/card/id/syndicate/vox/W = new(src)
	W.name = "[real_name]'s Legitimate Human ID Card"
	W.assignment = "Trader"
	W.registered_name = real_name
	W.registered_user = src
	equip_to_slot_or_del(W, slot_wear_id)

	return 1
