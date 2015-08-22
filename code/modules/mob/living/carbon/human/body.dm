var/global/list/alt_bodies_by_name = list()

/hook/startup/proc/init_alt_body()
	for(var/type in subtypesof(/datum/body))
		var/datum/body/s = new type
		if(istype(s,/datum/body))
			alt_bodies_by_name["[s.name]"] = s

	if(alt_bodies_by_name.len)
		return 1
	return 0

/datum/body
	var/name = "Default Body"

	var/icon = null
	var/icon_state = ""
	var/blend_mode = ICON_MULTIPLY

	var/list/pixel_offsets = list("x" = 0, "y" = 0)

/datum/body/snake
	name = "Snake"

	icon = 'icons/mob/human_bodies_64.dmi'
	icon_state = "naga_s"

	pixel_offsets = list("x" = -16, "y" = 0)