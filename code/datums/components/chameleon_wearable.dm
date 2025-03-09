/**
 * This element is used to indicate that a movable atom can be mounted by mobs in order to ride it. The movable is considered mounted when a mob is buckled to it,
 * at which point a [riding component][/datum/component/riding] is created on the movable, and that component handles the actual riding behavior.
 *
 * Besides the target, the ridable element has one argument: the component subtype. This is not really ideal since there's ~20-30 component subtypes rather than
 * having the behavior defined on the ridable atoms themselves or some such, but because the old riding behavior was so horrifyingly spread out and redundant,
 * just having the variables, behavior, and procs be standardized is still a big improvement.
 */

#define EMP_RANDOMISE_TIME 30 SECONDS

/datum/component/chameleon_wearable
	var/disguise_type
	var/disguise_name
	var/list/disguise_blacklist = list()

/datum/component/chameleon_wearable/Initialize(_disguise_type, _disguise_name, _disguise_blacklist)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	disguise_type = _disguise_type
	disguise_name = _disguise_name
	if(islist(_disguise_blacklist))
		disguise_blacklist = _disguise_blacklist

	// RegisterSignal(c_item, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))
	// RegisterSignal(c_item, COMSIG_ITEM_DROPPED, PROC_REF(dropped))


// /datum/component/chameleon_wearable/Detach(atom/movable/target)
// 	// CRASH("I CAN BE Detach?")
// 	return ..()

/datum/component/chameleon_wearable/proc/get_subscribed(datum/source, list/items)
	SIGNAL_HANDLER
	items += src

/datum/component/chameleon_wearable/proc/on_pickup(datum/source, mob/user)
	SIGNAL_HANDLER // COMSIG_ITEM_PICKUP
	user.AddComponent(/datum/component/chameleon_system, src, source)
// 	var/datum/component/chameleon_system/sys = user.GetComponent(/datum/component/chameleon_system)
// 	if(!sys)
//
// 		sys = user.GetComponent(/datum/component/chameleon_system)

// 	if(sys.is_item_in_system(I))
// 		return

// 	sys.link_item(chameleon_item, chameleon_type_name, disguise_type, blacklist)
// 	register_chameleon_system_signals(sys)

/datum/component/chameleon_wearable/proc/equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER // COMSIG_ITEM_EQUIPPED
	// user.AddComponent(/datum/component/chameleon_system, src)

	// if(chameleon_type_name == "Glasses")
	// 	var/datum/component/chameleon_system/sys = user.GetComponent(/datum/component/chameleon_system)
	// 	if(slot == ITEM_SLOT_EYES)
	// 		sys.give_scan()

	// 	if(slot != ITEM_SLOT_EYES && sys.scan)
	// 		sys.lose_scan()
	return

/datum/component/chameleon_wearable/proc/dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER // COMSIG_ITEM_DROPPED

	SEND_SIGNAL(src, COMSIG_CHAMELEON_REFRESH_ACTIONS)
	UnregisterSignal(src, list(
		COMSIG_CHAMELEON_CHANGE_ONE_TRIGGER,
		COMSIG_CHAMELEON_SINGLE_CHANGE_REQUEST,
		COMSIG_CHAMELEON_FULL_CHANGE_REQUEST,
		COMSIG_ATOM_EMP_ACT,
	))

/datum/component/chameleon_wearable/proc/on_emp(source, obj/item/unit)
	SIGNAL_HANDLER  // COMSIG_ATOM_EMP_ACT
	// TODO CODE
	return

/**
 * Changes singular chameleon item as per system REQUEST
 */
/datum/component/chameleon_wearable/proc/change_item_disguise(source, type, obj/item/requested_item)
	SIGNAL_HANDLER  // COMSIG_CHAMELEON_SINGLE_CHANGE_REQUEST

	if(src.disguise_type != type)
		return

	if(!requested_item)
		log_debug("[src] was requested to change to a null value")
		return

	update_item_appearance(requested_item)
	// chameleon_item.update_slot_icon()
	// TODO Update appearance in hand
	return TRUE

/**
 * Implementation
 */
/datum/component/chameleon_wearable/proc/update_item_appearance(obj/item/requested_item)

	// if(!istype(chameleon_item,/obj/item))
	// 	return

	// chameleon_item.name = initial(requested_item.name)
	// chameleon_item.desc = initial(requested_item.desc)
	// chameleon_item.icon_state = initial(requested_item.icon_state)

	// if(isitem(chameleon_item))
	// 	var/obj/item/I = chameleon_item

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

	// chameleon_item.icon = initial(requested_item.icon)
	return

// Maybe insted just make
/**
 * Changes all chameleon item as per system REQUEST
 */
/datum/component/chameleon_wearable/proc/apply_disguise(source, datum/outfit/requested_outfit)
	SIGNAL_HANDLER  // COMSIG_CHAMELEON_FULL_CHANGE_REQUEST

	// requested_outfit

	return TRUE




#undef EMP_RANDOMISE_TIME

/datum/component/chameleon_wearable/glasses/Initialize()
	return ..(/obj/item/clothing/glasses, "Glasses")

/datum/component/chameleon_wearable/under/Initialize()
	return ..(/obj/item/clothing/under, "Jumpsuit", typecacheof(list(
		/obj/item/clothing/under,
		/obj/item/clothing/under/misc,
		/obj/item/clothing/under/dress,
		/obj/item/clothing/under/pants,
		/obj/item/clothing/under/color,
		/obj/item/clothing/under/retro,
		/obj/item/clothing/under/solgov,
		/obj/item/clothing/under/suit,
		/obj/item/clothing/under/costume,
		/obj/item/clothing/under/rank,
		/obj/item/clothing/under/rank/cargo,
		/obj/item/clothing/under/rank/civilian,
		/obj/item/clothing/under/rank/engineering,
		/obj/item/clothing/under/rank/medical,
		/obj/item/clothing/under/rank/rnd,
		/obj/item/clothing/under/rank/security,
	), only_root_path = TRUE))


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
	AddComponent(/datum/component/chameleon_wearable/glasses)
