//MODsuit signals
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
