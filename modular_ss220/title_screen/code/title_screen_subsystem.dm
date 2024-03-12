#define TITLE_SCREENS_LOCATION "config/title_screens/images/"

/datum/controller/subsystem/title
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TITLE
	/// Currently set title screen
	var/datum/title_screen/current_title_screen
	/// The list of image files available to be picked for title screen
	var/list/title_images_pool = list()

/datum/controller/subsystem/title/Initialize()
	fill_title_images_pool()
	current_title_screen = new(title_html = get_title_html(), screen_image_file = pick_title_image())
	show_title_screen_to_all_new_players()

/datum/controller/subsystem/title/Recover()
	current_title_screen = SStitle.current_title_screen
	title_images_pool = SStitle.title_images_pool

/**
 * Iterates over all files in `TITLE_SCREENS_LOCATION` and loads all valid title screens to `title_screens` var.
 */
/datum/controller/subsystem/title/proc/fill_title_images_pool()
	for(var/file_name in flist(TITLE_SCREENS_LOCATION))
		if(validate_filename(file_name))
			var/file_path = "[TITLE_SCREENS_LOCATION][file_name]"
			title_images_pool += fcopy_rsc(file_path)

/**
 * Checks wheter passed title is valid
 * Currently validates extension and checks whether it's special image like default title screen etc.
 */
/datum/controller/subsystem/title/proc/validate_filename(filename)
	var/static/list/title_screens_to_ignore = list("blank.png")
	if(filename in title_screens_to_ignore)
		return FALSE

	var/static/list/supported_extensions = list("gif", "jpg", "jpeg", "png", "svg")
	var/extstart = findlasttext(filename, ".")
	if(!extstart)
		return FALSE

	var/extension = copytext(filename, extstart + 1)
	return (extension in supported_extensions)

/**
 * Show the title screen to all new players.
 */
/datum/controller/subsystem/title/proc/show_title_screen_to_all_new_players()
	if(!current_title_screen)
		return

	for(var/mob/new_player/viewer in GLOB.player_list)
		show_title_screen_to(viewer.client)

/**
 * Show the title screen to specific client.
 */
/datum/controller/subsystem/title/proc/show_title_screen_to(client/viewer)
	if(!viewer || !current_title_screen)
		return

	INVOKE_ASYNC(current_title_screen, TYPE_PROC_REF(/datum/title_screen, show_to), viewer)

/**
 * Hide the title screen from specific client.
 */
/datum/controller/subsystem/title/proc/hide_title_screen_from(client/viewer)
	if(!viewer || !current_title_screen)
		return

	INVOKE_ASYNC(current_title_screen, TYPE_PROC_REF(/datum/title_screen, hide_from), viewer)

/**
 * Adds a notice to the main title screen in the form of big red text!
 */
/datum/controller/subsystem/title/proc/set_notice(new_notice)
	new_notice = new_notice ? sanitize_text(new_notice) : null

	if(!current_title_screen)
		if(!new_notice)
			return

		current_title_screen = new(notice = new_notice)
	else
		current_title_screen.notice = new_notice

	show_title_screen_to_all_new_players()

/**
 * Replaces html of title screen
 */
/datum/controller/subsystem/title/proc/set_title_html(new_html)
	if(!new_html)
		return

	if(!current_title_screen)
		current_title_screen = new(title_html = new_html)
	else
		current_title_screen.title_html = new_html

	show_title_screen_to_all_new_players()

/**
 * Changes title image to desired
 */
/datum/controller/subsystem/title/proc/set_title_image(desired_image_file)
	if(desired_image_file)
		if(!isfile(desired_image_file))
			CRASH("Not a file passed to `/datum/controller/subsystem/title/proc/set_title_image`")
	else
		desired_image_file = pick_title_image()

	if(!current_title_screen)
		current_title_screen = new(screen_image_file = desired_image_file)
	else
		current_title_screen.set_screen_image(desired_image_file)

	show_title_screen_to_all_new_players()

/**
 * Picks title image from `title_images_pool` list. If the list is empty, `DEFAULT_TITLE_HTML` is returned
 */
/datum/controller/subsystem/title/proc/pick_title_image()
	return length(title_images_pool) ? pick(title_images_pool) : DEFAULT_TITLE_SCREEN_IMAGE_PATH


/**
 * Tries to read title html from config, if none found - backups to `DEFAULT_TITLE_HTML`
 */
/datum/controller/subsystem/title/proc/get_title_html()
	if(!fexists("config/title_html.txt"))
		error(span_boldwarning("Unable to read title_html.txt, reverting to backup title html, please check your server config and ensure this file exists."))
		return DEFAULT_TITLE_HTML
	else
		return file2text("config/title_html.txt")

#undef TITLE_SCREENS_LOCATION
