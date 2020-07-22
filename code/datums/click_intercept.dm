/datum/click_intercept
	var/client/holder = null
	var/list/obj/screen/buttons = list()

/datum/click_intercept/New(client/C)
	create_buttons()
	enter(C)
	return ..()

/datum/click_intercept/Destroy()
	holder.screen -= buttons
	holder.click_intercept = null
	holder.show_popup_menus = TRUE
	holder = null
	QDEL_LIST(buttons)
	return ..()

/datum/click_intercept/proc/enter(client/C)
	holder = C
	holder.click_intercept = src
	holder.show_popup_menus = FALSE
	holder.screen += buttons

/datum/click_intercept/proc/quit()
	qdel(src)

/datum/click_intercept/proc/create_buttons()
	return

/datum/click_intercept/proc/InterceptClickOn(user,params,atom/object)
	return