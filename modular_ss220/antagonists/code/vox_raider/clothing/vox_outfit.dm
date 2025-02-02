// Outfit
/datum/outfit/vox
	name = "Vox Crew"
	uniform = /obj/item/clothing/under/vox/jumpsuit
	gloves = /obj/item/clothing/gloves/vox
	shoes = /obj/item/clothing/shoes/roman/vox
	l_ear = /obj/item/radio/headset/vox
	id = /obj/item/card/id/syndicate/vox
	l_pocket = /obj/item/melee/classic_baton/telescopic

	back = /obj/item/storage/backpack/vox
	backpack_contents = list(
		/obj/item/clothing/mask/breath/vox/respirator = 1,
		/obj/item/tank/internals/emergency_oxygen/double/vox = 1,
		/obj/item/flashlight = 1,
		/obj/item/flash = 1,
		/obj/item/clothing/suit/space/vox/pressure = 1,
		/obj/item/clothing/head/helmet/space/vox/pressure = 1,
	)

/datum/outfit/vox/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	var/choosen = rand(1, 8)
	switch(choosen)
		if(1)
			uniform = /obj/item/clothing/under/vox/jumpsuit/red
		if(2)
			uniform = /obj/item/clothing/under/vox/jumpsuit/teal
		if(3)
			uniform = /obj/item/clothing/under/vox/jumpsuit/blue
		if(4)
			uniform = /obj/item/clothing/under/vox/jumpsuit/green
		if(5)
			uniform = /obj/item/clothing/under/vox/jumpsuit/yellow
		if(6)
			uniform = /obj/item/clothing/under/vox/jumpsuit/purple
		else
			uniform = /obj/item/clothing/under/vox/jumpsuit

	if(prob(5))
		uniform = /obj/item/clothing/suit/hooded/vox_robes

	if(prob(50))
		back = /obj/item/storage/backpack/satchel_flat/vox
		if(prob(25))
			back = /obj/item/storage/backpack/duffel/vox

/datum/outfit/vox/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS, ACCESS_VOX, ACCESS_EXTERNAL_AIRLOCKS), "Vox Skipjack Crew", "data")

	if(internals_slot)
		H.internal = H.get_item_by_slot(internals_slot)
		H.update_action_buttons_icon()

/obj/item/card/id/syndicate/vox
	name = "vox data card"
	icon_state = "data"

// ==================== Raiders ====================
/datum/outfit/vox/raider
	name = "vox raider"
	suit = /obj/item/clothing/suit/space/hardsuit/vox
	suit_store = /obj/item/tank/internals/emergency_oxygen/double/vox
	gloves = /obj/item/clothing/gloves/color/yellow/vox
	shoes = /obj/item/clothing/shoes/magboots/vox
	l_ear = /obj/item/radio/headset/vox/alt

/datum/outfit/vox/raider/trooper
	name = "vox raider trooper"
	suit = /obj/item/clothing/suit/space/hardsuit/vox/trooper
	shoes = /obj/item/clothing/shoes/magboots/vox/combat

/datum/outfit/vox/raider/scout
	name = "vox raider scout"
	suit = /obj/item/clothing/suit/space/hardsuit/vox/scout
	shoes = /obj/item/clothing/shoes/magboots/vox/scout

/datum/outfit/vox/raider/medic
	name = "vox raider medic"
	suit = /obj/item/clothing/suit/space/hardsuit/vox/medic

/datum/outfit/vox/raider/mechanic
	name = "vox raider mechanic"
	suit = /obj/item/clothing/suit/space/hardsuit/vox/mechanic
	shoes = /obj/item/clothing/shoes/magboots/vox/heavy

/datum/outfit/vox/raider/heavy
	name = "vox raider heavy"
	suit = /obj/item/clothing/suit/space/hardsuit/vox/heavy
	shoes = /obj/item/clothing/shoes/magboots/vox/heavy


// ==================== Mercenaries ====================
/datum/outfit/vox/merc
	name = "vox mercenary"
	suit = /obj/item/clothing/suit/armor/vox_merc
	head = /obj/item/clothing/head/helmet/vox_merc
	gloves = /obj/item/clothing/gloves/color/yellow/vox
	shoes = /obj/item/clothing/shoes/magboots/vox
	l_ear = /obj/item/radio/headset/vox/alt

/datum/outfit/vox/merc/storm
	name = "vox mercenary stormtrooper"
	suit = /obj/item/clothing/suit/armor/vox_merc/stormtrooper
	head = /obj/item/clothing/head/helmet/vox_merc/stormtrooper
	shoes = /obj/item/clothing/shoes/magboots/vox/combat

/datum/outfit/vox/merc/fieldmedic
	name = "vox mercenary field medic"
	suit = /obj/item/clothing/suit/armor/vox_merc/fieldmedic
	head = /obj/item/clothing/head/helmet/vox_merc/fieldmedic

/datum/outfit/vox/merc/bomber
	name = "vox mercenary bomber"
	suit = /obj/item/clothing/suit/armor/vox_merc/bomber
	head = /obj/item/clothing/head/helmet/vox_merc/bomber
	shoes = /obj/item/clothing/shoes/magboots/vox/heavy

/datum/outfit/vox/merc/laminar
	name = "vox mercenary laminar"
	suit = /obj/item/clothing/suit/armor/vox_merc/laminar
	head = /obj/item/clothing/head/helmet/vox_merc/laminar

/datum/outfit/vox/merc/laminar/scout
	name = "vox mercenary laminar scout"
	suit = /obj/item/clothing/suit/armor/vox_merc/laminar/scout
	shoes = /obj/item/clothing/shoes/magboots/vox/scout

/datum/outfit/vox/merc/stealth
	name = "vox mercenary stealth"
	suit = /obj/item/clothing/suit/armor/vox_merc/stealth
	head = /obj/item/clothing/head/helmet/vox_merc/stealth


// ==================== Other ====================
/datum/outfit/vox/carapace
	name = "Vox Carapace"
	uniform = /obj/item/clothing/suit/hooded/vox_robes
	suit = /obj/item/clothing/suit/space/vox/carapace
	gloves = /obj/item/clothing/gloves/color/yellow/vox
	shoes = /obj/item/clothing/shoes/magboots/vox
	head = /obj/item/clothing/head/helmet/space/vox/carapace
	mask = /obj/item/clothing/mask/gas/syndicate
	glasses = /obj/item/clothing/glasses/thermal/monocle
	l_ear = /obj/item/radio/headset/vox/alt

/datum/outfit/vox/carapace/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	uniform = /obj/item/clothing/suit/hooded/vox_robes
	back = /obj/item/storage/backpack/vox
