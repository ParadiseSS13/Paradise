/*
TGUI MODULES

This allows for datum-based TGUIs that can be hooked into objects.
This is useful for things such as the power monitor, which needs to exist on a physical console in the world, but also as a virtual device the AI can use

Code is pretty much ripped verbatim from nano modules, but with un-needed stuff removed
*/
/datum/tgui_module
	var/name
	var/datum/host

/datum/tgui_module/New(var/host)
	src.host = host

/datum/tgui_module/tgui_host()
	return host ? host : src

/datum/tgui_module/tgui_close(mob/user)
	if(host)
		host.tgui_close(user)
