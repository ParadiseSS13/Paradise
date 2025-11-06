// NOTE:
// This is an incredibly piecemeal port of /tg/'s decal element.
// It does not include several pieces of functionality that exist in /tg/.
//
// Namely:
// - It does not support smoothing decals
// - It does not send a signal when a decal is detached (used for trapdoors on /tg/)
// - It does not support custom plane configuration as this behavior seems primarily concerned with multi-z

/datum/element/decal
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	/// Whether this decal can be cleaned.
	var/cleanable
	/// A description this decal appends to the target's examine message.
	var/description
	/// If true this was initialized with no set direction - will follow the parent dir.
	var/directional
	/// The base icon state that this decal was initialized with.
	var/base_icon_state
	/// The overlay applied by this decal to the target.
	var/mutable_appearance/pic

/datum/element/decal/Attach(atom/target, _icon, _icon_state, _dir, _layer=TURF_LAYER, _alpha=255, _color, _cleanable=FALSE, _description, mutable_appearance/_pic)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	if(_pic)
		pic = _pic
	else if(!generate_appearance(_icon, _icon_state, _dir, _layer, _color, _alpha, target))
		return ELEMENT_INCOMPATIBLE
	description = _description
	cleanable = _cleanable
	directional = _dir
	base_icon_state = _icon_state

	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_overlay), TRUE)
	if(target.initialized)
		target.update_appearance(UPDATE_OVERLAYS) //could use some queuing here now maybe.
	else
		RegisterSignal(target, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE, PROC_REF(late_update_icon), TRUE)
	if(isitem(target))
		INVOKE_ASYNC(target, TYPE_PROC_REF(/obj/item/, update_slot_icon), TRUE)
	if(_dir)
		RegisterSignal(target, list(COMSIG_ATOM_DECALS_ROTATING, COMSIG_ATOM_GET_DECALS), PROC_REF(get_decals), TRUE)
		SSdcs.RegisterSignal(target, COMSIG_ATOM_DIR_CHANGE, TYPE_PROC_REF(/datum/controller/subsystem/processing/dcs, rotate_decals), override=TRUE)
	if(_cleanable)
		RegisterSignal(target, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(clean_react), TRUE)
	if(_description)
		RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(examine), TRUE)

	RegisterSignal(target, COMSIG_TURF_ON_SHUTTLE_MOVE, PROC_REF(shuttle_move_react), TRUE)

/// Remove old decals and apply new decals after rotation as necessary
/datum/controller/subsystem/processing/dcs/proc/rotate_decals(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER  // COMSIG_ATOM_DIR_CHANGE

	if(old_dir == new_dir)
		return

	var/list/datum/element/decal/old_decals = list() //instances
	SEND_SIGNAL(source, COMSIG_ATOM_DECALS_ROTATING, old_decals)

	if(!length(old_decals))
		UnregisterSignal(source, COMSIG_ATOM_DIR_CHANGE)
		return

	var/list/resulting_decals_params = list() // param lists
	for(var/datum/element/decal/rotating as anything in old_decals)
		resulting_decals_params += list(rotating.get_rotated_parameters(old_dir,new_dir))

	//Instead we could generate ids and only remove duplicates to save on churn on four-corners symmetry ?
	for(var/datum/element/decal/decal in old_decals)
		decal.Detach(source)

	for(var/result in resulting_decals_params)
		source.AddElement(/datum/element/decal, result["icon"], result["icon_state"], result["dir"], result["layer"], result["alpha"], result["color"], result["cleanable"], result["desc"])

/datum/element/decal/proc/get_rotated_parameters(old_dir,new_dir)
	var/rotation = 0
	if(directional) //Even when the dirs are the same rotation is coming out as not 0 for some reason
		rotation = SIMPLIFY_DEGREES(dir2angle(new_dir)-dir2angle(old_dir))
		new_dir = turn(pic.dir,-rotation)
	return list(
		"icon" = pic.icon,
		"icon_state" = base_icon_state,
		"dir" = new_dir,
		"plane" = pic.plane,
		"layer" = pic.layer,
		"alpha" = pic.alpha,
		"color" = pic.color,
		"cleanable" = cleanable,
		"desc" = description
	)

/datum/element/decal/proc/late_update_icon(atom/source)
	SIGNAL_HANDLER  // COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE

	if(istype(source) && !(source.flags_2 & DECAL_INIT_UPDATE_EXPERIENCED_2))
		source.flags_2 |= DECAL_INIT_UPDATE_EXPERIENCED_2
		source.update_appearance(UPDATE_OVERLAYS)
		UnregisterSignal(source, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)

/**
 * If the decal was not given an appearance, it will generate one based on the other given arguments.
 * element won't be compatible if it cannot do either
 * all args are fed into creating an image, they are byond vars for images you'll recognize in the byond docs
 * (except source, source is the object whose appearance we're copying.)
 */
/datum/element/decal/proc/generate_appearance(_icon, _icon_state, _dir, _layer, _color, _alpha, source)
	if(!_icon || !_icon_state)
		return FALSE
	var/temp_image = image(_icon, null, _icon_state, _layer, _dir)
	pic = new(temp_image)
	pic.color = _color
	pic.alpha = _alpha
	return TRUE

/datum/element/decal/Detach(atom/source)
	UnregisterSignal(source, list(
		COMSIG_ATOM_DIR_CHANGE,
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_PARENT_EXAMINE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_TURF_ON_SHUTTLE_MOVE,
		COMSIG_ATOM_DECALS_ROTATING,
		COMSIG_ATOM_GET_DECALS
	))
	SSdcs.UnregisterSignal(source, COMSIG_ATOM_DIR_CHANGE)
	source.update_appearance(UPDATE_OVERLAYS)
	if(isitem(source))
		INVOKE_ASYNC(source, TYPE_PROC_REF(/obj/item/, update_slot_icon))
	return ..()

/datum/element/decal/proc/apply_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER  // COMSIG_ATOM_UPDATE_OVERLAYS

	overlays += pic

/datum/element/decal/proc/clean_react(datum/source, clean_types)
	SIGNAL_HANDLER  // COMSIG_COMPONENT_CLEAN_ACT

	if(clean_types & cleanable)
		Detach(source)
		return COMPONENT_CLEANED
	return NONE

/datum/element/decal/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER  // COMSIG_PARENT_EXAMINE

	examine_list += description

/datum/element/decal/proc/shuttle_move_react(datum/source, turf/new_turf)
	SIGNAL_HANDLER  // COMSIG_TURF_ON_SHUTTLE_MOVE

	if(new_turf == source)
		return
	Detach(source)
	new_turf.AddElement(type, pic.icon, base_icon_state, directional, pic.layer, pic.alpha, pic.color, cleanable, description)

/datum/element/decal/proc/get_decals(datum/source, list/datum/element/decal/rotating)
	SIGNAL_HANDLER  // COMSIG_ATOM_DECALS_ROTATING
	rotating += src
