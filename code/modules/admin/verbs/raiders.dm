/mob/living/carbon/human/proc/equip_raider()

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(src)
	R.set_frequency(SYND_FREQ) //Same frequency as the syndicate team in Nuke mode.
	equip_or_collect(R, slot_l_ear) // Less talking, more raiding

	//ALL BASIC EQUIPMENT WILL GET REPLACED WITH COOL SHIT BEFORE THIS GETS MERGED, I JUST NEED SPRITE SLAVES
	//ALSO, THIS WILL HANDLE DIFFERENT SPECIES LIKE VOX AND PLASMAMEN, BECAUSE IT'S A BIT TOO SPECIFIC TO BE HANDLED UNDER THE SPECIES' equip()
	equip_or_collect(new /obj/item/clothing/under/color/black(src), slot_w_uniform)
	equip_or_collect(new /obj/item/clothing/shoes/combat(src), slot_shoes)
	equip_or_collect(new /obj/item/clothing/gloves/color/black(src), slot_gloves)
	equip_or_collect(new /obj/item/weapon/storage/backpack/duffel(src), slot_back)
	equip_or_collect(new /obj/item/device/flashlight(src), slot_r_store)

	var/obj/item/weapon/card/id/syndicate/raider/W = new(src)
	W.name = "[real_name]'s Legitimate Nanotrasen ID card"
	if(prob(1))
		W.assignment = "Space Pirate"
	else
		W.assignment = "Trader"
	W.registered_name = real_name
	W.registered_user = src
	equip_to_slot_or_del(W, slot_wear_id)
	return 1
