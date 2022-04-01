/obj/screen/screentip
	icon = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "TOP,LEFT"
	maptext_height = 480
	maptext_width = 480
	maptext_y = -50
	maptext = ""

/obj/screen/screentip/Initialize(mapload, _hud)
	. = ..()
	hud = _hud
	update_view()

/obj/screen/screentip/proc/update_view(datum/source)
	if(!hud) //Might not have been initialized by now
		return
	maptext_width = getviewsize(hud.mymob.client.view)[1] * world.icon_size
