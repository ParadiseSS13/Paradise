/*
UI MODULES

This allows for datum-based UIs that can be hooked into objects.
This is useful for things such as the power monitor, which needs to exist on a physical console in the world, but also as a virtual device the AI can use

Code is pretty much ripped verbatim from nano modules, but with un-needed stuff removed
*/
/datum/ui_module
	var/name
	var/datum/host

/datum/ui_module/New(datum/_host)
	host = _host

/datum/ui_module/ui_host()
	return host ? host : src

/datum/ui_module/ui_close(mob/user)
	if(host)
		host.ui_close(user)
