
#define CHAMELEON_MEMORY_SLOTS 3


/datum/chameleon_system

	// var/mob/???/owner
	var/mob/living/carbon/human/system_owner

	var/datum/action/chameleon_system/scan/scan

	var/datum/action/chameleon_system/change_all_action/change_all

	var/datum/action/chameleon_system/change_one/change_one

	var/chameleon_memory[CHAMELEON_MEMORY_SLOTS]

	var/list/system_items = list()

	var/static/list/items_disguises = list()


/datum/chameleon_system/New(owner)
	..()

	if(!owner)
		CRASH("Can't create hameleon system without a user")

	system_owner = owner

	for(var/i in 1 to CHAMELEON_MEMORY_SLOTS)
		chameleon_memory[i] = list("name" = "Save slot №[i]", "outfit" = null)

/datum/chameleon_system/Destroy()

	return ..()

// core stuff

/datum/chameleon_system/proc/link_item(var/item, chameleon_name, chameleon_type, chameleon_blacklist)

	if(!item)
		CRASH("No item to link has been provided")

	if(!length(system_items))
		change_all = new(system_owner)
		change_all.Grant(system_owner)

		change_one = new(system_owner)
		change_one.Grant(system_owner)

	//if(!is_type_in_list(item, system_items))
	if(!items_disguises[chameleon_name])
		initialize_item_disguises(item, chameleon_name, chameleon_type, chameleon_blacklist)

	system_items.Add(item)


/datum/chameleon_system/proc/unlink_item(var/item)
	if(!item)
		CRASH("No item to unlink has been provided")

	system_items.Remove(item) // TODO TEST 2 IDENTICAL ITEMS

	if(!length(system_items))
		change_all.Remove(system_owner)
		qdel(change_all)
		change_one.Remove(system_owner)
		qdel(change_one)


/datum/chameleon_system/proc/initialize_item_disguises(obj/item, chameleon_name, chameleon_type, chameleon_blacklist)

	chameleon_blacklist |= typecacheof(item.type)
	items_disguises[chameleon_name] = list()

	for(var/V in typesof(chameleon_type))
		if(ispath(V) && ispath(V, /obj/item))
			var/obj/item/I = V
			if(chameleon_blacklist[V] || (initial(I.flags) & ABSTRACT) || !initial(I.icon_state))
				continue
			var/chameleon_item_name = "[replacetext(initial(I.name), "\improper", "")]_[initial(I.icon_state)]"
			if(isnull(items_disguises[chameleon_name][chameleon_item_name]))
				items_disguises[chameleon_name][chameleon_item_name] = I


// scan related stuff

/datum/chameleon_system/proc/give_scan()
	scan = new(src)
	scan.Grant(system_owner)

/datum/chameleon_system/proc/lose_scan()
	scan.Remove(system_owner)
	qdel(scan)


// Memory Helpers
/datum/chameleon_system/proc/get_memory_names(var/item)
	var/list/save_slot_names = list()
	for(var/i in 1 to CHAMELEON_MEMORY_SLOTS)
		save_slot_names += chameleon_memory[i]["name"]

	return save_slot_names

//////////////////////////////
// MARK: scan_action
//////////////////////////////

/datum/action/chameleon_system/scan
	name = "Copy Outfit"
	button_overlay_icon_state = "set_drop"
	var/ready_to_scan = TRUE
	var/datum/middle_click_override/callback_invoker/click_override

/datum/action/chameleon_system/scan/New(Target)
	. = ..()
	click_override = new(CALLBACK(src, PROC_REF(try_to_scan)))

/datum/action/chameleon_system/scan/Destroy()
	if (ready_to_scan == FALSE) // Check if the user has ended the scan mode before unequipping the glasses."
		end_scan_mode()

	. = ..()

/datum/action/chameleon_system/scan/Trigger(left_click)
	if (ready_to_scan)
		enter_scan_mode()
	else
		end_scan_mode()

/datum/action/chameleon_system/scan/proc/enter_scan_mode()
	var/mob/living/user = owner
	ready_to_scan = FALSE
	to_chat(user, "<span class='warning'>You activate scan module on your glasses, use alt+click or middle mouse button on a target to scan their outfit.</span>")
	user.middleClickOverride = click_override


/datum/action/chameleon_system/scan/proc/end_scan_mode()
	var/mob/living/user = owner
	ready_to_scan = TRUE
	to_chat(user, "<span class='warning'>You deactivate scan module.</span>")
	user.middleClickOverride = null


