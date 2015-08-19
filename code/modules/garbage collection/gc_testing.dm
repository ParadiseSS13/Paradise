// Garbage collection testing/debugging/profiling code

/client/proc/qdel_toggle()
	set name = "(GC) Toggle Queueing"
	set desc = "Toggle qdel usage between normal and force del()."
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	garbageCollector.del_everything = !garbageCollector.del_everything
	// world << "<b>GC: qdel turned [garbageCollector.del_everything ? "off" : "on"].</b>"
	log_admin("[key_name(usr)] turned qdel [garbageCollector.del_everything ? "off" : "on"].")
	message_admins("\blue [key_name_admin(usr)] turned qdel [garbageCollector.del_everything ? "off" : "on"].", 1)

/client/proc/gc_toggle_profiling()
	set name = "(GC) Toggle Profiling"
	set desc = "Toggle profiling of deletion methods"
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	del_profiling = !del_profiling
	log_admin("[key_name(usr)] turned deletion profiling [del_profiling ? "on" : "off"].")
	message_admins("\blue [key_name_admin(usr)] turned deletion profiling [del_profiling ? "on" : "off"].", 1)

/client/proc/gc_show_del_report()
	set name = "(GC) Show Del Report"
	set desc = "Show report of deletions seen while profiling"
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	delete_profiler_report()

/client/proc/gc_dump_hdl()
	set name = "(GC) Hard Del List"
	set desc = "List types that are hard del()'d by the GC."
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	if(!gc_hard_del_types || !gc_hard_del_types.len)
		usr << "<span class='notice'>No hard del()'d types found.</span>"
		return

	usr << "Types hard del()'d by the GC:"
	for(var/A in gc_hard_del_types)
	 usr << "[A]"

// Profiling stuff
var/global/del_profiling = 0
var/global/list/dels_profiled = list()
var/global/list/gdels_profiled = list()
var/global/list/ghdels_profiled = list()

/proc/delete_profile(var/datum/D)
	if(!ticker || (ticker.current_state < 3)) return
	var/code = 0
	var/type = D.type
	if(isnull(D.gcDestroyed))
		code = 0
	else if(D.hard_deleted == -1)
		code = 0 // A non-queued hard deletion is counted as a straight deletion
	else if(D.hard_deleted)
		code = 1
	else
		code = 2
	switch(code)
		if(0) // Directly deleted (skipped the GC queue entirely)
			if (!("[type]" in dels_profiled))
				dels_profiled["[type]"] = 0

			dels_profiled["[type]"] += 1
		if(1) // Hard-deleted by the GC
			if (!("[type]" in ghdels_profiled))
				ghdels_profiled["[type]"] = 0

			ghdels_profiled["[type]"] += 1
		if(2) // qdel'd and garbage collected by BYOND
			if (!("[type]" in gdels_profiled))
				gdels_profiled["[type]"] = 0

			gdels_profiled["[type]"] += 1

/proc/delete_profiler_report()
	var/dat = "<html><head><title>Deletion Profiler Report</title></head>"
	if(dels_profiled.len + gdels_profiled.len + ghdels_profiled.len)
		dat += "<a href='#DD'>Direct Deletions</a><br />"
		dat += "<a href='#SD'>GC Soft Deletions</a><br />"
		dat += "<a href='#HD'>GC Hard Deletions</a><br />"
		dat += delete_profiler_sortedlist(dels_profiled, "Direct Deletions", "DD")
		dat += delete_profiler_sortedlist(gdels_profiled, "GC Soft Deletions", "SD")
		dat += delete_profiler_sortedlist(ghdels_profiled, "GC Hard Deletions", "HD")
	else
		dat += "(No deletions profiled; listing types that have been hard-deleted by GC)<br />"
		dat += "<table border='1'><tr><th>GC Hard Deletion Types</th></tr>"
		for(var/A in gc_hard_del_types)
			dat += "<tr><td>[A]</td></tr>"
		dat += "</table>"
	usr << browse(dat, "window=delete_profiler_report;size=600x480")

/proc/delete_profiler_sortedlist(var/list/L, var/header, var/anchorid)
	L = L.Copy()
	// Yes, this is a terrible sort, but I'm too lazy to find a good one
	var/v,i,j,s
	for(i = 1 to L.len-1)
		s=i
		v = L[L[i]]
		for(j = i + 1 to L.len)
			if(L[L[j]] > v)
				s = j
				v = L[L[j]]
		L.Swap(i,s)

	var/dat = "<table border='1' id='[anchorid]'><tr><th colspan='2'>[header]</th></tr>"
	for (var/t in L)
		dat +="<tr><td>[L[t]]</td><td>[t]</td></tr>"
	dat += "</table>"
	return dat

/*/client/var/running_find_references

/atom/verb/find_references()
	set category = "Debug"
	set name = "Find References"
	set background = 1
	set src in world

	if(!usr || !usr.client)
		return

	if(usr.client.running_find_references)
		testing("CANCELLED search for references to a [usr.client.running_find_references].")
		usr.client.running_find_references = null
		return

	if(alert("Running this will create a lot of lag until it finishes.	You can cancel it by running it again.	Would you like to begin the search?", "Find References", "Yes", "No") == "No")
		return
	qdel(src)
	// Remove this object from the list of things to be auto-deleted.
	if(garbageCollector)
		garbageCollector.queue -= "\ref[src]"

	usr.client.running_find_references = type
	testing("Beginning search for references to a [type].")
	var/list/things = list()
	for(var/client/thing)
		things += thing
	for(var/datum/thing)
		things += thing
	for(var/atom/thing)
		things += thing
	for(var/event/thing)
		things += thing
	testing("Collected list of things in search for references to a [type]. ([things.len] Thing\s)")
	for(var/datum/thing in things)
		if(!usr.client.running_find_references) return
		for(var/varname in thing.vars)
			var/variable = thing.vars[varname]
			if(variable == src)
				testing("Found [src.type] \ref[src] in [thing.type]'s [varname] var.")
			else if(islist(variable))
				if(src in variable)
					testing("Found [src.type] \ref[src] in [thing.type]'s [varname] list var.")
	testing("Completed search for references to a [type].")
	usr.client.running_find_references = null
*/