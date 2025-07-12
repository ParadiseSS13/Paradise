/mob/dead/observer/proc/update_admin_actions()
	for(var/datum/action/innate/admin/action in actions)
		if(!check_rights(action.rights_required, FALSE, src))
			qdel(action)
	if(!client || !client.holder)
		return
	if(ckey && (ckey in (GLOB.de_admins + GLOB.de_mentors)))
		return

	for(var/datum/action/innate/admin/action as anything in subtypesof(/datum/action/innate/admin))
		if(check_rights(action.rights_required, FALSE, src))
			var/datum/action/innate/admin/given_action = new action()
			given_action.Grant(src)

/datum/action/innate/admin
	button_icon = 'icons/mob/actions/actions_admin.dmi'
	var/rights_required = R_ADMIN

/datum/action/innate/admin/Trigger()
	if(!..())
		return FALSE
	if(!check_rights(rights_required, TRUE, usr))
		return
	admin_click(usr)

/datum/action/innate/admin/proc/admin_click(mob/user)
	return

/datum/action/innate/admin/ticket
	name = "Adminhelps"
	desc = "There are 0 open tickets."
	button_icon_state = "adminhelp"
	var/mutable_appearance/button_text
	var/ticket_amt = 0

/datum/action/innate/admin/ticket/New(Target)
	button_icon_state = "nohelp"
	. = ..()
	register_ticket_signals()

/datum/action/innate/admin/ticket/admin_click(mob/user)
	SStickets.showUI(user)

/datum/action/innate/admin/ticket/proc/register_ticket_signals()
	RegisterSignal(SStickets, COMSIGN_TICKET_COUNT_UPDATE, PROC_REF(update_tickets))
	SStickets.open_ticket_count_updated() // update the starting count

/datum/action/innate/admin/ticket/proc/update_tickets(ticketsystem, _ticket_amt)
	ticket_amt = _ticket_amt
	desc = "There are [ticket_amt] open tickets."
	if(ticket_amt > 0)
		button_icon_state = initial(button_icon_state)
	else
		button_icon_state = "nohelp"
	build_all_button_icons(force = TRUE)

/datum/action/innate/admin/ticket/apply_button_overlay(atom/movable/screen/movable/action_button/button, force)
	. = ..()
	// TODO: We need a generic way to handle button text for actions bc this is atrocious
	// Yes cutting and adding the overlay each time is required
	button.cut_overlay(button_text)
	button_text = mutable_appearance('icons/effects/effects.dmi', icon_state = "nothing")
	button_text.appearance_flags = RESET_COLOR | RESET_ALPHA
	button_text.plane = FLOAT_PLANE + 1
	button_text.maptext_x = 2
	button_text.maptext = ticket_amt > 0 ? "<span class='maptext'>[ticket_amt]</span>" : ""
	button.add_overlay(button_text)

/datum/action/innate/admin/ticket/mentor
	name = "Mentorhelps"
	button_icon_state = "mentorhelp"
	rights_required = R_MENTOR|R_ADMIN

/datum/action/innate/admin/ticket/mentor/register_ticket_signals()
	RegisterSignal(SSmentor_tickets, COMSIGN_TICKET_COUNT_UPDATE, PROC_REF(update_tickets))
	SSmentor_tickets.open_ticket_count_updated() // update the starting count

/datum/action/innate/admin/ticket/mentor/admin_click(mob/user)
	SSmentor_tickets.showUI(user)
