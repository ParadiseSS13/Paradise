/client/verb/webmap()
	set name = "webmap"
	set hidden = TRUE

	if(!SSmapping.map_datum.webmap_url)
		to_chat(usr, "<span class='warning'>The current map has no defined webmap. Please file an issue report.</span>")
		return

	if(tgui_alert(usr, "Do you want to open this map's Webmap in your browser?", "Webmap", list("Yes", "No")) != "Yes")
		return

	usr << link(SSmapping.map_datum.webmap_url)

/client/verb/open_balance_pr()
	set name = "balance_pr"
	set hidden = TRUE

	if(tgui_alert(usr, "Do you want to open a balance PR?", "Webmap", list("Yes", "No")) != "Yes")
		return

	usr << link("http://github.com/ParadiseSS13/Paradise/compare/master...DGamerL:halp-I-got-killed-%3B-%3B?expand=1")
