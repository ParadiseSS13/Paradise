/obj/effect/landmark/map_loader
	name = "map loader"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	invisibility = 101
	anchored = 1
	density = 0
	opacity = 0
	var/template_name = null
	var/datum/map_template/template = null
	var/centered = 1
	var/loaded = 0

/obj/effect/landmark/map_loader/New(turf/loc, tname)
	..()

	if(tname)
		template_name = tname
	if(template_name)
		template = map_templates[template_name]

/obj/effect/landmark/map_loader/initialize()
	..()
	if(template)
		load(template)

/obj/effect/landmark/map_loader/set_tag()
	return

/obj/effect/landmark/map_loader/proc/load(datum/map_template/t)
	if(!t)
		return
	if(loaded) // I wanna be super sure this loads only once
		return
	loaded = 1
	var/turf/pos = get_turf(src)
	// Hop to nullspace so we don't get re-initialized by the map we're loading
	loc = null
	t.load(pos, centered = centered)
	t.loaded++
	qdel(src)

/obj/effect/landmark/map_loader/random
	var/template_list = ""

/obj/effect/landmark/map_loader/random/initialize()
	..()
	if(template_list)
		template_name = safepick(splittext(template_list, ";"))
		template = map_templates[template_name]
		load(template)
