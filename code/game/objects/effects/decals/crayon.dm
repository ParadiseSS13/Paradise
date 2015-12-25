/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	layer = 2.1
	anchored = 1


/obj/effect/decal/cleanable/crayon/New(location, main = "#FFFFFF", var/type = "rune1", var/e_name = "rune")
	..()
	loc = location

	name = e_name
	desc = "A [name] drawn in crayon."
	if(type == "poseur tag")
		type = pick(gang_name_pool)
	icon_state = type
	color = main

/obj/effect/decal/cleanable/crayon/gang
	layer = 3.6 //Harder to hide
	var/datum/gang/gang

/obj/effect/decal/cleanable/crayon/gang/New(location, var/datum/gang/G, var/e_name = "gang tag")
	if(!type || !G)
		qdel(src)

	var/area/territory = get_area(location)

	gang = G
	color = G.color_hex
	icon_state = G.name
	G.territory_new |= list(territory.type = territory.name)

	..(location, color, icon_state, e_name)

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	var/area/territory = get_area(src)

	if(gang)
		gang.territory -= territory.type
		gang.territory_new -= territory.type
		gang.territory_lost |= list(territory.type = territory.name)
	return ..()