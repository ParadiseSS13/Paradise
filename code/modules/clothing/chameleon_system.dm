
/datum/chameleon_system

	// var/mob/???/owner
	var/mob/living/carbon/human/system_owner

	var/datum/action/spell_action/chameleon_system/scan_action/scan

	var/datum/action/chameleon_system/change_one_action/change_one

	var/datum/action/chameleon_system/change_all_action/change_all

	static/datum/chameleom_memory


//////////////////////////////
// MARK: scan_action
//////////////////////////////

/datum/action/item_action/chameleon_system/scan
	name = "Copy Outfit"
	var/list/chameleon_blacklist = list() //This is a typecache
	var/list/chameleon_list = list()
	var/chameleon_type = null
	var/chameleon_name = "Item"
	var/ready_to_scan = TRUE

	var/emp_timer
	var/datum/middleClickOverride/callback_invoker/click_override

/datum/action/item_action/chameleon_system/scan/New(Target)
	. = ..()
	click_override = new(CALLBACK(src, PROC_REF(try_to_scan)))

/datum/action/item_action/chameleon_system/scan/Trigger(left_click)
	if (ready_to_scan)
		enter_scan_mode() // Продолжим сделаем красота!
	else
		end_scan_mode()

/datum/action/item_action/chameleon_system/scan/proc/enter_scan_mode()
	var/mob/living/user = owner
	ready_to_scan = FALSE
	to_chat(user, "<span class='warning'>You activate scan module on your glasses, use alt+click or middle mouse button on a target to scan their outfit.</span>")
	user.middleClickOverride = click_override


/datum/action/item_action/chameleon_system/scan/proc/end_scan_mode()
	var/mob/living/user = owner
	ready_to_scan = TRUE
	to_chat(user, "<span class='warning'>You deactivate scan module.</span>")
	user.middleClickOverride = null


/datum/action/item_action/chameleon_system/scan/proc/try_to_scan(mob/user, mob/target)
	user.changeNext_click(5)
	if(ishuman(target)) // can scan only crew // TODO FIX
		start_scan_body(user, target)
		to_chat(user, "<span class='warning'>You have scaned [target.name].</span>")


/datum/action/item_action/chameleon_system/scan/proc/start_scan_body(mob/user, mob/target)
	// if(!iscarbon(target) || !isturf(user.loc))
	// 	return FALSE
	// var/target_distance = get_dist(user, target)
	// if(target_distance > cling.sting_range) // Too far, don't bother pathfinding
	// 	to_chat(user, "<span class='warning'>Our target is too far for our sting!</span>")
	// 	return FALSE
	// if(target_distance && !length(get_path_to(user, target, max_distance = cling.sting_range, simulated_only = FALSE, skip_first = FALSE))) // If they're not on the same turf, check if it can even reach them.
	// 	to_chat(user, "<span class='warning'>Our sting is blocked from reaching our target!</span>")
	// 	return FALSE
	// if(!cling.chosen_sting)
	// 	to_chat(user, "<span class='warning'>We haven't prepared our sting yet!</span>")
	// 	return FALSE
	// if(ismachineperson(target))
	// 	to_chat(user, "<span class='warning'>This won't work on synthetics.</span>")
	// 	return FALSE
	// if(IS_CHANGELING(target))
	// 	sting_feedback(user, target)
	// 	take_chemical_cost()
	// 	return FALSE
	return TRUE


// /datum/action/spell_action/chameleon_system/scan_action
// 	name = "Steal Outfit"
// 	desc = "Copy others outfits."
// 	button_overlay_icon_state = "chameleon_outfit"
// 	var/number_slots = 3
// 	var/list/saved_options

// /datum/action/spell_action/chameleon_system/scan_action/New()
// 	..()
// 	initialize_save_slots()

// /datum/action/spell_action/chameleon_system/scan_action/Destroy()
// 	STOP_PROCESSING(SSprocessing, src)
// 	return ..()

// /datum/action/spell_action/chameleon_system/scan_action/proc/initialize_save_slots()
// 	if(!saved_options)
// 		saved_options = new/list(number_slots)
// 		for(var/i = 1; i <= saved_options.len; i++)
// 			world << i
// 			saved_options[i] = "Save slot №[i]"


// /datum/action/spell_action/chameleon_system/scan_action/Trigger(left_click)
// 	return ..() //select_outfit(owner)

//////////////////////////////
// MARK: change_one_action
//////////////////////////////

/datum/action/chameleon_system/change_one_action
	name = "Change Chameleon Part"
	button_overlay_icon_state = "chameleon_outfit"

//////////////////////////////
// MARK: change_all_action
//////////////////////////////

/datum/action/chameleon_system/change_all_action/
	name = "Select Chameleon Outfit"
	button_overlay_icon_state = "chameleon_outfit"

/datum/action/chameleon_system/change_all_action/New()
	..()

/datum/action/chameleon_system/change_all_action/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()


/datum/action/chameleon_system/change_all_action/Trigger(left_click)
	return select_outfit(owner)

/datum/action/chameleon_system/change_all_action/proc/select_outfit(mob/user)
	return TRUE




//////////////////////////////
// MARK: Item Test
//////////////////////////////


/obj/item/clothing/glasses/test_chameleon
	name = "optical meson scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	icon_state = "meson"
	item_state = "meson"
	resistance_flags = NONE
	prescription_upgradable = TRUE
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/eyes.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/eyes.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/eyes.dmi'
	)

	// var/datum/action/item_action/chameleon/change/chameleon_action
	var/datum/action/item_action/chameleon_system/scan/tsa

/obj/item/clothing/glasses/test_chameleon/Initialize(mapload)
	. = ..()
	tsa = new(src)

/obj/item/clothing/glasses/test_chameleon/Destroy()
	// QDEL_NULL(chameleon_action)
	return ..()
