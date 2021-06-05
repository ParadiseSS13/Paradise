#define CLIENT_FROM_VAR(I) (ismob(I) ? I:client : (istype(I, /client) ? I : (istype(I, /datum/mind) ? I:current?:client : null)))

/client/var/status_bar_prev_text = ""

/proc/status_bar_set_text(target, text)
	var/client/client = CLIENT_FROM_VAR(target)
	// Stop a winset call if text didn't change.
	if(!client || client.status_bar_prev_text == text)
		return
	client.status_bar_prev_text = text
	winset(client, "mapwindow.status_bar",
		"text=[url_encode(text)]&is-visible=[!!text]")
