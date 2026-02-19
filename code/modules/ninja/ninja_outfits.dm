/datum/outfit/space_ninja
	name = "Space Ninja"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/space_ninja
	gloves = /obj/item/clothing/gloves/space_ninja
	head = /obj/item/clothing/head/helmet/space_ninja
	mask = /obj/item/clothing/mask/gas/space_ninja
	glasses = /obj/item/clothing/glasses/night
	suit = /obj/item/clothing/suit/space_ninja
	belt = /obj/item/katana/energy
	id = /obj/item/card/id/syndicate/ninja
	back = /obj/item/storage/backpack/satchel
	l_ear = /obj/item/radio/headset
	box = /obj/item/storage/box/survival_syndie
	backpack_contents = list(
		/obj/item/storage/box/syndie_kit/throwing_weapons,
		/obj/item/ninja_scanner,
		/obj/item/gun/energy/kinetic_accelerator/energy_net,
		/obj/item/wormhole_jaunter/extraction,
		/obj/item/teleportation_scroll/apprentice,
	)
	bio_chips = list(
		/obj/item/bio_chip/dust,
		/obj/item/bio_chip/uplink/ninja
	)

/datum/outfit/space_ninja/vox
	name = "Space Ninja - Vox"

/datum/outfit/space_ninja/vox/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	var/obj/item/tank/internal_tank = new /obj/item/tank/internals/emergency_oxygen/double/vox(H)
	if(!H.equip_to_appropriate_slot(internal_tank))
		if(!H.put_in_any_hand_if_possible(internal_tank))
			H.drop_item_to_ground(H.l_hand)
			H.equip_or_collect(internal_tank, ITEM_SLOT_LEFT_HAND)
			to_chat(H, "<span class='boldannounceooc'>Could not find an empty slot for internals! Please report this as a bug</span>")
	H.internal = internal_tank

/datum/outfit/admin/ghostbar_antag/space_ninja
	name = "Ghostbar Space Ninja"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/space_ninja
	gloves = /obj/item/clothing/gloves/space_ninja
	head = /obj/item/clothing/head/helmet/space_ninja
	mask = /obj/item/clothing/mask/gas/space_ninja
	suit = /obj/item/clothing/suit/space_ninja
	belt = /obj/item/toy/katana
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1,
		/obj/item/flashlight = 1,
		/obj/item/food/syndidonkpocket = 1,
	)