/datum/action/chameleon_system/scan/proc/try_to_scan(mob/user, mob/target)

	user.changeNext_click(5)

	if(!ishuman(target)) // can scan only crew PunPun is human to :( ) // TODO FIX
		return

	to_chat(user, "<span class='warning'>You have scaned [target.name].</span>")
	var/datum/outfit/target_outfit = get_target_outfit(user, target)

	var/disguise_name = tgui_input_text(user, "Enter disguise name", "Disguise name", max_length = MAX_NAME_LEN)

	if(!disguise_name)
		return

	var/list/save_slot_names = user.mind.chameleon_system.get_memory_names()
	var/chameleon_memory = user.mind.chameleon_system.chameleon_memory


	var/slot_name = tgui_input_list(user, "Please, select a save slot:", "Save slot selection", save_slot_names)

	if(!slot_name)
		return

	for(var/i in 1 to CHAMELEON_MEMORY_SLOTS)
		if(chameleon_memory[i]["name"] == slot_name)
			chameleon_memory[i]["outfit"] = target_outfit
			chameleon_memory[i]["name"] = disguise_name
			break

	end_scan_mode()



@SpaceDaddy
MAIN
    var/t = list(1,2,3)
    var/t2 = t
    t2[1] = 999
    VAR_OUT(t)





/datum/action/chameleon_system/scan/proc/get_target_outfit(mob/user, mob/living/carbon/human/target)
	// TODO ACTIAL CODE
	var/datum/outfit/target_outfit = new()

	if (target.back)
		target_outfit.back = target.back
	if (target.wear_id)
		target_outfit.id = target.wear_id
	if (target.w_uniform)
		target_outfit.uniform= target.w_uniform
	if (target.wear_suit)
		target_outfit.suit = target.wear_suit
	if (target.wear_mask)
		target_outfit.mask = target.wear_mask
	if (target.neck)
		target_outfit.neck = target.neck
	if (target.head)
		target_outfit.head = target.head
	if (target.shoes)
		target_outfit.shoes = target.shoes
	if (target.gloves)
		target_outfit.gloves = target.gloves
	if (target.l_ear)
		target_outfit.l_ear = target.l_ear
	if (target.r_ear)
		target_outfit.r_ear = target.r_ear
	if (target.glasses)
		target_outfit.glasses = target.glasses
	if (target.belt)
		target_outfit.belt = target.belt
	if (target.wear_pda)
		target_outfit.pda = target.wear_pda

	// var/list/types = list(uniform, suit, back, belt, gloves, shoes, head, mask, neck, l_ear, r_ear, glasses, id, l_pocket, r_pocket, suit_store, r_hand, l_hand, pda)

	return target_outfit

//////////////////////////////
// MARK: change_one_action
//////////////////////////////

/datum/action/chameleon_system/change_one
	name = "Change Any Chameleon Part"
	button_overlay_icon_state = "chameleon_outfit"

	var/mob/living/carbon/human/system_owner
	var/chameleon_type = null
	var/chameleon_name = "Item"
	var/emp_timer


/datum/action/chameleon_system/change_one/New(mob/owner)
	system_owner = owner
	. = ..()

/datum/action/chameleon_system/change_one/Trigger(left_click)
	var/list/chameleon_items_on_user = system_owner.mind.chameleon_system.system_items
	var/obj/item/tranform_from = tgui_input_list(owner, "Select what item you want to change", "Chameleon Change", chameleon_items_on_user) // custom TGUI In future lol)
	if (isnull(tranform_from))
		return
	ui_interact(system_owner)


// /datum/action/chameleon_system/change_one/proc/random_look(mob/user) // todo
// 	var/picked_name = pick(chameleon_list[chameleon_name])
// 	// If a user is provided, then this item is in use, and we
// 	// need to update our icons and stuff

// 	if(user)
// 		update_look(user, chameleon_list[chameleon_name][picked_name])

// 	// Otherwise, it's likely a random initialisation, so we
// 	// don't have to worry

// 	else
// 		update_item(chameleon_list[chameleon_name][picked_name])

/datum/action/chameleon_system/change_one/proc/update_look(mob/user, obj/item/picked_item) // todo
	if(isliving(user))
		var/mob/living/C = user
		if(C.stat != CONSCIOUS)
			return

		update_item(picked_item)
		var/obj/item/thing = target
		thing.update_slot_icon()
		SStgui.update_uis(src)
	UpdateButtons()

