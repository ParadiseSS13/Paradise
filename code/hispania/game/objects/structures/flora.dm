/obj/structure/flora/tree/blue_light_naga
	name = "polar tree"
	icon = 'icons/hispania/obj/flora/flora_snow.dmi'
	icon_state = "tree_sif0"
	light_color = LIGHT_COLOR_CYAN
	light_range = 2

/obj/structure/flora/tree/blue_light_naga/New()
	..()
	icon_state = "tree_sif[rand(0, 5)]"

/obj/structure/flora/bush/naga_bush
	name = "polar bush"
	icon = 'icons/hispania/obj/flora/small_flora_snow.dmi'
	icon_state = "frostbelle0"

/obj/structure/flora/bush/naga_bush/New()
	..()
	icon_state = "frostbelle[rand(0, 3)]"

/obj/structure/flora/bush/naga_eyes
	name = "polar eye plant"
	light_color = LIGHT_COLOR_CYAN
	light_range = 1
	icon = 'icons/hispania/obj/flora/small_flora_snow.dmi'
	icon_state = "eyeplant1"

/obj/structure/flora/bush/naga_eyes/New()
	..()
	icon_state = "eyeplant[rand(1, 3)]"

/obj/structure/flora/bush/naga_eye_yellow
	name = "polar yellow eye"
	icon = 'icons/hispania/obj/flora/small_flora_snow.dmi'
	icon_state = "glowplant1"
	light_color = LIGHT_COLOR_YELLOW
	light_range = 1

/obj/structure/flora/bush/naga_eye_yellow/New()
	..()
	icon_state = "glowplant[rand(1, 2)]"
