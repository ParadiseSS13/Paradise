/**
 * A component for an item that attempts to defibrillate a mob when activated.
 */

#define EMP_RANDOMISE_TIME 30 SECONDS

/datum/component/chameleon

	var/obj/item/chameleon_item
	var/disguise_type
	var/chameleon_type_name
	var/list/blacklist
	var/datum/chameleon_system/chameleon_system


/**
 * Create a new chameleon component.
 * *
 * * type - path to objects that can be chameleon example /obj/item/clothing/glasses
 * * name - unick name per object type, to search in chameleon system.
 * * datum_owner - a UID reference to an chameleon item, so i can update it here
 * * blacklist - list of items, that, shouldnot be aceeble to chameleon to.
 */
/datum/component/chameleon/Initialize(type, name, datum_owner, blacklist)

	if(!isitem(parent))
		// PARENT SHOULD BE A CHAMELEON SYSTEM?
		return COMPONENT_INCOMPATIBLE

	src.chameleon_item = locateUID(datum_owner)
	src.disguise_type = type
	src.chameleon_type_name = name
	src.blacklist = blacklist

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(dropped))


/datum/component/chameleon/proc/equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER // COMSIG_ITEM_EQUIPPED

	if(!user.mind.chameleon_system)
		user.mind.chameleon_system = new /datum/chameleon_system(user)

	// So now i will listen to signals form this datum. Such as COMSIG_CHAMELEON_SINGLE_CHANGE_REQ
	if(chameleon_system != user.mind.chameleon_system)
		chameleon_system = user.mind.chameleon_system
		chameleon_system.link_item(chameleon_item, chameleon_type_name, disguise_type, blacklist)
		register_chameleon_system_signals(chameleon_system)

	if(chameleon_type_name != "Glasses")
		return

	if(slot == ITEM_SLOT_EYES )
		chameleon_system.give_scan()

	if(slot != ITEM_SLOT_EYES && user.mind.chameleon_system.scan)
		chameleon_system.lose_scan()

/datum/component/chameleon/proc/dropped(datum/source, mob/user)
	SIGNAL_HANDLER // COMSIG_ITEM_DROPPED
	if(isturf(chameleon_item.loc)) // need a better cheek
		chameleon_system.unlink_item(chameleon_item)
		unregister_chameleon_system_signals()

	return

/datum/component/chameleon/proc/register_chameleon_system_signals()
	RegisterSignal(chameleon_system, COMSIG_CHAMELEON_SINGLE_CHANGE_REQUEST, PROC_REF(change_item_disguise))
	RegisterSignal(chameleon_system, COMSIG_CHAMELEON_FULL_CHANGE_REQUEST, PROC_REF(apply_disguise))
	RegisterSignal(chameleon_system, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))

/datum/component/chameleon/proc/unregister_chameleon_system_signals()
	// SIGNAL_HANDLER // COMSIG_DEACTIVATE_CHAMELEON_SYSTEM
	UnregisterSignal(chameleon_system, COMSIG_CHAMELEON_SINGLE_CHANGE_REQUEST)
	UnregisterSignal(chameleon_system, COMSIG_CHAMELEON_FULL_CHANGE_REQUEST)
	UnregisterSignal(chameleon_system, COMSIG_ATOM_EMP_ACT)

/datum/component/chameleon/proc/on_emp(obj/item/unit)
	SIGNAL_HANDLER  // COMSIG_ATOM_EMP_ACT
	// TODO CODE
	return


/**
 * Changes singular chameleon item as per system REQUEST
 */
/datum/component/chameleon/proc/change_item_disguise(type, requested_item)
	SIGNAL_HANDLER  // COMSIG_CHAMELEON_SINGLE_CHANGE_REQUEST

	if(src.type != type)
		return

	update_item_appearance(requested_item)


	return TRUE

/**
 * Implementation
 */
/datum/component/chameleon/proc/update_item_appearance(obj/item/requested_item)
	return

	// if(!istype(target,/obj/item))
	// 	return

	// target.name = initial(requested_item.name)
	// target.desc = initial(requested_item.desc)
	// target.icon_state = initial(requested_item.icon_state)

	// if(isitem(target))
	// 	var/obj/item/I = target

	// 	I.item_state = initial(requested_item.item_state)
	// 	I.item_color = initial(requested_item.item_color)
	// 	I.color = initial(requested_item.color)

	// 	I.icon_override = initial(requested_item.icon_override)
	// 	if(initial(requested_item.sprite_sheets))
	// 		// Species-related variables are lists, which can not be retrieved using initial(). As such, we need to instantiate the picked item.
	// 		var/obj/item/P = new requested_item(null)
	// 		I.sprite_sheets = P.sprite_sheets
	// 		qdel(P)

	// 	if(isclothing(I) && isclothing(requested_item))
	// 		var/obj/item/clothing/CL = I
	// 		var/obj/item/clothing/PCL = requested_item
	// 		CL.flags_cover = initial(PCL.flags_cover)
	// 	I.update_appearance()

	// target.icon = initial(requested_item.icon)


// Maybe insted just make
/**
 * Changes all chameleon item as per system REQUEST
 */
/datum/component/chameleon/proc/apply_disguise(datum/outfit/requested_outfit)
	SIGNAL_HANDLER  // COMSIG_CHAMELEON_FULL_CHANGE_REQUEST

	// requested_outfit

	return TRUE




#undef EMP_RANDOMISE_TIME





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

/obj/item/clothing/glasses/test_chameleon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/chameleon, /obj/item/clothing/glasses, "Glasses", UID(), list())



