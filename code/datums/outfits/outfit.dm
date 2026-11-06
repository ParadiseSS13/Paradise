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

	/// if some species replace outfit parts, those sub-outfits go here.
	var/list/species_outfits = list("Plasmaman", /datum/outfit/plasmaman)

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

	var/datum/outfit/species_outfit = null
	if(H.dna.species.name in species_outfits)
		species_outfit = new species_outfits[H.dna.species.name]
	//Start with uniform,suit,backpack for additional slots
	if(uniform || species_outfit?.uniform)
		equip_item(H, species_outfit?.uniform || uniform, ITEM_SLOT_JUMPSUIT)
	if(suit || species_outfit?.suit)
		equip_item(H, species_outfit?.suit || suit, ITEM_SLOT_OUTER_SUIT)
	if(back || species_outfit?.back)
		equip_item(H, species_outfit?.back || back, ITEM_SLOT_BACK)
	if(belt || species_outfit?.belt)
		equip_item(H, species_outfit?.belt || belt, ITEM_SLOT_BELT)
	if(gloves || species_outfit?.gloves)
		equip_item(H, species_outfit?.gloves || gloves, ITEM_SLOT_GLOVES)
	if(shoes || species_outfit?.shoes)
		equip_item(H, species_outfit?.shoes || shoes, ITEM_SLOT_SHOES)
	if(head || species_outfit?.head)
		equip_item(H, species_outfit?.head || head, ITEM_SLOT_HEAD)
	if(mask || species_outfit?.mask)
		equip_item(H, species_outfit?.mask || mask, ITEM_SLOT_MASK)
	if(neck || species_outfit?.neck)
		equip_item(H, species_outfit?.neck || neck, ITEM_SLOT_NECK)
	if(l_ear || species_outfit?.l_ear)
		equip_item(H, species_outfit?.l_ear || l_ear, ITEM_SLOT_LEFT_EAR)
	if(r_ear || species_outfit?.r_ear)
		equip_item(H, species_outfit?.r_ear || r_ear, ITEM_SLOT_RIGHT_EAR)
	if(glasses || species_outfit?.glasses)
		equip_item(H, species_outfit?.glasses || glasses, ITEM_SLOT_EYES)
	if(id)
		equip_item(H, id, ITEM_SLOT_ID)

	if(!H.head && toggle_helmet && istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/HS = H.wear_suit
		HS.ToggleHelmet()
	else if(toggle_helmet && ismodcontrol(H.back))
		var/obj/item/mod/control/C = H.back
		C.quick_activation()

	if(suit_store || species_outfit?.suit_store)
		equip_item(H, species_outfit?.suit_store || suit_store, ITEM_SLOT_SUIT_STORE)

	if(l_hand || species_outfit?.l_hand)
		var/hand_path = species_outfit?.l_hand || l_hand
		H.put_in_l_hand(new hand_path(H))
	if(r_hand || species_outfit?.r_hand)
		var/hand_path = species_outfit?.r_hand || r_hand
		H.put_in_r_hand(new hand_path(H))

	if(pda || species_outfit?.pda)
		equip_item(H, species_outfit?.pda || pda, ITEM_SLOT_PDA)

	if(uniform || species_outfit?.uniform)
		for(var/path in accessories)
			var/obj/item/clothing/accessory/A = new path()
			var/obj/item/clothing/under/U = uniform
			U.attach_accessory(A, H)

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(l_pocket || species_outfit?.l_pocket)
			equip_item(H, species_outfit?.l_pocket || l_pocket, ITEM_SLOT_LEFT_POCKET)
		if(r_pocket || species_outfit?.r_pocket)
			equip_item(H, species_outfit?.r_pocket || r_pocket, ITEM_SLOT_RIGHT_POCKET)

		if(box || species_outfit?.box)
			if(!backpack_contents)
				backpack_contents = list()
			backpack_contents.Insert(1, species_outfit?.box || box)
			backpack_contents[species_outfit?.box || box] = 1

		var/list/backpack_to_populate = species_outfit?.backpack_contents || backpack_contents
		for(var/path in backpack_to_populate)
			var/number = backpack_to_populate[path]
			if(!number)
				number = 1
			for(var/i in 1 to number)
				H.equip_or_collect(new path(H), ITEM_SLOT_IN_BACKPACK)

		var/list/implants_to_populate = species_outfit?.cybernetic_implants || cybernetic_implants
		for(var/path in implants_to_populate)
			var/obj/item/organ/internal/O = new path
			O.insert(H)

	post_equip(H, visualsOnly)

	if(!visualsOnly)
		apply_fingerprints(H)
		if(internals_slot)
			H.internal = H.get_item_by_slot(internals_slot)
			H.update_action_buttons_icon()

	if(bio_chips || species_outfit?.bio_chips)
		var/list/biochips_to_populate = species_outfit?.bio_chips || bio_chips
		for(var/bio_chip_type in biochips_to_populate)
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

/datum/outfit/proc/preview_outfit_icon(species, body_parts, backpack_choice = 2, monitor_head = FALSE)
	var/icon/outfit_icon = new /icon('icons/blanks/32x32.dmi', "nothing")

	var/datum/outfit/species_outfit = null
	if(species in species_outfits)
		species_outfit = species_outfits[species]
		species_outfit = new species_outfit()
		message_admins(species_outfit.uniform)

	if(uniform || species_outfit?.uniform)
		outfit_icon.Blend(preview_uniform_icon(species, body_parts, species_outfit), ICON_OVERLAY)
	if(id || species_outfit?.id)
		outfit_icon.Blend(preview_id_icon(species, body_parts, species_outfit), ICON_OVERLAY)
	if(shoes || species_outfit?.shoes)
		outfit_icon.Blend(preview_shoes_icon(species, body_parts, species_outfit), ICON_OVERLAY)
	if(gloves || species_outfit?.gloves)
		outfit_icon.Blend(preview_gloves_icon(species, body_parts, species_outfit), ICON_OVERLAY)
	if(l_ear || species_outfit?.l_ear)
		outfit_icon.Blend(preview_l_ear_icon(species, body_parts, species_outfit, monitor_head), ICON_OVERLAY)
	if(r_ear || species_outfit?.r_ear)
		outfit_icon.Blend(preview_r_ear_icon(species, body_parts, species_outfit, monitor_head), ICON_OVERLAY)
	if(belt || species_outfit?.belt)
		outfit_icon.Blend(preview_belt_icon(species, body_parts, species_outfit), ICON_OVERLAY)
	if(suit || species_outfit?.suit)
		outfit_icon.Blend(preview_suit_icon(species, body_parts, species_outfit), ICON_OVERLAY)
	if(neck || species_outfit?.neck)
		outfit_icon.Blend(preview_neck_icon(species, body_parts, species_outfit), ICON_OVERLAY)
	if(back || species_outfit?.back)
		outfit_icon.Blend(preview_back_icon(species, body_parts, species_outfit, backpack_choice), ICON_OVERLAY)
	if(glasses || species_outfit?.glasses)
		outfit_icon.Blend(preview_glasses_icon(species, body_parts, species_outfit, monitor_head), ICON_OVERLAY)
	if(mask || species_outfit?.mask)
		outfit_icon.Blend(preview_mask_icon(species, body_parts, species_outfit, monitor_head), ICON_OVERLAY)
	if(head || species_outfit?.head)
		outfit_icon.Blend(preview_uniform_icon(species, body_parts, species_outfit, monitor_head), ICON_OVERLAY)
	if(l_hand || species_outfit?.l_hand)
		outfit_icon.Blend(preview_l_hand_icon(species, body_parts, species_outfit), ICON_OVERLAY)
	if(r_hand || species_outfit?.r_hand)
		outfit_icon.Blend(preview_r_hand_icon(species, body_parts, species_outfit), ICON_OVERLAY)
	qdel(species_outfit)
	return outfit_icon

/datum/outfit/proc/preview_uniform_icon(species, list/body_parts, datum/outfit/species_outfit = null)
	if(!uniform && !species_outfit?.uniform)
		return null
	var/obj/item/clothing/worn_item
	if(species_outfit?.uniform)
		worn_item = new species_outfit.uniform(null)
	else
		worn_item = new uniform(null)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	if(species in worn_item.sprite_sheets)
		. = new /icon(worn_item.sprite_sheets[species], worn_icon_state)
	else
		. = new /icon(worn_item.worn_icon, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_suit_icon(species, list/body_parts, datum/outfit/species_outfit = null)
	if(!suit && !species_outfit?.suit)
		return null
	var/obj/item/clothing/worn_item
	if(species_outfit?.suit)
		worn_item = new species_outfit.suit(null)
	else
		worn_item = new suit(null)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	if(species in worn_item.sprite_sheets)
		. = new /icon(worn_item.sprite_sheets[species], worn_icon_state)
	else
		. = new /icon(worn_item.worn_icon, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_back_icon(species, list/body_parts, datum/outfit/species_outfit = null)
	if(!back && !species_outfit?.back)
		return null
	var/obj/item/clothing/worn_item
	if(species_outfit?.back)
		worn_item = new species_outfit.back(null)
	else
		worn_item = new back(null)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	if(species in worn_item.sprite_sheets)
		. = new /icon(worn_item.sprite_sheets[species], worn_icon_state)
	else
		. = new /icon(worn_item.worn_icon, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_belt_icon(species, list/body_parts, datum/outfit/species_outfit = null)
	if(!belt && !species_outfit?.belt)
		return null
	var/obj/item/clothing/worn_item
	if(species_outfit?.belt)
		worn_item = new species_outfit.belt(null)
	else
		worn_item = new belt(null)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	if(species in worn_item.sprite_sheets)
		. = new /icon(worn_item.sprite_sheets[species], worn_icon_state)
	else
		. = new /icon(worn_item.worn_icon, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_gloves_icon(species, list/body_parts, datum/outfit/species_outfit = null)
	if(!gloves && !species_outfit?.gloves)
		return null
	if(!("r_hand" in body_parts) || !("l_hand" in body_parts))
		return null
	var/obj/item/clothing/worn_item
	if(species_outfit?.gloves)
		worn_item = new species_outfit.gloves(null)
	else
		worn_item = new gloves(null)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	if(species in worn_item.sprite_sheets)
		. = new /icon(worn_item.sprite_sheets[species], worn_icon_state)
	else
		. = new /icon(worn_item.worn_icon, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_shoes_icon(species, list/body_parts, datum/outfit/species_outfit = null)
	if(!shoes && !species_outfit?.shoes)
		return null
	if(!("l_foot" in body_parts) || !("r_foot" in body_parts))
		return null
	var/obj/item/clothing/worn_item
	if(species_outfit?.shoes)
		worn_item = new species_outfit.shoes(null)
	else
		worn_item = new shoes(null)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	if(species in worn_item.sprite_sheets)
		. = new /icon(worn_item.sprite_sheets[species], worn_icon_state)
	else
		. = new /icon(worn_item.worn_icon, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_head_icon(species, list/body_parts, datum/outfit/species_outfit = null, monitor_head = FALSE)
	if(!head && !species_outfit?.head)
		return null
	if(!("head" in body_parts))
		return null
	var/obj/item/clothing/head/worn_item
	if(species_outfit?.head)
		worn_item = new species_outfit.head(null)
	else
		worn_item = new head(null)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	if(monitor_head && worn_item.icon_monitor)
		. = new /icon(worn_item.icon_monitor, worn_icon_state)
	else if(species in worn_item.sprite_sheets)
		. = new /icon(worn_item.sprite_sheets[species], worn_icon_state)
	else
		. = new /icon(worn_item.worn_icon, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_mask_icon(species, list/body_parts, datum/outfit/species_outfit = null, monitor_head = FALSE)
	if(!mask && !species_outfit?.mask)
		return null
	if(!("head" in body_parts))
		return null
	var/obj/item/clothing/mask/worn_item
	if(species_outfit?.mask)
		worn_item = new species_outfit.mask(null)
	else
		worn_item = new mask(null)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	if(monitor_head && worn_item.icon_monitor)
		. = new /icon(worn_item.icon_monitor, worn_icon_state)
	else if(species in worn_item.sprite_sheets)
		. = new /icon(worn_item.sprite_sheets[species], worn_icon_state)
	else
		. = new /icon(worn_item.worn_icon, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_neck_icon(species, list/body_parts, datum/outfit/species_outfit = null)
	if(!neck && !species_outfit?.neck)
		return null
	var/obj/item/clothing/worn_item
	if(species_outfit?.neck)
		worn_item = new species_outfit.neck(null)
	else
		worn_item = new neck(null)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	if(species in worn_item.sprite_sheets)
		. = new /icon(worn_item.sprite_sheets[species], worn_icon_state)
	else
		. = new /icon(worn_item.worn_icon, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_l_ear_icon(species, list/body_parts, datum/outfit/species_outfit = null, monitor_head = FALSE)
	if(!l_ear && !species_outfit?.l_ear)
		return null
	if(!("head" in body_parts))
		return null
	var/obj/item/clothing/worn_item
	if(species_outfit?.l_ear)
		worn_item = new species_outfit.l_ear(null)
	else
		worn_item = new l_ear(null)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	if(monitor_head && worn_item.icon_monitor)
		. = new /icon(worn_item.icon_monitor, worn_icon_state)
	else if(species in worn_item.sprite_sheets)
		. = new /icon(worn_item.sprite_sheets[species], worn_icon_state)
	else
		. = new /icon(worn_item.worn_icon, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_r_ear_icon(species, list/body_parts, datum/outfit/species_outfit = null, monitor_head = FALSE)
	if(!r_ear && !species_outfit?.r_ear)
		return null
	if(!("head" in body_parts))
		return null
	var/obj/item/clothing/worn_item
	if(species_outfit?.r_ear)
		worn_item = new species_outfit.r_ear(null)
	else
		worn_item = new r_ear(null)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	if(monitor_head && worn_item.icon_monitor)
		. = new /icon(worn_item.icon_monitor, worn_icon_state)
	else if(species in worn_item.sprite_sheets)
		. = new /icon(worn_item.sprite_sheets[species], worn_icon_state)
	else
		. = new /icon(worn_item.worn_icon, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_glasses_icon(species, list/body_parts, datum/outfit/species_outfit = null, monitor_head = FALSE)
	if(!glasses && !species_outfit?.glasses)
		return null
	if(!("head" in body_parts))
		return null
	var/obj/item/clothing/glasses/worn_item
	if(species_outfit?.glasses)
		worn_item = new species_outfit.glasses(null)
	else
		worn_item = new glasses(null)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	if(monitor_head && worn_item.icon_monitor)
		. = new /icon(worn_item.icon_monitor, worn_icon_state)
	else if(species in worn_item.sprite_sheets)
		. = new /icon(worn_item.sprite_sheets[species], worn_icon_state)
	else
		. = new /icon(worn_item.worn_icon, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_id_icon(species, list/body_parts, datum/outfit/species_outfit = null)
	if(!id && !species_outfit?.id)
		return null
	var/obj/item/clothing/worn_item
	if(species_outfit?.id)
		worn_item = new species_outfit.id(null)
	else
		worn_item = new id(null)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	if(species in worn_item.sprite_sheets)
		. = new /icon(worn_item.sprite_sheets[species], worn_icon_state)
	else
		. = new /icon(worn_item.worn_icon, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_l_hand_icon(species, list/body_parts, datum/outfit/species_outfit = null)
	if(!l_hand && !species_outfit?.l_hand)
		return null
	if(!("l_hand" in body_parts))
		return null
	var/obj/item/clothing/worn_item
	if(species_outfit?.l_hand)
		worn_item = new species_outfit.l_hand(null)
	else
		worn_item = new l_hand(null)
	var/worn_icon_state = worn_item.inhand_icon_state ? worn_item.inhand_icon_state : worn_item.icon_state
	if(species in worn_item.sprite_sheets_inhand)
		. = new /icon(worn_item.sprite_sheets_inhand[species], "[worn_icon_state]_l")
	else
		. = new /icon(worn_item.lefthand_file, worn_icon_state)
	qdel(worn_item)
	return

/datum/outfit/proc/preview_r_hand_icon(species, list/body_parts, datum/outfit/species_outfit = null)
	if(!r_hand && !species_outfit?.r_hand)
		return null
	if(!("r_hand" in body_parts))
		return null
	var/obj/item/clothing/worn_item
	if(species_outfit?.r_hand)
		worn_item = new species_outfit.r_hand(null)
	else
		worn_item = new r_hand(null)
	var/worn_icon_state = worn_item.inhand_icon_state ? worn_item.inhand_icon_state : worn_item.icon_state
	if(species in worn_item.sprite_sheets_inhand)
		. = new /icon(worn_item.sprite_sheets_inhand[species], "[worn_icon_state]_r")
	else
		. = new /icon(worn_item.righthand_file, worn_icon_state)
	qdel(worn_item)
	return

// Butler outfit
/datum/outfit/butler
	name = "Butler"
	uniform = /obj/item/clothing/under/suit/really_black
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/bowlerhat
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/white
