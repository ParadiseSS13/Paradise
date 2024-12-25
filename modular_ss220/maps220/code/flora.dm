/obj/structure/flora/biolumini
	name = "glowing plants"
	desc = "Several sticks with bulbous, bioluminescent tips."
	icon = 'modular_ss220/maps220/icons/mesaflora.dmi'
	icon_state = "stick"
	light_range = 4
	light_power = 1
	max_integrity = 50
	var/list/random_light = list("#6AFF00","#00FFEE", "#D9FF00", "#FFC800")

/obj/structure/flora/biolumini/Initialize(mapload)
	. = ..()
	icon_state = "stick[rand(1, 9)]"
	if(random_light)
		light_color = pick(random_light)
	update_appearance()

// /obj/structure/flora/biolumini/update_overlays()
// 	. = ..()
// 	cut_overlay(src, managed_overlays)
// 	add_overlay(src, icon, "[icon_state]_light", 0, ABOVE_LIGHTING_PLANE)
// 	if(light_color)
// 		var/obj/effect/overlay = managed_overlays[1]
// 		overlay.color = light_color


/obj/structure/flora/biolumini/flower
	name = "glowing plant"
	desc = "Beautiful, bioluminescent flower."
	icon_state = "flower"

/obj/structure/flora/biolumini/flower/Initialize(mapload)
	. = ..()
	icon_state = "flower[rand(1, 2)]"

/obj/structure/flora/biolumini/mine
	name = "glowing plant"
	desc = "Glowing sphere encased in jungle leaves."
	icon_state = "mine"

/obj/structure/flora/biolumini/mine/Initialize(mapload)
	. = ..()
	icon_state = "mine[rand(1, 4)]"

/obj/structure/flora/biolumini/lamp
	name = "plant lamp"
	desc = "Bioluminescent plant much in a shape of a street lamp."
	icon_state = "lamp"

/obj/structure/flora/biolumini/lamp/Initialize(mapload)
	. = ..()
	icon_state = "lamp[rand(1, 2)]"

/obj/structure/flora/biolumini/mine/weaklight
	light_power = 0.5

/obj/structure/flora/biolumini/flower/weaklight
	light_power = 0.5

/obj/structure/flora/biolumini/lamp/weaklight
	light_power = 0.5

