/obj/structure/chair/comfy
	icon = 'modular_ss220/aesthetics/chairs/icons/chairs.dmi'

/obj/structure/chair/comfy/GetArmrest()
	return mutable_appearance('modular_ss220/aesthetics/chairs/icons/chairs.dmi', "[icon_state]_armrest")

/obj/structure/chair/comfy/corp
	icon = 'icons/obj/chairs.dmi'

/obj/structure/chair/comfy/corp/GetArmrest()
	return mutable_appearance('icons/obj/chairs.dmi', "[icon_state]_armrest")

/obj/structure/chair/comfy/shuttle
	icon = 'icons/obj/chairs.dmi'

// Recoloring comfy's
/obj/structure/chair/comfy/beige
	color = rgb(240, 240, 200)

/obj/structure/chair/comfy/black
	color = rgb(60, 60, 55)

/obj/structure/chair/comfy/red
	color = rgb(165, 65, 65)

/obj/structure/chair/comfy/brown
	color = rgb(141, 70, 0)

/obj/structure/chair/comfy/green
	color = rgb(80, 170, 85)

/obj/structure/chair/comfy/lime
	color = rgb(185, 210, 115)

/obj/structure/chair/comfy/yellow
	color = rgb(225, 215, 125)

/obj/structure/chair/comfy/blue
	color = rgb(80, 125, 220)

/obj/structure/chair/comfy/teal
	color = rgb(115, 215, 215)

/obj/structure/chair/comfy/purp
	color = rgb(100, 65, 120)

/obj/structure/chair/office/dark
	icon = 'modular_ss220/aesthetics/chairs/icons/chairs.dmi'

/obj/structure/chair/office/light
	icon = 'modular_ss220/aesthetics/chairs/icons/chairs.dmi'

/obj/structure/chair/e_chair
	icon = 'modular_ss220/aesthetics/chairs/icons/chairs.dmi'

//TODO: Support or chairs

/obj/item/chair/stool/bar/dark
	icon = 'modular_ss220/aesthetics/chairs/icons/chairs.dmi'
	icon_state = "bar_toppled_dark"
	item_state = "stool_bar_dark"
	origin_type = /obj/structure/chair/stool/bar/dark
	lefthand_file = 'modular_ss220/aesthetics/chairs/icons/chairs_lefthand.dmi'
	righthand_file = 'modular_ss220/aesthetics/chairs/icons/chairs_righthand.dmi'

/obj/structure/chair/stool/bar/dark
	icon = 'modular_ss220/aesthetics/chairs/icons/chairs.dmi'
	icon_state = "bar_dark"
	item_chair = /obj/item/chair/stool/bar/dark
