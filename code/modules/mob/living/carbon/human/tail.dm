var/global/list/tail_datums = list()

/hook/startup/proc/init_tail_datums()
	for(var/T in typesof(/datum/tail) - /datum/tail - /datum/tail/body)
		tail_datums += new T
	return 1

/datum/tail
	var/name
	var/icon_file = 'icons/effects/species.dmi'
	var/icon_state
	var/animated_state
	var/base_type = 1
	var/list/species = list()
	var/shift_x_size = 0
	var/icon_blend_mode = ICON_ADD

/datum/tail/proc/return_tail_icon_state()
	return "[icon_state]_s"

/datum/tail/proc/return_tail_animated_state()
	if(!animated_state)
		return "[icon_state]_s"
	return "[animated_state]w_s"

/datum/tail/tajaran
	name = "Tajaran Standard Tail"
	icon_state = "tajtail"
	animated_state = "tajtail"

/datum/tail/restricted_tajaran
	name = "Restricted Tajaran Standard Tail"
	icon_state = "tajtail"
	animated_state = "tajtail"
	species = list("Tajaran")

/datum/tail/body //not quite tails but they'll work
	name = "body"
	icon_file = 'icons/effects/tail_bodies.dmi'
	shift_x_size = -16
	icon_blend_mode = ICON_MULTIPLY

/datum/tail/body/snake
	name = "Snake Body"
	icon_state = "naga"