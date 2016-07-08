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

/obj/effect/landmark/map_loader/New(loc, tname)
	..()
	if(tname)
		template_name = tname
	if(template_name)
		template = map_templates[template_name]
	if(template)
		load(template)

/obj/effect/landmark/map_loader/proc/load(datum/map_template/t)
	spawn(1)
		if(!t)
			return
		t.load(get_turf(src), centered = centered)
		t.loaded++
		qdel(src)

/obj/effect/landmark/map_loader/random
	var/template_list = ""

/obj/effect/landmark/map_loader/random/New()
	..()
	if(template_list)
		template_name = safepick(splittext(template_list, ";"))
		template = map_templates[template_name]
		load(template)