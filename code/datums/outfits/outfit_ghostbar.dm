/datum/outfit/admin/ghostbar_antag
	name = "Ghostly Antagonist"

	l_ear = /obj/item/radio/headset/deadsay
	l_pocket = /obj/item/stack/spacecash/c1000
	id = /obj/item/card/id/syndicate
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/ghostbar_antag/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/our_id = H.wear_id
	if(!istype(our_id))
		return
	apply_to_card(our_id, H, list(ACCESS_MAINT_TUNNELS), name)
	our_id.assignment = src.name
	our_id.registered_name = H.real_name
	our_id.sex = capitalize(H.gender)
	our_id.age = H.age
	our_id.name = "[our_id.registered_name]'s ID Card ([our_id.assignment])"
	our_id.photo = get_id_photo(H)
	our_id.owner_uid = H.UID()
	our_id.owner_ckey = H.ckey
	our_id.icon_state = "syndie"
	H.job = src.name

	H.mind.assigned_role = src.name
	H.mind.special_role = src.name
	H.mind.offstation_role = TRUE

	H.sec_hud_set_ID()

/datum/outfit/admin/ghostbar_antag/syndicate
	name = "Syndicate Agent"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/jacket/bomber/syndicate
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1,
		/obj/item/flashlight = 1,
		/obj/item/food/syndidonkpocket = 1,
		/obj/item/gun/projectile/automatic/toy/pistol = 1,
		/obj/item/ammo_box/magazine/toy/pistol = 2
	)

/datum/outfit/admin/ghostbar_antag/syndicate/plasmaman
	name = "Syndicate Plasmaman"

	head = /obj/item/clothing/head/helmet/space/plasmaman
	uniform = /obj/item/clothing/under/plasmaman

/datum/outfit/admin/ghostbar_antag/vampire
	name = "Vampire"

	uniform = /obj/item/clothing/under/suit/black
	suit = /obj/item/clothing/suit/draculacoat
	neck = /obj/item/clothing/neck/cloak
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/black
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1,
		/obj/item/reagent_containers/iv_bag/blood/o_plus = 3
	)

/datum/outfit/admin/ghostbar_antag/vampire/plasmaman
	name = "Vampire Plasmaman"

	head = /obj/item/clothing/head/helmet/space/plasmaman
	uniform = /obj/item/clothing/under/plasmaman

/datum/outfit/admin/ghostbar_antag/changeling
	name = "Changeling"

	uniform = /obj/item/clothing/under/chameleon
	suit = /obj/item/clothing/suit/chameleon
	neck = /obj/item/clothing/neck/chameleon
	back = /obj/item/storage/backpack/chameleon
	gloves = /obj/item/clothing/gloves/chameleon
	shoes = /obj/item/clothing/shoes/chameleon
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1,
		/obj/item/toy/foamblade = 1
	)

/datum/outfit/admin/ghostbar_antag/changeling/plasmaman
	name = "Changeling Plasmaman"

	head = /obj/item/clothing/head/helmet/space/plasmaman
	uniform = /obj/item/clothing/under/plasmaman

/datum/outfit/admin/ghostbar_antag/mindflayer
	name = "Mindflayer"

	uniform = /obj/item/clothing/under/psysuit
	suit = /obj/item/clothing/suit/blacktrenchcoat
	neck = /obj/item/clothing/neck/cloak
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/black
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1,
		/obj/item/toy/plushie/ipcplushie = 1
	)

/datum/outfit/admin/ghostbar_antag/mindflayer/plasmaman
	name = "Mindflayer Plasmaman"

	head = /obj/item/clothing/head/helmet/space/plasmaman
	uniform = /obj/item/clothing/under/plasmaman
