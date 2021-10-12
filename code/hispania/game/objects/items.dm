/obj/item/proc/swapped(mob/usr)
	return

/obj/item/proc/swappedto(mob/usr)
	return

/obj/item/proc/hotkeyequip(mob/usr)
	return

/obj/item/proc/apply_outline(outline_color = null)
	if(!in_inventory || QDELETED(src) || isobserver(usr)) //cancel if the item isn't in an inventory, is being deleted, or if the person hovering is a ghost (so that people spectating you don't randomly make your items glow)
		return
	if(!outline_color) //if we weren't provided with a color, take the theme's color
		outline_color = usr.client?.prefs.UI_style_color
	if(color)
		outline_color = COLOR_WHITE //if the item is recolored then the outline will be too, let's make the outline white so it becomes the same color instead of some ugly mix of the theme and the tint
	if(outline_filter)
		filters -= outline_filter
	outline_filter = filter(type="outline", size=1, color=outline_color)
	filters += outline_filter

	if(!(in_inventory || in_storage) || QDELETED(src) || isobserver(usr)) //cancel if the item isn't in an inventory, is being deleted, or if the person hovering is a ghost (so that people spectating you don't randomly make your items glow)
		return
	var/theme = lowertext(usr.client.prefs.UI_style)
	if(!outline_color) //if we weren't provided with a color, take the theme's color
		switch(theme) //yeah it kinda has to be this way
			if("midnight")
				outline_color = COLOR_THEME_MIDNIGHT
			if("plasmafire")
				outline_color = COLOR_THEME_PLASMAFIRE
			if("retro")
				outline_color = COLOR_THEME_RETRO //just as garish as the rest of this theme
			if("slimecore")
				outline_color = COLOR_THEME_SLIMECORE
			if("operative")
				outline_color = COLOR_THEME_OPERATIVE
			if("clockwork")
				outline_color = COLOR_THEME_CLOCKWORK //if you want free gbp go fix the fact that clockwork's tooltip css is glass'
			if("glass")
				outline_color = COLOR_THEME_GLASS
			else //this should never happen, hopefully
				outline_color = COLOR_WHITE
	if(color)
		outline_color = COLOR_WHITE //if the item is recolored then the outline will be too, let's make the outline white so it becomes the same color instead of some ugly mix of the theme and the tint
	if(outline_filter)
		filters -= outline_filter
	outline_filter = filter(type = "outline", size = 1, color = outline_color)
	filters += outline_filter

/obj/item/proc/remove_outline()
	if(outline_filter)
		filters -= outline_filter
		outline_filter = null

/obj/item/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	remove_outline()
