// The cuuuuuuuuuuuuuube
/obj/item/flock_cube
	name = "weird cube"
	desc = "A weird looking cube."
	icon_state = "cube"
	icon = 'icons/goonstation/mob/featherzone.dmi'
	light_color = "#26ffe6"
	light_power = 0.2
	light_range = 2

	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000, MAT_GNESIS = 2000, MAT_GNESIS_GLASS = 2000)
	origin_tech = "materials=5;biotech=5;programming=5"

	/// How much shit in da cube
	var/substrate = 10
