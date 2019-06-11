/obj/effect/temp_visual/healfast //color is white by default, set to whatever is needed
	name = "healing glow"
	icon_state = "heal"
	duration = 30

/obj/effect/temp_visual/healfast/New(loc, colour)
	..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-9, 0)
	if(colour)
		color = colour

