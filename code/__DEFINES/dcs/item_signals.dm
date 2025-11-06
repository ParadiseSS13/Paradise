/**
 * Signals for /obj/item and subtypes that have too few related signals to put in separate files.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

// /obj/item


///called on [/obj/item] before unequip from base of [/mob/proc/unEquip]: (force, atom/newloc, no_move, invdrop, silent)
#define COMSIG_ITEM_PRE_UNEQUIP "item_pre_unequip"
	///only the pre unequip can be cancelled
	#define COMPONENT_ITEM_BLOCK_UNEQUIP (1<<0)
///from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_EQUIPPED "item_equip"
///from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_DROPPED "item_drop"
///from base of obj/item/pickup(): (/mob/taker)
#define COMSIG_ITEM_PICKUP "item_pickup"
///from base of obj/item/hit_reaction(): (list/args)
#define COMSIG_ITEM_HIT_REACT "item_hit_react"
	#define COMPONENT_BLOCK_SUCCESSFUL (1 << 0)
	#define COMPONENT_BLOCK_PERFECT (1 << 2)
///from base of item/sharpener/attackby(): (amount, max)
#define COMSIG_ITEM_SHARPEN_ACT "sharpen_act"
	#define COMPONENT_SHARPEN_APPLIED (1<<0)
	#define COMPONENT_BLOCK_SHARPEN_BLOCKED (1<<1)
	#define COMPONENT_BLOCK_SHARPEN_ALREADY (1<<2)
	#define COMPONENT_BLOCK_SHARPEN_MAXED (1<<3)
/// Called by [/obj/item/assembly/proc/pulse]
#define COMSIG_ASSEMBLY_PULSED "item_assembly_pulsed"
///from [/mob/living/carbon/human/proc/Move]: ()
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"

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


// other items

/// from base of /obj/item/slimepotion/speed/afterattack__legacy__attackchain(): (obj/target, /obj/src, mob/user)
#define COMSIG_SPEED_POTION_APPLIED "speed_potion"
	#define SPEED_POTION_STOP (1<<0)

// Cyborg specific items

/// from /mob/living/silicon/robot/proc/activate_item() (mob/user), A general signal for if a specific borg item needs something done when being activated.
#define COMSIG_CYBORG_ITEM_ACTIVATED "cyborg_activation"

/// from /mob/living/silicon/robot/proc/deactivate_item() (mob/user), A general signal for if a specific borg item needs something done when being deactivated.
#define COMSIG_CYBORG_ITEM_DEACTIVATED "cyborg_deactivation"
