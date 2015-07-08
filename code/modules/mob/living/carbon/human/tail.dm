var/global/list/tail_datums = list()

/hook/startup/proc/init_tail_datums()
	for(var/T in typesof(/datum/tail) - /datum/tail)
		tail_datums += new T
	return 1

/datum/tail
	var/name
	var/icon_file = 'icons/effects/species.dmi'
	var/icon_state
	var/animated_state
	var/list/species = list()

/datum/tail/proc/return_tail_icon_state()
	return "[icon_state]_s"

/datum/tail/proc/return_tail_animated_state()
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