/datum/outfit
	var/name = "Naked"
	var/collect_not_del = FALSE

	var/uniform = null
	var/suit = null
	var/back = null
	var/belt = null
	var/gloves = null
	var/shoes = null
	var/head = null
	var/mask = null
	var/l_ear = null
	var/r_ear = null
	var/glasses = null
	var/id = null
	var/l_pocket = null
	var/r_pocket = null
	var/suit_store = null
	var/l_hand = null
	var/r_hand = null
	/// Should the toggle helmet proc be called on the helmet during equip
	var/toggle_helmet = TRUE
	var/pda = null
	var/internals_slot = null //ID of slot containing a gas tank
	var/list/backpack_contents = list() // In the list(path=count,otherpath=count) format
	var/box // Internals box. Will be inserted at the start of backpack_contents
	var/list/implants = list()
	var/list/cybernetic_implants = list()
	var/list/accessories = list()

	var/list/chameleon_extras //extra types for chameleon outfit changes, mostly guns

	var/can_be_admin_equipped = TRUE // Set to FALSE if your outfit requires runtime parameters

/datum/outfit/proc/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overriden for customization depending on client prefs,species etc
	return

// Used to equip an item to the mob. Mainly to prevent copypasta for collect_not_del.
/datum/outfit/proc/equip_item(mob/living/carbon/human/H, path, slot)
	var/obj/item/I = new path(H)
	if(collect_not_del)
		H.equip_or_collect(I, slot)
	else
		H.equip_to_slot_or_del(I, slot)

/datum/outfit/proc/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overriden for toggling internals, id binding, access etc
	return

