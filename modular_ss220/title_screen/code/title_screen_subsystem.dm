#define TITLE_SCREENS_LOCATION "config/title_screens/images/"

/datum/controller/subsystem/title
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TITLE
	/// The current title screen being displayed, as a file path text.
	var/current_title_screen
	/// The current notice text, or null.
	var/current_notice
	/// The preamble html that includes all styling and layout.
	var/title_html
	/// The list of possible title screens to rotate through, as file path texts.
	var/title_screens = list()

/datum/controller/subsystem/title/Initialize()
	if(!fexists("config/title_html.txt"))
		error(span_boldwarning("Unable to read title_html.txt, reverting to backup title html, please check your server config and ensure this file exists."))
		title_html = DEFAULT_TITLE_HTML
	else
		title_html = file2text("config/title_html.txt")

	var/list/local_title_screens = list()
	for(var/screen in flist(TITLE_SCREENS_LOCATION))
		var/list/screen_name_parts = splittext(screen, "+")
		if((LAZYLEN(screen_name_parts) == 1 && (screen_name_parts[1] != "exclude" && screen_name_parts[1] != "blank.png")))
			local_title_screens += screen

	for(var/title_screen in local_title_screens)
		var/file_path = "[TITLE_SCREENS_LOCATION][title_screen]"
		ASSERT(fexists(file_path))
		title_screens += fcopy_rsc(file_path)

	change_title_screen()

/datum/controller/subsystem/title/Recover()
	current_title_screen = SStitle.current_title_screen
	current_notice = SStitle.current_notice
	title_html = SStitle.title_html
	title_screens = SStitle.title_screens

/**
 * Show the title screen to all new players.
 */
/datum/controller/subsystem/title/proc/show_title_screen()
	for(var/mob/new_player/new_player in GLOB.player_list)
		INVOKE_ASYNC(new_player, TYPE_PROC_REF(/mob/new_player, show_title_screen))

/**
 * Adds a notice to the main title screen in the form of big red text!
 */
/datum/controller/subsystem/title/proc/set_notice(new_title)
	current_notice = new_title ? sanitize_text(new_title) : null
	show_title_screen()

/**
 * Changes the title screen to a new image.
 */
/datum/controller/subsystem/title/proc/change_title_screen(new_screen)
	if(new_screen)
		current_title_screen = new_screen
	else
		if(LAZYLEN(title_screens))
			current_title_screen = pick(title_screens)
		else
			current_title_screen = DEFAULT_TITLE_SCREEN_IMAGE

	show_title_screen()

#undef TITLE_SCREENS_LOCATION
