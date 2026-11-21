/// Things on a tile past which a right-click there opens the tile list instead of BYOND's right-click menu.
/// BYOND builds that menu in the client and it gets slow fast: 1000 seeds of one kind froze the game for 13.5 seconds.
#define PILE_MENU_LIMIT 100
/// ID of the game map window, used to turn its right-click menu on and off and to check a click came from it
#define PILE_MENU_MAP "paramapwindow.map"

/// Called when the mouse goes over something: turns the right-click menu off over a huge pile in reach, back on anywhere else.
/// Far piles keep the menu since the tile list only shows tiles in reach.
/client/proc/check_pile_menu(atom/hovered)
	if(!show_popup_menus) // something like build mode wants right-clicks for itself
		return
	var/turf/T = isturf(hovered) ? hovered : (isturf(hovered.loc) ? hovered.loc : null)
	var/off = !!(T && length(T.contents) > PILE_MENU_LIMIT && mob?.TurfAdjacent(T))
	if(off == pile_menu_off)
		return
	pile_menu_off = off
	winset(src, PILE_MENU_MAP, "right-click=[off ? "true" : "false"]")

/// A right-click on the map while the menu is off. Returns TRUE if it was handled here.
/client/proc/pile_right_click(atom/object, control, params)
	if(!pile_menu_off || control != PILE_MENU_MAP || !show_popup_menus)
		return FALSE
	var/list/modifiers = params2list(params)
	if(!modifiers["right"])
		return FALSE
	var/turf/T = istype(object) ? get_turf(object) : null
	if(T && length(T.contents) > PILE_MENU_LIMIT && mob?.TurfAdjacent(T))
		mob.set_listed_turf(T)
		return TRUE
	// The mouse got somewhere else before its hover did: give the menu back for the next right-click
	pile_menu_off = FALSE
	winset(src, PILE_MENU_MAP, "right-click=false")
	return TRUE

#undef PILE_MENU_LIMIT
#undef PILE_MENU_MAP
