/*
 * ViewMods Client module
 * This should be used by anything that wants to change a client's view range.
 * Also includes
 */

/* Defines */
#define CUSTOM_VIEWRANGES list(1, 2, 3, 4, 5, 6, "RESET")

/* Viewmods */
/client
	var/list/ViewMods = list()
	var/ViewModsActive = FALSE
	var/ViewPreferedIconSize = 0

/client/proc/AddViewMod(id, size)
	var/datum/viewmod/V = new /datum/viewmod(id, size)
	ViewMods[V.id] = V
	UpdateView()

/client/proc/CheckViewMod(id)
	. = 0
	if(ViewMods[id])
		. = 1

/client/proc/RemoveViewMod(id)
	if(CheckViewMod(id))
		qdel(ViewMods[id])
		ViewMods.Remove(id)
	UpdateView()

/client/proc/UpdateView()
	if(!ViewModsActive)
		ViewPreferedIconSize = winget(src, "mapwindow.map", "icon-size")

	var/highest_range = 0
	for(var/mod_id in ViewMods)
		var/datum/viewmod/V = ViewMods[mod_id]
		highest_range = max(highest_range, V.size)

	SetView(highest_range ? highest_range : world.view)
	ViewModsActive = (highest_range > 0)

/client/proc/SetView(view_range)
	if(view_range == world.view)
		winset(src, "mapwindow.map", "icon-size=[ViewPreferedIconSize]")
	else
		winset(src, "mapwindow.map", "icon-size=0")

	view = view_range

	if(mob && mob.hud_used)
		// If view range is less than world.view, assume the HUD will not fit under normal mode and turn it to reduced
		if(view_range < world.view)
			// If it's really tiny, turn their hud off completely
			if(view_range <= ARBITRARY_VIEWRANGE_NOHUD)
				mob.hud_used.show_hud(HUD_STYLE_NOHUD)
			else
				mob.hud_used.show_hud(HUD_STYLE_REDUCED)
		else
			mob.hud_used.show_hud(HUD_STYLE_STANDARD)

/* Viewmod datums */
/datum/viewmod
	var/id = ""
	var/size = -1

/datum/viewmod/New(new_id, new_size = world.view)
	. = ..()
	id = new_id
	size = new_size

/* Client verbs */
/proc/viewNum_to_text(view)
	return "[(view * 2) + 1]x[(view * 2) + 1]"

/client/verb/set_view_range(view_range as null|anything in CUSTOM_VIEWRANGES)
	set name = "Set View Range"
	set category = "Preferences"

	if(!view_range)
		return

	RemoveViewMod("custom")
	if(view_range == "RESET")
		to_chat(src, "<span class='notice'>View range reset.</span>")
		return

	to_chat(src, "<span class='notice'>View range set to [viewNum_to_text(view_range)]</span>")
	AddViewMod("custom", view_range)