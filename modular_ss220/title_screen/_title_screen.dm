/datum/modpack/title_screen
	name = "Title Screen"
	desc = "Заменяет изображение в лобби настоящей картинкой, а не объектом в мире игры."
	author = "larentoun"

/datum/modpack/title_screen/initialize()
	GLOB.admin_verbs_event |= list(
		/client/proc/admin_change_title_screen,
		/client/proc/change_title_screen_html,
		/client/proc/change_title_screen_notice)