/datum/action/chameleon_system/change_one/proc/update_item(obj/item/picked_item) // todo
	target.name = initial(picked_item.name)
	target.desc = initial(picked_item.desc)
	target.icon_state = initial(picked_item.icon_state)

	if(isitem(target))
		var/obj/item/I = target

		I.item_state = initial(picked_item.item_state)
		I.item_color = initial(picked_item.item_color)
		I.color = initial(picked_item.color)

		I.icon_override = initial(picked_item.icon_override)
		if(initial(picked_item.sprite_sheets))
			// Species-related variables are lists, which can not be retrieved using initial(). As such, we need to instantiate the picked item.
			var/obj/item/P = new picked_item(null)
			I.sprite_sheets = P.sprite_sheets
			qdel(P)

		if(isclothing(I) && isclothing(picked_item))
			var/obj/item/clothing/CL = I
			var/obj/item/clothing/PCL = picked_item
			CL.flags_cover = initial(PCL.flags_cover)
		I.update_appearance()

	target.icon = initial(picked_item.icon)


/datum/action/chameleon_system/change_one/ui_host()
	return system_owner

/datum/action/chameleon_system/change_one/ui_state(mob/user)
	return GLOB.physical_state

/datum/action/chameleon_system/change_one/ui_data(mob/user)
	var/list/data = list()
	data["selected_appearance"] = "[system_owner.name]_[system_owner.icon_state]"
	return data

/datum/action/chameleon_system/change_one/ui_static_data(mob/user, datum/tgui/ui = null)
	var/list/data = list()
	var/list/chameleon_skins = list()
	var/items_disguises = system_owner.mind.chameleon_system.items_disguises
	for(var/chameleon_type in items_disguises[chameleon_name])
		var/obj/item/chameleon_item = items_disguises[chameleon_name][chameleon_type]
		chameleon_skins.Add(list(list(
			"icon" = initial(chameleon_item.icon),
			"icon_state" = initial(chameleon_item.icon_state),
			"name" = initial(chameleon_item.name),
		)))

	data["chameleon_skins"] = chameleon_skins
	return data

/datum/action/chameleon_system/change_one/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Chameleon", "Change [chameleon_name] Appearance")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/action/chameleon_system/change_one/ui_act(action, list/params)
	if(..())
		return

	var/items_disguises = system_owner.mind.chameleon_system.items_disguises
	switch(action)
		if("change_appearance")
			update_look(usr, items_disguises[chameleon_name][params["new_appearance"]])



//////////////////////////////
// MARK: change_all_action
//////////////////////////////

/datum/action/chameleon_system/change_all_action/
	name = "Select Chameleon Outfit"
	button_overlay_icon_state = "chameleon_outfit"
	//By default, this list is shared between all instances.
	//It is not static because if it were, subtypes would not be able to have their own. If you ever want to edit it, copy it first.
	var/list/outfit_options
	var/mob/living/carbon/human/system_owner

/datum/action/chameleon_system/change_all_action/New(mob/owner)
	system_owner = owner
	initialize_outfits()
	..()

/datum/action/chameleon_system/change_all_action/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/action/chameleon_system/change_all_action/proc/initialize_outfits()
	var/static/list/standard_outfit_options
	if(!standard_outfit_options)
		standard_outfit_options = list()
		for(var/path in subtypesof(/datum/outfit/job))
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				standard_outfit_options[initial(O.name)] = path
		sortTim(standard_outfit_options, GLOBAL_PROC_REF(cmp_text_asc))

	// TODO ADD 3 CUSTOM SLOTS HERE
	outfit_options = standard_outfit_options


/datum/action/chameleon_system/change_all_action/Trigger(left_click)
	return select_outfit(owner)

/datum/action/chameleon_system/change_all_action/proc/select_outfit(mob/user)

	if(!user || !IsAvailable())
		return FALSE

	var/list/save_slot_names = system_owner.mind.chameleon_system.get_memory_names()
	var/outfits= save_slot_names + outfit_options
	var/selected = tgui_input_list(user, "Select outfit to change into", "Chameleon Outfit", outfits)

	if(!IsAvailable() || QDELETED(src) || QDELETED(user))
		return FALSE

	return TRUE
