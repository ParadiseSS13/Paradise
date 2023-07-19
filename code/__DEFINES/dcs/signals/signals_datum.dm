// Datum signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /datum signals
/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of ClearFromParent: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"

/// before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
/// you should only be using this if you want to block deletion
/// that's the only functional difference between it and COMSIG_QDELETING, outside setting QDELETING to detect
#define COMSIG_PREQDELETED "parent_preqdeleted"
/// just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called
#define COMSIG_QDELETING "parent_qdeleting"
/// generic topic handler (usr, href_list)
#define COMSIG_TOPIC "handle_topic"
/// handler for vv_do_topic (usr, href_list)
#define COMSIG_VV_TOPIC "vv_topic"
	#define COMPONENT_VV_HANDLED (1<<0)
/// from datum ui_act (usr, action)
#define COMSIG_UI_ACT "COMSIG_UI_ACT"

/// fires on the target datum when an element is attached to it (/datum/element)
#define COMSIG_ELEMENT_ATTACH "element_attach"
/// fires on the target datum when an element is attached to it  (/datum/element)
#define COMSIG_ELEMENT_DETACH "element_detach"

// Merger datum signals
/// Called on the object being added to a merger group: (datum/merger/new_merger)
#define COMSIG_MERGER_ADDING "comsig_merger_adding"
/// Called on the object being removed from a merger group: (datum/merger/old_merger)
#define COMSIG_MERGER_REMOVING "comsig_merger_removing"
/// Called on the merger after finishing a refresh: (list/leaving_members, list/joining_members)
#define COMSIG_MERGER_REFRESH_COMPLETE "comsig_merger_refresh_complete"

// Gas mixture signals
/// From /datum/gas_mixture/proc/merge: ()
#define COMSIG_GASMIX_MERGED "comsig_gasmix_merged"
/// From /datum/gas_mixture/proc/remove: ()
#define COMSIG_GASMIX_REMOVED "comsig_gasmix_removed"
/// From /datum/gas_mixture/proc/react: ()
#define COMSIG_GASMIX_REACTED "comsig_gasmix_reacted"

// Modular computer's file signals. Tells the program datum something is going on.
/// From /obj/item/modular_computer/proc/store_file: (datum/computer_file/file_source, obj/item/modular_computer/host)
#define COMSIG_MODULAR_COMPUTER_FILE_STORE "comsig_modular_computer_file_store"
/// From /obj/item/modular_computer/proc/store_file: ()
#define COMSIG_MODULAR_COMPUTER_FILE_DELETED "comsig_modular_computer_file_deleted"
