// Speeds up the offering process and optionally allows the admin to set up playtime requirement and "Show role" only once.
// Default setting is 20H like the default recommendation for offering from drop down menu.
/datum/buildmode_mode/offer
	key = "offer"
	var/hours = 20
	var/hide_role

/datum/buildmode_mode/offer/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left click to offer a mob</span>")
	to_chat(user, "<span class='notice'>Right click to change amount of playtime a player needs to be able to sign up and whether to display their special role</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/offer/change_settings(mob/user)
	hours = tgui_input_number(user, "Playtime required", "Input", 20)
	if(tgui_alert(user, "Do you want to show the mob's special role?", "Role Status", list("Yes", "No")) == "Yes")
		hide_role = FALSE
	else
		hide_role = TRUE

/datum/buildmode_mode/offer/handle_click(mob/user, params, atom/A)
	var/list/modifiers = params2list(params)
	var/left_click = LAZYACCESS(modifiers, LEFT_CLICK)
	var/selected_atom

	if(left_click && ismob(A) && !isobserver(A))
		selected_atom = A
		offer_control(selected_atom, hours, hide_role)

