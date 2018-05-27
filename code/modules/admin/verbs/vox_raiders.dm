var/global/vox_tick = 1

/mob/living/carbon/human/proc/equip_vox_raider()

	var/obj/item/radio/R = new /obj/item/radio/headset/syndicate(src)
	R.set_frequency(SYND_FREQ) //Same frequency as the syndicate team in Nuke mode.
	equip_to_slot_or_del(R, slot_l_ear)

	equip_to_slot_or_del(new /obj/item/clothing/under/vox/vox_robes(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/vox(src), slot_shoes) // REPLACE THESE WITH CODED VOX ALTERNATIVES.
	equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow/vox(src), slot_gloves) // AS ABOVE.

	switch(vox_tick)
		if(1) // Vox raider!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/carapace(src), slot_wear_suit)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/carapace(src), slot_head)
			equip_to_slot_or_del(new /obj/item/melee/classic_baton/telescopic(src), slot_belt)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(src), slot_glasses) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/chameleon(src), slot_l_store)

			var/obj/item/gun/projectile/automatic/spikethrower/W = new(src)
			equip_to_slot_or_del(W, slot_r_hand)


		if(2) // Vox engineer!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/pressure(src), slot_wear_suit)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/pressure(src), slot_head)
			equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(src), slot_belt)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/meson(src), slot_glasses) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/storage/box/emps(src), slot_r_hand)
			equip_to_slot_or_del(new /obj/item/multitool(src), slot_l_hand)


		if(3) // Vox saboteur!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/stealth(src), slot_wear_suit)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/stealth(src), slot_head)
			equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(src), slot_belt)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(src), slot_glasses) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/card/emag(src), slot_l_store)
			equip_to_slot_or_del(new /obj/item/gun/dartgun/vox/raider(src), slot_r_hand)
			equip_to_slot_or_del(new /obj/item/multitool(src), slot_l_hand)

		if(4) // Vox medic!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/medic(src), slot_wear_suit)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/medic(src), slot_head)
			equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(src), slot_belt) // Who needs actual surgical tools?
			equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(src), slot_glasses) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/circular_saw(src), slot_l_store)
			equip_to_slot_or_del(new /obj/item/gun/dartgun/vox/medical, slot_r_hand)

	equip_to_slot_or_del(new /obj/item/clothing/mask/breath/vox(src), slot_wear_mask)
	equip_to_slot_or_del(new /obj/item/tank/nitrogen(src), slot_back)
	equip_to_slot_or_del(new /obj/item/flashlight(src), slot_r_store)

	var/obj/item/card/id/syndicate/vox/W = new(src)
	W.name = "[real_name]'s Legitimate Human ID Card"
	W.assignment = "Trader"
	W.registered_name = real_name
	W.registered_user = src
	equip_to_slot_or_del(W, slot_wear_id)

	vox_tick++
	if(vox_tick > 4) vox_tick = 1

	return 1
