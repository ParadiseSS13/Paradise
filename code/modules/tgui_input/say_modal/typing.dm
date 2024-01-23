/mob/set_stat(new_stat)
	. = ..()
	if(.)
		set_typing_indicator(FALSE)

/mob/Logout()
	set_typing_indicator(FALSE)
	return ..()

/** Sets the mob as "thinking" - with indicator and variable thinking_IC */
/datum/tgui_say/proc/start_thinking()
	if(!client?.mob || !window_open)
		return FALSE
	/// Special exemptions
	if(isabductor(client.mob))
		return FALSE
	client.mob.set_typing_indicator(TRUE, TRUE)

/** Removes typing/thinking indicators and flags the mob as not thinking */
/datum/tgui_say/proc/stop_thinking()
	if(!client?.mob)
		return FALSE
	client.mob.set_typing_indicator(FALSE)

/**
 * Handles the user typing. After a brief period of inactivity,
 * signals the client mob to revert to the "thinking" icon.
 */
/datum/tgui_say/proc/start_typing()
	if(!client?.mob)
		return FALSE
	client.mob.set_typing_indicator(FALSE)
	if(!window_open)
		return FALSE
	client.mob.set_typing_indicator(TRUE)
	addtimer(CALLBACK(src, PROC_REF(stop_typing)), 5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)

/**
 * Callback to remove the typing indicator after a brief period of inactivity.
 * If the user was typing IC, the thinking indicator is shown.
 */
/datum/tgui_say/proc/stop_typing()
	if(!client?.mob)
		return FALSE
	client.mob.set_typing_indicator(FALSE)
	if(!window_open)
		return FALSE
	client.mob.set_typing_indicator(TRUE, TRUE)
