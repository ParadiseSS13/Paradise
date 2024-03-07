/atom/movable/screen/screentip
	icon = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "TOP,LEFT"
	maptext_height = 480
	maptext_width = 480
	maptext_y = -50
	maptext = ""

/atom/movable/screen/screentip/Initialize(mapload, _hud)
	. = ..()
	hud = _hud
	update_view()

/atom/movable/screen/screentip/proc/update_view(datum/source)
	if(!hud?.mymob?.client) //Might not have been initialized by now
		return
	var/list/view_size = getviewsize(hud.mymob.client.view)
	var/view = "[view_size[1]]x[view_size[2]]"
	maptext_width = view_to_pixels(view)[1]
