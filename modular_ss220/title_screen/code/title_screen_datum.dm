/datum/title_screen
	/// The preamble html that includes all styling and layout.
	var/title_html = DEFAULT_TITLE_HTML
	/// The current notice text, or null.
	var/notice
	/// The current title screen being displayed, as `/datum/asset_cache_item`
	var/datum/asset_cache_item/screen_image

/datum/title_screen/New(title_html = DEFAULT_TITLE_HTML, notice, screen_image_file)
	src.title_html = title_html
	src.notice = notice
	set_screen_image(screen_image_file)

/datum/title_screen/proc/set_screen_image(screen_image_file)
	if(!screen_image_file)
		return

	if(!isfile(screen_image_file))
		screen_image_file = fcopy_rsc(screen_image_file)

	screen_image = SSassets.transport.register_asset("[screen_image_file]", screen_image_file)

/datum/title_screen/proc/show_to(client/viewer)
	if(!viewer)
		return

	winset(viewer, "title_browser", "is-disabled=true;is-visible=true")
	winset(viewer, "status_bar", "is-visible=false")

	var/datum/asset/lobby_asset = get_asset_datum(/datum/asset/simple/lobby_fonts)
	lobby_asset.send(viewer)

	SSassets.transport.send_assets(viewer, screen_image.name)

	viewer << browse(get_title_html(), "window=title_browser")

/datum/title_screen/proc/hide_from(client/viewer)
	if(viewer?.mob)
		winset(viewer, "title_browser", "is-disabled=true;is-visible=false")
		winset(viewer, "status_bar", "is-visible=true")

/**
 * Get the HTML of title screen.
 */
/datum/title_screen/proc/get_title_html()
	var/list/html = list(title_html)

	var/screen_image_url = SSassets.transport.get_asset_url(asset_cache_item = screen_image)
	if(screen_image_url)
		html += {"<img src="[screen_image_url]" class="bg" alt="">"}

	if(notice)
		html += {"
		<div class="container_notice">
			<p class="menu_notice">[notice]</p>
		</div>
	"}

	html += "</body></html>"

	return html.Join()
