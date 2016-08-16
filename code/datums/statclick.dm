// Not TECHNICALLY a datum, but this should never be instantiated
// outside of the stat panel
// Clickable stat() button
/obj/effect/statclick
	var/target

/obj/effect/statclick/New(ntarget, text)
	name = text
	target = ntarget

/obj/effect/statclick/proc/update(text)
	name = text
	return src

/obj/effect/statclick/debug
	var/class

/obj/effect/statclick/debug/New(ntarget)
	name = "Initializing..."
	target = ntarget
	if(istype(target, /datum/controller/process))
		class = "process"
	else if(istype(target, /datum/controller/processScheduler))
		class = "scheduler"
	else if(istype(target, /datum/controller))
		class = "controller"
	else if(istype(target, /datum))
		class = "datum"
	else
		class = "unknown"

// This bit is called when clicked in the stat panel
/obj/effect/statclick/debug/Click()
	if(!usr.client.holder)
		return

	usr.client.debug_variables(target)

	message_admins("Admin [key_name_admin(usr)] is debugging the [target] [class].")
