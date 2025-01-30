/datum/outfit
	var/name = "SOMEBODY FORGOT TO SET A NAME, NOTIFY A CODER"
	var/collect_not_del = FALSE

	var/uniform = null
	var/suit = null
	var/back = null
	var/belt = null
	var/gloves = null
	var/shoes = null
	var/head = null
	var/mask = null
	var/neck = null
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
	var/list/bio_chips = list()
	var/list/cybernetic_implants = list()
	var/list/accessories = list()

	var/list/chameleon_extras //extra types for chameleon outfit changes, mostly guns

	var/can_be_admin_equipped = TRUE // Set to FALSE if your outfit requires runtime parameters

/datum/outfit/naked
	name = "Naked"

/datum/outfit/proc/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overriden for customization depending on client prefs,species etc
	return

// Used to equip an item to the mob. Mainly to prevent copypasta for collect_not_del.
/datum/outfit/proc/equip_item(mob/living/carbon/human/H, path, slot)
	var/obj/item/I = new path(H)
	if(collect_not_del)
		H.equip_or_collect(I, slot, TRUE)
	else
		H.equip_to_slot_or_del(I, slot, TRUE)

/datum/outfit/proc/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overriden for toggling internals, id binding, access etc
	SHOULD_CALL_PARENT(TRUE)
	if(visualsOnly)
		return

	if(H.mind)
		on_mind_initialize(H)
		return
	RegisterSignal(H, COMSIG_MIND_INITIALIZE, PROC_REF(on_mind_initialize))

// Guaranteed access to mind, will never be called if visualsOnly = TRUE
/datum/outfit/proc/on_mind_initialize(mob/living/carbon/human/H)
	SIGNAL_HANDLER // COMSIG_MIND_INITIALIZE
	SHOULD_CALL_PARENT(TRUE)
	UnregisterSignal(H, COMSIG_MIND_INITIALIZE) // prevent this call from being called multiple times on a human

/datum/outfit/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	pre_equip(H, visualsOnly)

	//Start with uniform,suit,backpack for additional slots
	if(uniform)
		equip_item(H, uniform, ITEM_SLOT_JUMPSUIT)
	if(suit)
		equip_item(H, suit, ITEM_SLOT_OUTER_SUIT)
	if(back)
		equip_item(H, back, ITEM_SLOT_BACK)
	if(belt)
		equip_item(H, belt, ITEM_SLOT_BELT)
	if(gloves)
		equip_item(H, gloves, ITEM_SLOT_GLOVES)
	if(shoes)
		equip_item(H, shoes, ITEM_SLOT_SHOES)
	if(head)
		equip_item(H, head, ITEM_SLOT_HEAD)
	if(mask)
		equip_item(H, mask, ITEM_SLOT_MASK)
	if(neck)
		equip_item(H, neck, ITEM_SLOT_NECK)
	if(l_ear)
		equip_item(H, l_ear, ITEM_SLOT_LEFT_EAR)
	if(r_ear)
		equip_item(H, r_ear, ITEM_SLOT_RIGHT_EAR)
	if(glasses)
		equip_item(H, glasses, ITEM_SLOT_EYES)
	if(id)
		equip_item(H, id, ITEM_SLOT_ID)

	if(!H.head && toggle_helmet && istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/HS = H.wear_suit
		HS.ToggleHelmet()
	else if(toggle_helmet && ismodcontrol(H.back))
		var/obj/item/mod/control/C = H.back
		C.quick_activation()

	if(suit_store)
		equip_item(H, suit_store, ITEM_SLOT_SUIT_STORE)

	if(l_hand)
		H.put_in_l_hand(new l_hand(H))
	if(r_hand)
		H.put_in_r_hand(new r_hand(H))

	if(pda)
		equip_item(H, pda, ITEM_SLOT_PDA)

	if(uniform)
		for(var/path in accessories)
			var/obj/item/clothing/accessory/A = new path()
			var/obj/item/clothing/under/U = uniform
			U.attach_accessory(A, H)

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(l_pocket)
			equip_item(H, l_pocket, ITEM_SLOT_LEFT_POCKET)
		if(r_pocket)
			equip_item(H, r_pocket, ITEM_SLOT_RIGHT_POCKET)

		if(box)
			if(!backpack_contents)
				backpack_contents = list()
			backpack_contents.Insert(1, box)
			backpack_contents[box] = 1

		for(var/path in backpack_contents)
			var/number = backpack_contents[path]
			if(!number)
				number = 1
			for(var/i in 1 to number)
				H.equip_or_collect(new path(H), ITEM_SLOT_IN_BACKPACK)

		for(var/path in cybernetic_implants)
			var/obj/item/organ/internal/O = new path
			O.insert(H)

	post_equip(H, visualsOnly)

	if(!visualsOnly)
		apply_fingerprints(H)
		if(internals_slot)
			H.internal = H.get_item_by_slot(internals_slot)
			H.update_action_buttons_icon()

	if(bio_chips)
		for(var/bio_chip_type in bio_chips)
			var/obj/item/bio_chip/I = new bio_chip_type(H)
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
	if(H.neck)
		H.neck.add_fingerprint(H, 1)
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
	var/list/types = list(uniform, suit, back, belt, gloves, shoes, head, mask, neck, l_ear, r_ear, glasses, id, l_pocket, r_pocket, suit_store, r_hand, l_hand, pda)
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
	neck = text2path(outfit_data["neck"])
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

	var/list/impl = outfit_data["bio_chips"]
	bio_chips = list()
	for(var/I in impl)
		var/imptype = text2path(I)
		if(imptype)
			bio_chips += imptype

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
	.["neck"] = neck
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
	.["bio_chips"] = bio_chips
	.["cybernetic_implants"] = cybernetic_implants
	.["accessories"] = accessories

// Butler outfit
/datum/outfit/butler
	name = "Butler"
	uniform = /obj/item/clothing/under/suit/really_black
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/bowlerhat
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/white
