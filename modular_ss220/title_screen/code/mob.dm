#define TITLE_SCREEN_BG_FILE_NAME "bg_file_name"

/**
 * Shows the titlescreen to a new player.
 */
/mob/proc/show_title_screen()
	if(!client)
		return
	winset(src, "title_browser", "is-disabled=true;is-visible=true")
	winset(src, "status_bar", "is-visible=false")

	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/lobby) //Sending pictures to the client
	assets.send(src)

	update_title_screen()

/**
 * Get the HTML of title screen.
 */
/mob/proc/get_title_html()
	var/dat = SStitle.title_html
	dat += {"<img src="[TITLE_SCREEN_BG_FILE_NAME]" class="bg" alt="">"}

	if(SStitle.current_notice)
		dat += {"
		<div class="container_notice">
			<p class="menu_notice">[SStitle.current_notice]</p>
		</div>
	"}

	dat += "</body></html>"

	return dat

/**
 * Hard updates the title screen HTML, it causes visual glitches if used.
 */
/mob/proc/update_title_screen()
	var/dat = get_title_html()

	src << browse(SStitle.current_title_screen, "file=[TITLE_SCREEN_BG_FILE_NAME];display=0")
	src << browse(dat, "window=title_browser")

/datum/asset/simple/lobby
	assets = list(
		"FixedsysExcelsior3.01Regular.ttf" = 'modular_ss220/title_screen/html/browser/FixedsysExcelsior3.01Regular.ttf',
	)

/**
 * Removes the titlescreen entirely from a mob.
 */
/mob/proc/hide_title_screen()
	if(client?.mob)
		winset(client, "title_browser", "is-disabled=true;is-visible=false")
		winset(client, "status_bar", "is-visible=true")

#undef TITLE_SCREEN_BG_FILE_NAME
