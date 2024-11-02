GLOBAL_LIST_INIT(bitfields, generate_bitfields())

/// Specifies a bitfield for smarter debugging
/datum/bitfield
	/// The variable name that contains the bitfield
	var/variable
	/// An associative list of the readable flag and its true value
	var/list/flags

/datum/bitfield/can_vv_delete()
	return FALSE

/datum/bitfield/vv_edit_var(var_name, var_value)
	return FALSE // no.

/// Turns /datum/bitfield subtypes into a list for use in debugging
/proc/generate_bitfields()
	var/list/bitfields = list()
	for(var/_bitfield in subtypesof(/datum/bitfield))
		var/datum/bitfield/bitfield = new _bitfield
		bitfields[bitfield.variable] = bitfield.flags
	return bitfields

/proc/translate_bitfield(variable_type, variable_name, variable_value)
	if(variable_type != VV_BITFIELD)
		return variable_value

	var/list/flags = list()
	for(var/flag in GLOB.bitfields[variable_name])
		if(variable_value & GLOB.bitfields[variable_name][flag])
			flags += flag
	if(length(flags))
		return jointext(flags, ", ")
	return "NONE"

/proc/input_bitfield(mob/user, bitfield, current_value)
	if(!user || !(bitfield in GLOB.bitfields))
		return
	var/list/currently_checked = list()
	for(var/name in GLOB.bitfields[bitfield])
		currently_checked[name] = (current_value & GLOB.bitfields[bitfield][name])

	var/list/result = tgui_input_checkbox_list(user, "Editing bitfield for [bitfield].", "Editing bitfield", currently_checked)
	if(isnull(result) || !islist(result))
		return

	var/new_result = 0
	for(var/name in GLOB.bitfields[bitfield])
		if(result[name])
			new_result |= GLOB.bitfields[bitfield][name]
	return new_result

// MARK: Default byond bitfields

DEFINE_BITFIELD(appearance_flags, list(
	"KEEP_APART" = KEEP_APART,
	"KEEP_TOGETHER" = KEEP_TOGETHER,
	"LONG_GLIDE" = LONG_GLIDE,
	"NO_CLIENT_COLOR" = NO_CLIENT_COLOR,
	"PIXEL_SCALE" = PIXEL_SCALE,
	"PLANE_MASTER" = PLANE_MASTER,
	"RESET_ALPHA" = RESET_ALPHA,
	"RESET_COLOR" = RESET_COLOR,
	"RESET_TRANSFORM" = RESET_TRANSFORM,
	"TILE_BOUND" = TILE_BOUND,
	"PASS_MOUSE" = PASS_MOUSE,
	"TILE_MOVER" = TILE_MOVER,
))

DEFINE_BITFIELD(sight, list(
	"BLIND" = BLIND,
	"SEE_BLACKNESS" = SEE_BLACKNESS,
	"SEE_INFRA" = SEE_INFRA,
	"SEE_MOBS" = SEE_MOBS,
	"SEE_OBJS" = SEE_OBJS,
	"SEE_PIXELS" = SEE_PIXELS,
	"SEE_SELF" = SEE_SELF,
	"SEE_THRU" = SEE_THRU,
	"SEE_TURFS" = SEE_TURFS,
))

DEFINE_BITFIELD(vis_flags, list(
	"VIS_HIDE" = VIS_HIDE,
	"VIS_INHERIT_DIR" = VIS_INHERIT_DIR,
	"VIS_INHERIT_ICON" = VIS_INHERIT_ICON,
	"VIS_INHERIT_ICON_STATE" = VIS_INHERIT_ICON_STATE,
	"VIS_INHERIT_ID" = VIS_INHERIT_ID,
	"VIS_INHERIT_LAYER" = VIS_INHERIT_LAYER,
	"VIS_INHERIT_PLANE" = VIS_INHERIT_PLANE,
	"VIS_UNDERLAY" = VIS_UNDERLAY,
))


// MARK: Other bitfields

