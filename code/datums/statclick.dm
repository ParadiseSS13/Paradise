// Not TECHNICALLY a datum, but this should never be instantiated
// outside of the stat panel
// Clickable stat() button
/obj/effect/statclick
	var/target

/obj/effect/statclick/New(ntarget, text)
	target = ntarget
	name = text

/obj/effect/statclick/proc/update(text)
	name = text
	return src

/obj/effect/statclick/debug
	var/class

/obj/effect/statclick/debug/Click()
	if(!is_admin(usr) || !target)
		return
	if(!class)
		if(istype(target, /datum/controller/process))
			class = "process"
		else if(istype(target, /datum/controller/processScheduler))
			class = "scheduler"
		if(istype(target, /datum/controller/subsystem))
			class = "subsystem"
		else if(istype(target, /datum/controller))
			class = "controller"
		else if(istype(target, /datum))
			class = "datum"
		else
			class = "unknown"

	usr.client.debug_variables(target)
	message_admins("Admin [key_name_admin(usr)] is debugging the [target] [class].")