/**
 * Signals for /obj/item and subtypes that have too few related signals to put in separate files.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

// /obj/item

///from base of obj/item/attack(): (/mob/living/target, /mob/living/user)
#define COMSIG_ITEM_ATTACK "item_attack"
///from base of obj/item/attack_self(): (/mob)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"
	#define COMPONENT_NO_INTERACT (1<<0)
///from base of obj/item/attack_obj(): (/obj, /mob)
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"
	#define COMPONENT_NO_ATTACK_OBJ (1<<0)
///from base of obj/item/pre_attack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_PRE_ATTACK "item_pre_attack"
	#define COMPONENT_NO_ATTACK (1<<0)
///from base of obj/item/pre_attack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_BEING_ATTACKED "item_being_attacked"
///from base of obj/item/afterattack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"
///from base of obj/item/attack_qdeleted(): (atom/target, mob/user, params)
#define COMSIG_ITEM_ATTACK_QDELETED "item_attack_qdeleted"
///from base of obj/item/equipped(): (/mob/equipper, slot)
///called on [/obj/item] before unequip from base of [mob/proc/doUnEquip]: (force, atom/newloc, no_move, invdrop, silent)
#define COMSIG_ITEM_PRE_UNEQUIP "item_pre_unequip"
	///only the pre unequip can be cancelled
	#define COMPONENT_ITEM_BLOCK_UNEQUIP (1<<0)
#define COMSIG_ITEM_EQUIPPED "item_equip"
///from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_DROPPED "item_drop"
///from base of obj/item/pickup(): (/mob/taker)
#define COMSIG_ITEM_PICKUP "item_pickup"
///from base of mob/living/carbon/attacked_by(): (mob/living/carbon/target, mob/living/user, hit_zone)
#define COMSIG_ITEM_ATTACK_ZONE "item_attack_zone"
///return a truthy value to prevent ensouling, checked in /datum/spell/lichdom/cast(): (mob/user)
#define COMSIG_ITEM_IMBUE_SOUL "item_imbue_soul"
///called before marking an object for retrieval, checked in /datum/spell/summonitem/cast() : (mob/user)
#define COMSIG_ITEM_MARK_RETRIEVAL "item_mark_retrieval"
	#define COMPONENT_BLOCK_MARK_RETRIEVAL (1<<0)
///from base of obj/item/hit_reaction(): (list/args)
#define COMSIG_ITEM_HIT_REACT "item_hit_react"
	#define COMPONENT_BLOCK_SUCCESSFUL (1 << 0)
	#define COMPONENT_BLOCK_PERFECT (1 << 2)
///called on item when crossed by something (): (/atom/movable, mob/living/crossed)
#define COMSIG_ITEM_WEARERCROSSED "wearer_crossed"
///called on item when microwaved (): (obj/machinery/microwave/M)
#define COMSIG_ITEM_MICROWAVE_ACT "microwave_act"
///from base of item/sharpener/attackby(): (amount, max)
#define COMSIG_ITEM_SHARPEN_ACT "sharpen_act"
	#define COMPONENT_SHARPEN_APPLIED (1<<0)
	#define COMPONENT_BLOCK_SHARPEN_BLOCKED (1<<1)
	#define COMPONENT_BLOCK_SHARPEN_ALREADY (1<<2)
	#define COMPONENT_BLOCK_SHARPEN_MAXED (1<<3)
///from base of [/obj/item/proc/tool_check_callback]: (mob/living/user)
#define COMSIG_TOOL_IN_USE "tool_in_use"
///from base of [/obj/item/proc/tool_start_check]: (mob/living/user)
#define COMSIG_TOOL_START_USE "tool_start_use"
///from base of [/obj/item/proc/tool_attack_chain]: (atom/tool, mob/user)
#define COMSIG_TOOL_ATTACK "tool_attack"
	#define COMPONENT_CANCEL_TOOLACT (1<<0)
///from [/obj/item/proc/disableEmbedding]:
#define COMSIG_ITEM_DISABLE_EMBED "item_disable_embed"
///from [/obj/effect/mine/proc/triggermine]:
#define COMSIG_MINE_TRIGGERED "minegoboom"
/// Called by /obj/item/proc/worn_overlays(list/overlays, mutable_appearance/standing, isinhands, icon_file)
#define COMSIG_ITEM_GET_WORN_OVERLAYS "item_get_worn_overlays"
/// Called by /obj/item/assembly/signaler(called_from_radio)
#define COMSIG_ASSEMBLY_PULSED "item_assembly_pulsed"

///called when an item is sold by the exports subsystem
#define COMSIG_ITEM_SOLD "item_sold"
///called when a wrapped up structure is opened by hand
#define COMSIG_STRUCTURE_UNWRAPPED "structure_unwrapped"
#define COMSIG_ITEM_UNWRAPPED "item_unwrapped"
///called when a wrapped up item is opened by hand
	#define COMSIG_ITEM_SPLIT_VALUE  (1<<0)
///called when getting the item's exact ratio for cargo's profit.
#define COMSIG_ITEM_SPLIT_PROFIT "item_split_profits"
///called when getting the item's exact ratio for cargo's profit, without selling the item.
#define COMSIG_ITEM_SPLIT_PROFIT_DRY "item_split_profits_dry"

// /obj/item/clothing

///from [/mob/living/carbon/human/Move]: ()
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"
///from base of /obj/item/clothing/suit/space/proc/toggle_spacesuit(): (obj/item/clothing/suit/space/suit)
#define COMSIG_SUIT_SPACE_TOGGLE "suit_space_toggle"

// /obj/item/implant

///from base of /obj/item/bio_chip/proc/activate(): ()
#define COMSIG_IMPLANT_ACTIVATED "implant_activated"
///from base of /obj/item/bio_chip/proc/implant(): (list/args)
#define COMSIG_IMPLANT_IMPLANTING "implant_implanting"
	#define COMPONENT_STOP_IMPLANTING (1<<0)
///called on already installed implants when a new one is being added in /obj/item/bio_chip/proc/implant(): (list/args, obj/item/bio_chip/new_implant)
#define COMSIG_IMPLANT_OTHER "implant_other"
	//#define COMPONENT_STOP_IMPLANTING (1<<0) //The name makes sense for both
	#define COMPONENT_DELETE_NEW_IMPLANT (1<<1)
	#define COMPONENT_DELETE_OLD_IMPLANT (1<<2)
///called on implants being implanted into someone with an uplink implant: (datum/component/uplink)
#define COMSIG_IMPLANT_EXISTING_UPLINK "implant_uplink_exists"
	//This uses all return values of COMSIG_IMPLANT_OTHER

/// called on implants, after a successful implantation: (mob/living/target, mob/user, silent, force)
#define COMSIG_IMPLANT_IMPLANTED "implant_implanted"

/// called on implants, after an implant has been removed: (mob/living/source, silent, special)
#define COMSIG_IMPLANT_REMOVED "implant_removed"


// /obj/item/pda

///called on pda when the user changes the ringtone: (mob/living/user, new_ringtone)
#define COMSIG_PDA_CHANGE_RINGTONE "pda_change_ringtone"
	#define COMPONENT_STOP_RINGTONE_CHANGE (1<<0)
#define COMSIG_PDA_CHECK_DETONATE "pda_check_detonate"
	#define COMPONENT_PDA_NO_DETONATE (1<<0)


// /obj/item/radio

///called from base of /obj/item/radio/proc/set_frequency(): (list/args)
#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"


// /obj/item/pen

///called after rotation in /obj/item/pen/attack_self(): (rotation, mob/living/carbon/user)
#define COMSIG_PEN_ROTATED "pen_rotated"


// /obj/item/gun

///called in /obj/item/gun/fire_gun (user, target, flag, params)
#define COMSIG_GUN_TRY_FIRE "gun_try_fire"
	#define COMPONENT_CANCEL_GUN_FIRE (1<<0)
///called in /obj/item/gun/afterattack (user, target, flag, params)
#define COMSIG_MOB_TRY_FIRE "mob_fired_gun"
///called in /obj/item/gun/process_fire (user, target)
#define COMSIG_GUN_FIRED "gun_fired"
/// called in /datum/component/automatic_fire/proc/on_mouse_down: (client/clicker, atom/target, turf/location, control, params)
#define COMSIG_AUTOFIRE_ONMOUSEDOWN "autofire_onmousedown"
	#define COMPONENT_AUTOFIRE_ONMOUSEDOWN_BYPASS (1<<0)
/// called in /datum/component/automatic_fire/proc/process_shot(): (atom/target, mob/living/shooter, allow_akimbo, params)
#define COMSIG_AUTOFIRE_SHOT "autofire_shot"
	#define COMPONENT_AUTOFIRE_SHOT_SUCCESS (1<<0)


// /obj/item/grenade

///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_PRIME "grenade_prime"
///called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_ARMED "grenade_armed"


// /obj/item/mod

/// Called when a module is selected to be the active one from on_select(obj/item/mod/module/module)
#define COMSIG_MOD_MODULE_SELECTED "mod_module_selected"
/// Called when a MOD deploys one or more of its parts.
#define COMSIG_MOD_DEPLOYED "mod_deployed"
/// Called when a MOD retracts one or more of its parts.
#define COMSIG_MOD_RETRACTED "mod_retracted"
/// Called when a MOD is finished toggling itself.
#define COMSIG_MOD_TOGGLED "mod_toggled"
/// Called when a MOD activation is called from toggle_activate(mob/user)
#define COMSIG_MOD_ACTIVATE "mod_activate"
	/// Cancels the suit's activation
	#define MOD_CANCEL_ACTIVATE (1 << 0)
/// Called when a MOD finishes having a module removed from it.
#define COMSIG_MOD_MODULE_REMOVED "mod_module_removed"
/// Called when a MOD finishes having a module added to it.
#define COMSIG_MOD_MODULE_ADDED "mod_module_added"
/// Called when a MOD is having modules removed from crowbar_act(mob/user, obj/crowbar)
#define COMSIG_MOD_MODULE_REMOVAL "mod_module_removal"
	/// Cancels the removal of modules
	#define MOD_CANCEL_REMOVAL (1 << 0)
/// Called when a module attempts to activate, however it does. At the end of checks so you can add some yourself, or work on trigger behavior (mob/user)
#define COMSIG_MODULE_TRIGGERED "mod_module_triggered"
	/// Cancels activation, with no message. Include feedback on your cancel.
	#define MOD_ABORT_USE (1<<0)
/// Called when a module activates, after all checks have passed and cooldown started.
#define COMSIG_MODULE_ACTIVATED "mod_module_activated"
/// Called when a module deactivates, after all checks have passed.
#define COMSIG_MODULE_DEACTIVATED "mod_module_deactivated"
/// Called when a module is used, after all checks have passed and cooldown started.
#define COMSIG_MODULE_USED "mod_module_used"
/// Called when the MODsuit wearer is set.
#define COMSIG_MOD_WEARER_SET "mod_wearer_set"
/// Called when the MODsuit wearer is unset.
#define COMSIG_MOD_WEARER_UNSET "mod_wearer_unset"


// /obj/item/food

///from base of obj/item/food/attack(): (mob/living/eater, mob/feeder)
#define COMSIG_FOOD_EATEN "food_eaten"

/// from base of /obj/item/slimepotion/speed/afterattack(): (obj/target, /obj/src, mob/user)
#define COMSIG_SPEED_POTION_APPLIED "speed_potion"
	#define SPEED_POTION_STOP (1<<0)

