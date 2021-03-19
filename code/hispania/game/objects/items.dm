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

/obj/item/proc/remove_outline()
	if(outline_filter)
		filters -= outline_filter
		outline_filter = null

/obj/item/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	remove_outline()
