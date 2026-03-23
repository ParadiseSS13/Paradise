// "Floating ghost blade" effect for blade heretics
/obj/effect/floating_blade
	name = "knife"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "dio_knife"
	layer = 3.75
	/// The color the knife glows around it.
	var/glow_color = "#ececff"

/obj/effect/floating_blade/Initialize(mapload)
	. = ..()
	add_filter("dio_knife", 2, list("type" = "outline", "color" = glow_color, "size" = 1))

/obj/effect/floating_blade/haunted
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "render"