/datum/outfit/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	pre_equip(H, visualsOnly)

	//Start with uniform,suit,backpack for additional slots
	if(uniform)
		equip_item(H, uniform, slot_w_uniform)
	if(suit)
		equip_item(H, suit, slot_wear_suit)
	if(back)
		equip_item(H, back, slot_back)
	if(belt)
		equip_item(H, belt, slot_belt)
	if(gloves)
		equip_item(H, gloves, slot_gloves)
	if(shoes)
		equip_item(H, shoes, slot_shoes)
	if(head)
		equip_item(H, head, slot_head)
	if(mask)
		equip_item(H, mask, slot_wear_mask)
	if(l_ear)
		equip_item(H, l_ear, slot_l_ear)
	if(r_ear)
		equip_item(H, r_ear, slot_r_ear)
	if(glasses)
		equip_item(H, glasses, slot_glasses)
	if(id)
		equip_item(H, id, slot_wear_id)
	if(suit_store)
		equip_item(H, suit_store, slot_s_store)

	if(l_hand)
		H.put_in_l_hand(new l_hand(H))
	if(r_hand)
		H.put_in_r_hand(new r_hand(H))

	if(pda)
		equip_item(H, pda, slot_wear_pda)

	if(uniform)
		for(var/path in accessories)
			var/obj/item/clothing/accessory/A = new path()
			var/obj/item/clothing/under/U = uniform
			U.attach_accessory(A, H)

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(l_pocket)
			equip_item(H, l_pocket, slot_l_store)
		if(r_pocket)
			equip_item(H, r_pocket, slot_r_store)

		if(box)
			if(!backpack_contents)
				backpack_contents = list()
			backpack_contents.Insert(1, box)
			backpack_contents[box] = 1

		for(var/path in backpack_contents)
			var/number = backpack_contents[path]
			for(var/i in 1 to number)
				H.equip_or_collect(new path(H), slot_in_backpack)

		for(var/path in cybernetic_implants)
			var/obj/item/organ/internal/O = new path(H)
			O.insert(H)

	if(!H.head && toggle_helmet && istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/HS = H.wear_suit
		HS.ToggleHelmet()

	post_equip(H, visualsOnly)

	if(!visualsOnly)
		apply_fingerprints(H)
		if(internals_slot)
			H.internal = H.get_item_by_slot(internals_slot)
			H.update_action_buttons_icon()

	if(implants)
		for(var/implant_type in implants)
			var/obj/item/implant/I = new implant_type(H)
			I.implant(H, null)

	H.update_body()
	return 1

/datum/outfit/proc/apply_fingerprints(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(H.back)
		H.back.add_fingerprint(H, 1)	//The 1 sets a flag to ignore gloves
		for(var/obj/item/I in H.back.contents)
			I.add_fingerprint(H, 1)
	if(H.wear_id)
		H.wear_id.add_fingerprint(H, 1)
	if(H.w_uniform)
		H.w_uniform.add_fingerprint(H, 1)
	if(H.wear_suit)
		H.wear_suit.add_fingerprint(H, 1)
	if(H.wear_mask)
		H.wear_mask.add_fingerprint(H, 1)
	if(H.head)
		H.head.add_fingerprint(H, 1)
	if(H.shoes)
		H.shoes.add_fingerprint(H, 1)
	if(H.gloves)
		H.gloves.add_fingerprint(H, 1)
	if(H.l_ear)
		H.l_ear.add_fingerprint(H, 1)
	if(H.r_ear)
		H.r_ear.add_fingerprint(H, 1)
	if(H.glasses)
		H.glasses.add_fingerprint(H, 1)
	if(H.belt)
		H.belt.add_fingerprint(H, 1)
		for(var/obj/item/I in H.belt.contents)
			I.add_fingerprint(H, 1)
	if(H.s_store)
		H.s_store.add_fingerprint(H, 1)
	if(H.l_store)
		H.l_store.add_fingerprint(H, 1)
	if(H.r_store)
		H.r_store.add_fingerprint(H, 1)
	if(H.wear_pda)
		H.wear_pda.add_fingerprint(H, 1)
	return 1

/datum/outfit/proc/get_chameleon_disguise_info()
	var/list/types = list(uniform, suit, back, belt, gloves, shoes, head, mask, l_ear, r_ear, glasses, id, l_pocket, r_pocket, suit_store, r_hand, l_hand, pda)
	types += chameleon_extras
	listclearnulls(types)
	return types

/datum/outfit/proc/save_to_file(mob/admin)
	var/stored_data = get_json_data()
	var/json = json_encode(stored_data)
	// Kinda annoying but as far as I can tell you need to make actual file.
	var/f = file("data/TempOutfitUpload")
	fdel(f)
	WRITE_FILE(f, json)
	admin << ftp(f, "[name].json")

/datum/outfit/proc/load_from(list/outfit_data)
	// This could probably use more strict validation.
	name = outfit_data["name"]
	uniform = text2path(outfit_data["uniform"])
	suit = text2path(outfit_data["suit"])
	toggle_helmet = text2path(outfit_data["toggle_helmet"])
	back = text2path(outfit_data["back"])
	belt = text2path(outfit_data["belt"])
	gloves = text2path(outfit_data["gloves"])
	shoes = text2path(outfit_data["shoes"])
	head = text2path(outfit_data["head"])
	mask = text2path(outfit_data["mask"])
	l_ear = text2path(outfit_data["l_ear"])
	r_ear = text2path(outfit_data["r_ear"])
	glasses = text2path(outfit_data["glasses"])
	id = text2path(outfit_data["id"])
	pda = text2path(outfit_data["pda"])
	l_pocket = text2path(outfit_data["l_pocket"])
	r_pocket = text2path(outfit_data["r_pocket"])
	suit_store = text2path(outfit_data["suit_store"])
	r_hand = text2path(outfit_data["r_hand"])
	l_hand = text2path(outfit_data["l_hand"])
	internals_slot = text2path(outfit_data["internals_slot"])

	var/list/backpack = outfit_data["backpack_contents"]
	backpack_contents = list()
	for(var/item in backpack)
		var/itype = text2path(item)
		if(itype)
			backpack_contents[itype] = backpack[item]
	box = text2path(outfit_data["box"])

	var/list/impl = outfit_data["implants"]
	implants = list()
	for(var/I in impl)
		var/imptype = text2path(I)
		if(imptype)
			implants += imptype

	var/list/cybernetic_impl = outfit_data["cybernetic_implants"]
	cybernetic_implants = list()
	for(var/I in cybernetic_impl)
		var/cybtype = text2path(I)
		if(cybtype)
			cybernetic_implants += cybtype

	var/list/accessories = outfit_data["accessories"]
	accessories = list()
	for(var/A in accessories)
		var/accessorytype = text2path(A)
		if(accessorytype)
			accessories += accessorytype

	return TRUE

/datum/outfit/proc/get_json_data()
	. = list()
	.["outfit_type"] = type
	.["name"] = name
	.["uniform"] = uniform
	.["suit"] = suit
	.["toggle_helmet"] = toggle_helmet
	.["back"] = back
	.["belt"] = belt
	.["gloves"] = gloves
	.["shoes"] = shoes
	.["head"] = head
	.["mask"] = mask
	.["l_ear"] = l_ear
	.["r_ear"] = r_ear
	.["glasses"] = glasses
	.["id"] = id
	.["pda"] = pda
	.["l_pocket"] = l_pocket
	.["r_pocket"] = r_pocket
	.["suit_store"] = suit_store
	.["r_hand"] = r_hand
	.["l_hand"] = l_hand
	.["internals_slot"] = internals_slot
	.["backpack_contents"] = backpack_contents
	.["box"] = box
	.["implants"] = implants
	.["cybernetic_implants"] = cybernetic_implants
	.["accessories"] = accessories
