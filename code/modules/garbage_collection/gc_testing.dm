// Garbage collection testing/debugging/profiling code

/client/proc/qdel_toggle()
	set name = "(GC) Toggle Queueing"
	set desc = "Toggle qdel usage between normal and force del()."
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	garbageCollector.del_everything = !garbageCollector.del_everything
//	to_chat(world, "<b>GC: qdel turned [garbageCollector.del_everything ? "off" : "on"].</b>")
	log_admin("[key_name(usr)] turned qdel [garbageCollector.del_everything ? "off" : "on"].")
	message_admins("\blue [key_name_admin(usr)] turned qdel [garbageCollector.del_everything ? "off" : "on"].", 1)

/client/proc/gc_dump_hdl()
	set name = "(GC) Hard Del List"
	set desc = "List types that are hard del()'d by the GC."
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	if(!gc_hard_del_types || !gc_hard_del_types.len)
		to_chat(usr, "<span class='notice'>No hard del()'d types found.</span>")
		return

	to_chat(usr, "Types hard del()'d by the GC:")
	for(var/A in gc_hard_del_types)
		to_chat(usr, "[A]")

#ifdef TESTING
/client/var/running_find_references
/datum/var/running_find_references

/datum/verb/find_references(remove_from_queue = TRUE as num)
	set category = "Debug"
	set name = "Find References"
	set background = 1
	set src in world

	running_find_references = type
	if(usr && usr.client)
		if(usr.client.running_find_references)
			testing("CANCELLED search for references to a [usr.client.running_find_references].")
			usr.client.running_find_references = null
			running_find_references = null
			return

		if(alert("Running this will create a lot of lag until it finishes.  You can cancel it by running it again.  Would you like to begin the search?", "Find References", "Yes", "No") == "No")
			running_find_references = null
			return
	// Remove this object from the list of things to be auto-deleted.
	if(remove_from_queue && garbageCollector && ("\ref[src]" in garbageCollector.queue))
		garbageCollector.queue -= "\ref[src]"
	if(usr && usr.client)
		usr.client.running_find_references = type

	testing("Beginning search for references to a [type].")
	var/list/things = list()
	for(var/client/thing)
		things |= thing
	for(var/datum/thing)
		things |= thing
	testing("Collected list of things in search for references to a [type]. ([things.len] Thing\s)")
	for(var/datum/thing in things)
		if(usr && usr.client && !usr.client.running_find_references) return
		for(var/varname in thing.vars)
			var/variable = thing.vars[varname]
			if(variable == src)
				testing("Found [src.type] \ref[src] in [thing.type]'s [varname] var.")
			else if(islist(variable))
				if(src in variable)
					testing("Found [src.type] \ref[src] in [thing.type]'s [varname] list var.")
	testing("Completed search for references to a [type].")
	if(usr && usr.client)
		usr.client.running_find_references = null
	running_find_references = null

/client/verb/purge_all_destroyed_objects()
	set category = "Debug"
	if(garbageCollector)
		while(garbageCollector.queue.len)
			var/datum/o = locate(garbageCollector.queue[1])
			if(istype(o) && !isnull(o.gcDestroyed))
				del(o)
				garbageCollector.dels_count++
			garbageCollector.queue.Cut(1, 2)

/datum/verb/qdel_then_find_references()
	set category = "Debug"
	set name = "qdel() then Find References"
	set background = 1
	set src in world

	qdel(src)
	if(!running_find_references)
		find_references(remove_from_queue = FALSE)
#endif
