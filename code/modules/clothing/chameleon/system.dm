
#define CHAMELEON_MEMORY_SLOTS 3
/**
  * # Chameleon System
  *
  * This system exists inside a mob mind.
  * It tracks all chameleon components in use by this mob.
  * Provides an interface for the user to interact with chameleon items (I am using actions; maybe I should use something else).
  * Responsible for sending signals to items, so they can change appearance when needed.
  */

/datum/component/chameleon_system
	// Human who has this system
	var/mob/living/carbon/human/system_owner
	// Scan action form chameleon glasses
	var/datum/action/chameleon_system/scan/scan
	// Change your outfit to a new one, even a saved one
	var/datum/action/chameleon_system/change_all_action/change_all
	// Change single chameleon item's appearance
	var/datum/action/chameleon_system/change_one/change_one
	// This is where saved outfits exist
	var/chameleon_memory[CHAMELEON_MEMORY_SLOTS]
	// This list keeps track of all chameleon items in use by the user
	var/list/system_items_names = list()
	var/list/system_items_types = list()
	// This is a global list shared between all systems (I hope it is); it stores paths to all appearances per type of chameleon item
	var/static/list/items_disguises = list()
	// This is a global list shared between all systems (I hope it is); it stores all outfits that the user can swap to
	var/static/list/outfit_options


/datum/component/chameleon_system/Initialize()
	// dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	system_owner = parent

	if(!system_owner)
		CRASH("Can't create hameleon system without a user")

	if(!outfit_options)
		initialize_outfits() // init outfit_options should be run only once


	for(var/i in 1 to CHAMELEON_MEMORY_SLOTS)
		chameleon_memory[i] = list("name" = "Save slot №[i]", "outfit" = null)


/datum/component/chameleon_system/Destroy()

	return ..()

// core stuff

// Called when iteam with chameleon component is pickid up by mob, now this item is trucked by system.
/datum/component/chameleon_system/proc/link_item(var/item, name, type, blacklist)

	if(!length(system_items_names))
		change_all = new(system_owner)
		change_all.Grant(system_owner)

		change_one = new(system_owner)
		change_one.Grant(system_owner)

	//if(!is_type_in_list(item, system_items))
	if(!items_disguises[name])
		// caled onece for every unique chameleon type item.
		initialize_item_disguises(item, name, type, blacklist)


	// TODO TEST 2 IDENTICAL ITEMS
	system_items_names.Add(name)
	system_items_types.Add(type)



// Called when item leaves mob inventory and hands, now we no longer control this item
/datum/component/chameleon_system/proc/unlink_item(var/item, name, type, blacklist)

	// TODO TEST 2 IDENTICAL ITEMS
	system_items_names.Remove(name)
	system_items_types.Remove(type)

	if(!length(system_items_names))
		change_all.Remove(system_owner)
		qdel(change_all)
		change_one.Remove(system_owner)
		qdel(change_one)


// Adds new "type" of item and it's disguises options in global list
/datum/component/chameleon_system/proc/initialize_item_disguises(obj/item, chameleon_name, chameleon_type, chameleon_blacklist)

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

// Change One

/datum/component/chameleon_system/proc/change_one_trigger()

	var/list/chameleon_items_on_user = system_items_names
	var/obj/item/tranform_from = tgui_input_list(system_owner, "Select what item you want to change", "Chameleon Change", chameleon_items_on_user) // custom TGUI In future lol)
	if(!tranform_from)
		return

	var/index
	for(var/i in 1 to length(system_items_names))
		if(system_items_names[i] == tranform_from)
			index = i
			break

	var/obj/item/tranform_to = tgui_input_list(system_owner, "Select what item you want to change", "Chameleon Change", items_disguises[tranform_from]) // Redo TGUI to work with this

	if(!tranform_to)
		return
	// What the poin of first argument here?
	SEND_SIGNAL(src, COMSIG_CHAMELEON_SINGLE_CHANGE_REQUEST, system_items_types[index], items_disguises[tranform_from][tranform_to])


// Change ALL
// Adds all otfits disguises in global list
/datum/component/chameleon_system/proc/initialize_outfits()
	outfit_options = list()
	for(var/path in subtypesof(/datum/outfit/job))
		var/datum/outfit/O = path
		if(initial(O.can_be_admin_equipped))
			outfit_options[initial(O.name)] = path
	sortTim(outfit_options, GLOBAL_PROC_REF(cmp_text_asc))


/datum/component/chameleon_system/proc/select_outfit()

	var/list/save_slot_names = get_memory_names()
	var/outfits = save_slot_names + outfit_options
	var/selected = tgui_input_list(system_owner, "Select outfit to change into", "Chameleon Outfit", outfits)
	if(selected)
		return TRUE


	return TRUE

// scan related stuff

/datum/component/chameleon_system/proc/give_scan()
	scan = new(src)
	scan.Grant(system_owner)

/datum/component/chameleon_system/proc/lose_scan()
	scan.Remove(system_owner)
	qdel(scan)


// Memory Helpers
/datum/component/chameleon_system/proc/get_memory_names(var/item)
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

	var/datum/component/chameleon_system/sys = user.GetComponent(/datum/component/chameleon_system)
	var/list/save_slot_names = sys.get_memory_names()
	var/chameleon_memory = sys.chameleon_memory


	var/slot_name = tgui_input_list(user, "Please, select a save slot:", "Save slot selection", save_slot_names)

	if(!slot_name)
		return

	for(var/i in 1 to CHAMELEON_MEMORY_SLOTS)
		if(chameleon_memory[i]["name"] == slot_name)
			chameleon_memory[i]["outfit"] = target_outfit
			chameleon_memory[i]["name"] = disguise_name
			break

	end_scan_mode()




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
	if(IsAvailable())
		var/datum/component/chameleon_system/sys = system_owner.GetComponent(/datum/component/chameleon_system)
		sys.change_one_trigger()


//////////////////////////////
// MARK: change_all_action
//////////////////////////////

/datum/action/chameleon_system/change_all_action/
	name = "Select Chameleon Outfit"
	button_overlay_icon_state = "no_clothes"
	//By default, this list is shared between all instances.
	//It is not static because if it were, subtypes would not be able to have their own. If you ever want to edit it, copy it first.
	var/list/outfit_options
	var/mob/living/carbon/human/system_owner

/datum/action/chameleon_system/change_all_action/New(mob/owner)
	system_owner = owner
	..()

/datum/action/chameleon_system/change_all_action/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/action/chameleon_system/change_all_action/Trigger(left_click)
	if(IsAvailable())
		var/datum/component/chameleon_system/sys = system_owner.GetComponent(/datum/component/chameleon_system)
		sys.select_outfit()

