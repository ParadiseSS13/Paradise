/**
	The label component.

	This component is used to manage labels applied by the hand labeler.

	Atoms can only have one instance of this component, and therefore only one label at a time.
	This is to avoid having names like "Backpack (label1) (label2) (label3)". This is annoying and abnoxious to read.

	When a player clicks the atom with a hand labeler to apply a label, this component gets applied to it.
	If the labeler is off, the component will be removed from it, and the label will be removed from its name.
 */
/datum/component/label
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// The name of the label the player is applying to the parent.
	var/label_name

/datum/component/label/Initialize(_label_name)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	label_name = _label_name
	apply_label()

/datum/component/label/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LABEL_REMOVE, PROC_REF(on_remove))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_NAME, PROC_REF(on_update_name))

/datum/component/label/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LABEL_REMOVE, COMSIG_PARENT_EXAMINE, COMSIG_ATOM_UPDATE_NAME))

/**
	This proc will fire after the parent is hit by a hand labeler which is trying to apply another label.
	Since the parent already has a label, it will remove the old one from the parent's name, and apply the new one.
*/
/datum/component/label/InheritComponent(datum/component/label/new_comp, i_am_original, _label_name)
	remove_label()
	if(new_comp)
		label_name = new_comp.label_name
	else
		label_name = _label_name
	apply_label()

/datum/component/label/proc/on_remove(datum/source)
	remove_label()
	qdel(src) // Remove the component from the object.
	return TRUE

/**
	This proc will trigger when someone examines the parent.
	It will attach the text found in the body of the proc to the `examine_list` and display it to the player examining the parent.

	Arguments:
	* source: The parent.
	* user: The mob exmaining the parent.
	* examine_list: The current list of text getting passed from the parent's normal examine() proc.
*/

///Reapplies label when update_name is called on the parent object. Attempts to remove it first just in case.
/datum/component/label/proc/on_update_name()
	SIGNAL_HANDLER // COMSIG_ATOM_UPDATE_NAME
	remove_label()
	apply_label()

/datum/component/label/proc/on_examine(datum/source, mob/user, list/examine_list)
	examine_list += "<span class='notice'>It has a label with some words written on it. Use a hand labeler to remove it.</span>"

/// Applies a label to the name of the parent in the format of: "parent_name (label)"
/datum/component/label/proc/apply_label()
	var/atom/owner = parent
	owner.name += " ([label_name])"
	owner.investigate_log("Label: \"[label_name]\" applied", INVESTIGATE_RENAME)

/// Removes the label from the parent's name
/datum/component/label/proc/remove_label()
	var/atom/owner = parent
	owner.name = replacetext(owner.name, "([label_name])", "") // Remove the label text from the parent's name, wherever it's located.
	owner.name = trim(owner.name) // Shave off any white space from the beginning or end of the parent's name.

/// A verson of the label component specific to labelling goal items.
/datum/component/label/goal
	var/owner = "Anyone"
	var/person
	var/department

/datum/component/label/goal/Initialize(who, where, from_cc=FALSE)
	person = who
	department = where
	update_owner_and_label_name(from_cc)
	return ..(label_name)

/datum/component/label/goal/proc/update_owner_and_label_name(from_cc)
	if(person)
		owner = person
	if(department)
		owner += " in [department]"
	
	if(from_cc)
		label_name = owner
	else
		label_name = "Secondary Goal"

/**
	This proc will fire after the parent is hit by a hand labeler which is trying to apply another goal label.
	Since the parent already has a goal label, it will remove the old one from the parent's name, and apply the new one.
*/
/datum/component/label/goal/InheritComponent(datum/component/label/new_comp, i_am_original, who, where, from_cc=FALSE)
	remove_label()
	person = who
	department = where
	update_owner_and_label_name(from_cc)
	apply_label()

/// Adds detailed information to the examine text.
/datum/component/label/goal/on_examine(datum/source, mob/user, list/examine_list)
	examine_list += "<span class='notice'>It has a label on it, marking it as part of a secondary goal for [owner]. Use a hand labeler to remove it.</span>"
