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

DEFINE_BITFIELD(flags, list(
	"STOPSPRESSUREDMAGE" = STOPSPRESSUREDMAGE,
	"NODROP" = NODROP,
	"NOBLUDGEON" = NOBLUDGEON,
	"AIRTIGHT" = AIRTIGHT,
	"HANDSLOW" = HANDSLOW,
	"CONDUCT" = CONDUCT,
	"ABSTRACT" = ABSTRACT,
	"ON_BORDER" = ON_BORDER,
	"PREVENT_CLICK_UNDER" = PREVENT_CLICK_UNDER,
	"NODECONSTRUCT" = NODECONSTRUCT,
	"EARBANGPROTECT" = EARBANGPROTECT,
	"HEADBANGPROTECT" = HEADBANGPROTECT,
	"BLOCK_GAS_SMOKE_EFFECT" = BLOCK_GAS_SMOKE_EFFECT,
	"THICKMATERIAL" = THICKMATERIAL,
	"DROPDEL" = DROPDEL,
	"NO_SCREENTIPS" = NO_SCREENTIPS,
))

DEFINE_BITFIELD(flags_2, list(
	"SLOWS_WHILE_IN_HAND_2" = SLOWS_WHILE_IN_HAND_2,
	"NO_EMP_WIRES_2" = NO_EMP_WIRES_2,
	"HOLOGRAM_2" = HOLOGRAM_2,
	"FROZEN_2" = FROZEN_2,
	"STATIONLOVING_2" = STATIONLOVING_2,
	"INFORM_ADMINS_ON_RELOCATE_2" = INFORM_ADMINS_ON_RELOCATE_2,
	"BANG_PROTECT_2" = BANG_PROTECT_2,
	"BLOCKS_LIGHT_2" = BLOCKS_LIGHT_2,
	"DECAL_INIT_UPDATE_EXPERIENCED_2" = DECAL_INIT_UPDATE_EXPERIENCED_2,
	"OMNITONGUE_2" = OMNITONGUE_2,
	"SHOCKED_2" = SHOCKED_2,
	"NO_MAT_REDEMPTION_2" = NO_MAT_REDEMPTION_2,
	"LAVA_PROTECT_2" = LAVA_PROTECT_2,
	"OVERLAY_QUEUED_2" = OVERLAY_QUEUED_2,
	"RAD_PROTECT_CONTENTS_2" = RAD_PROTECT_CONTENTS_2,
	"RAD_NO_CONTAMINATE_2" = RAD_NO_CONTAMINATE_2,
	"IMMUNE_TO_SHUTTLECRUSH_2" = IMMUNE_TO_SHUTTLECRUSH_2,
	"NO_MALF_EFFECT_2" = NO_MALF_EFFECT_2,
	"CRITICAL_ATOM_2" = CRITICAL_ATOM_2,
	"RANDOM_BLOCKER_2" = RANDOM_BLOCKER_2,
	"ALLOW_BELT_NO_JUMPSUIT_2" = ALLOW_BELT_NO_JUMPSUIT_2,
))

DEFINE_BITFIELD(flags_ricochet, list(
	"RICOCHET_SHINY" = RICOCHET_SHINY,
	"RICOCHET_HARD" = RICOCHET_HARD,
))

DEFINE_BITFIELD(clothing_flags, list(
	"HAS_UNDERWEAR" = HAS_UNDERWEAR,
	"HAS_UNDERSHIRT" = HAS_UNDERSHIRT,
	"HAS_SOCKS" = HAS_SOCKS,
))

DEFINE_BITFIELD(bodyflags, list(
	"HAS_HEAD_ACCESSORY" = HAS_HEAD_ACCESSORY,
	"HAS_TAIL" = HAS_TAIL,
	"TAIL_OVERLAPPED" = TAIL_OVERLAPPED,
	"HAS_SKIN_TONE" = HAS_SKIN_TONE,
	"HAS_ICON_SKIN_TONE" = HAS_ICON_SKIN_TONE,
	"HAS_SKIN_COLOR" = HAS_SKIN_COLOR,
	"HAS_HEAD_MARKINGS" = HAS_HEAD_MARKINGS,
	"HAS_BODY_MARKINGS" = HAS_BODY_MARKINGS,
	"HAS_TAIL_MARKINGS" = HAS_TAIL_MARKINGS,
	"TAIL_WAGGING" = TAIL_WAGGING,
	"NO_EYES" = NO_EYES,
	"HAS_ALT_HEADS" = HAS_ALT_HEADS,
	"HAS_WING" = HAS_WING,
	"HAS_BODYACC_COLOR" = HAS_BODYACC_COLOR,
	"BALD" = BALD,
	"ALL_RPARTS" = ALL_RPARTS,
	"SHAVED" = SHAVED,
))

DEFINE_BITFIELD(pass_flags, list(
	"PASSTABLE" = PASSTABLE,
	"PASSGLASS" = PASSGLASS,
	"PASSGRILLE" = PASSGRILLE,
	"PASSBLOB" = PASSBLOB,
	"PASSMOB" = PASSMOB,
	"LETPASSTHROW" = LETPASSTHROW,
	"PASSFENCE" = PASSFENCE,
	"PASSDOOR" = PASSDOOR,
	"PASSGIRDER" = PASSGIRDER,
	"PASSBARRICADE" = PASSBARRICADE,
	"PASSTAKE" = PASSTAKE,
))

DEFINE_BITFIELD(pass_flags_self, list(
	"PASSTAKE" = PASSTAKE,
	"LETPASSTHROW" = LETPASSTHROW,
))

DEFINE_BITFIELD(resistance_flags, list(
	"LAVA_PROOF" = LAVA_PROOF,
	"FIRE_PROOF" = FIRE_PROOF,
	"FLAMMABLE" = FLAMMABLE,
	"ON_FIRE" = ON_FIRE,
	"UNACIDABLE" = UNACIDABLE,
	"ACID_PROOF" = ACID_PROOF,
	"INDESTRUCTIBLE" = INDESTRUCTIBLE,
	"FREEZE_PROOF" = FREEZE_PROOF,
))

DEFINE_BITFIELD(mobility_flags, list(
	"MOBILITY_MOVE" = MOBILITY_MOVE,
	"MOBILITY_STAND" = MOBILITY_STAND,
	"MOBILITY_PICKUP" = MOBILITY_PICKUP,
	"MOBILITY_USE" = MOBILITY_USE,
	"MOBILITY_PULL" = MOBILITY_PULL,
))

DEFINE_BITFIELD(status_flags, list(
	"CANSTUN" = CANSTUN,
	"CANWEAKEN" = CANWEAKEN,
	"CANPARALYSE" = CANPARALYSE,
	"CANPUSH" = CANPUSH,
	"PASSEMOTES" = PASSEMOTES,
	"GODMODE" = GODMODE,
	"TERMINATOR_FORM" = TERMINATOR_FORM,
))
