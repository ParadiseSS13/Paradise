USER_VERB(advanced_proccall, R_PROCCALL, "Advanced ProcCall", "Advanced ProcCall", VERB_CATEGORY_DEBUG)
	spawn(0)
		var/target = null
		var/targetselected = 0
		var/returnval = null
		var/class = null

		switch(alert(client, "Proc owned by something?", null,"Yes","No"))
			if("Yes")
				targetselected = 1
				if(client.holder && client.holder.marked_datum)
					class = input(client, "Proc owned by...","Owner",null) as null|anything in list("Obj","Mob","Area or Turf","Client","Marked datum ([client.holder.marked_datum.type])")
					if(class == "Marked datum ([client.holder.marked_datum.type])")
						class = "Marked datum"
				else
					class = input(client, "Proc owned by...","Owner",null) as null|anything in list("Obj","Mob","Area or Turf","Client")
				switch(class)
					if("Obj")
						target = input(client, "Enter target:","Target",usr) as obj in world
					if("Mob")
						target = input(client, "Enter target:","Target",usr) as mob in world
					if("Area or Turf")
						target = input(client, "Enter target:","Target",usr.loc) as area|turf in world
					if("Client")
						var/list/keys = list()
						for(var/client/C)
							keys += C
						target = input(client, "Please, select a player!", "Selection", null) as null|anything in keys
					if("Marked datum")
						target = client.holder.marked_datum
					else
						return
			if("No")
				target = null
				targetselected = 0

		var/procname = clean_input("Proc path, eg: /proc/fake_blood","Path:", null, user = client)
		if(!procname)	return

		// absolutely not
		if(findtextEx(trim(lowertext(procname)), "rustg"))
			message_admins(SPAN_USERDANGER("[key_name_admin(client)] attempted to proc call rust-g procs. Inform the host <u>at once</u>."))
			log_admin("[key_name(client)] attempted to proc call rust-g procs. Inform the host at once.")
			GLOB.discord_manager.send2discord_simple(DISCORD_WEBHOOK_ADMIN, "[key_name(client)] attempted to proc call rustg things. Inform the host at once.")
			return

		if(targetselected && !hascall(target,procname))
			to_chat(client, "<font color='red'>Error: callproc(): target has no such call [procname].</font>")
			return

		var/list/lst = client.get_callproc_args()
		if(!lst)
			return

		if(targetselected)
			if(!target)
				to_chat(client, "<font color='red'>Error: callproc(): owner of proc no longer exists.</font>")
				return
			message_admins("[key_name_admin(client)] called [target]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]":"no arguments"].")
			log_admin("[key_name(client)] called [target]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = WrapAdminProcCall(target, procname, lst) // Pass the lst as an argument list to the proc
		else
			//this currently has no hascall protection. wasn't able to get it working.
			message_admins("[key_name_admin(client)] called [procname]() with [length(lst) ? "the arguments [list2params(lst)]":"no arguments"]")
			log_admin("[key_name(client)] called [procname]() with [length(lst) ? "the arguments [list2params(lst)]":"no arguments"]")
			returnval = WrapAdminProcCall(GLOBAL_PROC, procname, lst) // Pass the lst as an argument list to the proc

		to_chat(client, "<font color='#EB4E00'>[procname] returned: [!isnull(returnval) ? returnval : "null"]</font>")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Advanced Proc-Call") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

// All these vars are related to proc call protection
// If you add more of these, for the love of fuck, protect them

/// Who is currently calling procs
GLOBAL_VAR(AdminProcCaller)
GLOBAL_PROTECT(AdminProcCaller)
/// How many procs have been called
GLOBAL_VAR_INIT(AdminProcCallCount, 0)
GLOBAL_PROTECT(AdminProcCallCount)
/// UID of the admin who last called
GLOBAL_VAR(LastAdminCalledTargetUID)
GLOBAL_PROTECT(LastAdminCalledTargetUID)
/// Last target to have a proc called on it
GLOBAL_VAR(LastAdminCalledTarget)
GLOBAL_PROTECT(LastAdminCalledTarget)
/// Last proc called
GLOBAL_VAR(LastAdminCalledProc)
GLOBAL_PROTECT(LastAdminCalledProc)
/// List to handle proc call spam prevention
GLOBAL_LIST_EMPTY(AdminProcCallSpamPrevention)
GLOBAL_PROTECT(AdminProcCallSpamPrevention)


// Wrapper for proccalls where the datum is flagged as vareditted
/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target && procname == "Del")
		to_chat(usr, "Calling Del() is not allowed")
		return

	if(target != GLOBAL_PROC && !target.CanProcCall(procname))
		to_chat(usr, "Proccall on [target.type]/proc/[procname] is disallowed!")
		return
	var/current_caller = GLOB.AdminProcCaller
	var/ckey = usr ? usr.client.ckey : GLOB.AdminProcCaller
	if(!ckey)
		CRASH("WrapAdminProcCall with no ckey: [target] [procname] [english_list(arguments)]")
	if(current_caller && current_caller != ckey)
		if(!GLOB.AdminProcCallSpamPrevention[ckey])
			to_chat(usr, SPAN_USERDANGER("Another set of admin called procs are still running, your proc will be run after theirs finish."))
			GLOB.AdminProcCallSpamPrevention[ckey] = TRUE
			UNTIL(!GLOB.AdminProcCaller)
			to_chat(usr, SPAN_USERDANGER("Running your proc"))
			GLOB.AdminProcCallSpamPrevention -= ckey
		else
			UNTIL(!GLOB.AdminProcCaller)
	GLOB.LastAdminCalledProc = procname
	if(target != GLOBAL_PROC)
		GLOB.LastAdminCalledTargetUID = target.UID()
	GLOB.AdminProcCaller = ckey	//if this runtimes, too bad for you
	++GLOB.AdminProcCallCount
	try
		. = world.WrapAdminProcCall(target, procname, arguments)
	catch(var/exception/e)
		to_chat(usr, SPAN_USERDANGER("Your proc call failed to execute, likely from runtimes. You <i>should</i> be out of safety mode. If not, god help you. Runtime Info: [e.file]:[e.line]: [e.name]"))

	if(--GLOB.AdminProcCallCount == 0)
		GLOB.AdminProcCaller = null

//adv proc call this, ya nerds
/world/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target == GLOBAL_PROC)
		return call("/proc/[procname]")(arglist(arguments))
	else if(target != world)
		return call(target, procname)(arglist(arguments))
	else
		to_chat(usr, SPAN_BOLDANNOUNCEOOC("Call to world/proc/[procname] blocked: Advanced ProcCall detected."))
		message_admins("[key_name(usr)] attempted to call world/proc/[procname] with arguments: [english_list(arguments)]")
		log_admin("[key_name(usr)] attempted to call world/proc/[procname] with arguments: [english_list(arguments)]l")

/proc/IsAdminAdvancedProcCall()
#ifdef TESTING
	return FALSE
#else
	return usr && usr.client && GLOB.AdminProcCaller == usr.client.ckey
#endif

USER_CONTEXT_MENU(call_proc_datum, R_PROCCALL, "\[Admin\] Atom ProcCall", datum/A as null|area|mob|obj|turf)
	if(istype(A, /datum/logging) || istype(A, /datum/log_record))
		message_admins(SPAN_USERDANGER("[key_name_admin(client)] attempted to proc call on a logging object. Inform the host <u>at once</u>."))
		log_admin("[key_name(client)] attempted to proc call on a logging object. Inform the host at once.")
		GLOB.discord_manager.send2discord_simple(DISCORD_WEBHOOK_ADMIN, "[key_name(client)] attempted to proc call on a logging object. Inform the host at once.")
		return

	var/procname = clean_input("Proc name, eg: fake_blood","Proc:", null, user = client)
	if(!procname)
		return

	if(!hascall(A,procname))
		to_chat(client, SPAN_WARNING("Error: callproc_datum(): target has no such call [procname]."))
		return

	var/list/lst = client.get_callproc_args()
	if(!lst)
		return

	if(!A || !IsValidSrc(A))
		to_chat(client, SPAN_WARNING("Error: callproc_datum(): owner of proc no longer exists."))
		return
	message_admins("[key_name_admin(client)] called [A]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]":"no arguments"]")
	log_admin("[key_name(client)] called [A]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]":"no arguments"]")

	spawn()
		var/returnval = WrapAdminProcCall(A, procname, lst) // Pass the lst as an argument list to the proc
		to_chat(client, SPAN_NOTICE("[procname] returned: [!isnull(returnval) ? returnval : "null"]"))

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Atom Proc-Call") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/get_callproc_args()
	var/argnum = input("Number of arguments","Number:",0) as num|null
	if(argnum <= 0)
		return list() // to allow for calling with 0 args

	argnum = clamp(argnum, 1, 50)

	var/list/lst = list()
	//TODO: make a list to store whether each argument was initialised as null.
	//Reason: So we can abort the proccall if say, one of our arguments was a mob which no longer exists
	//this will protect us from a fair few errors ~Carn

	while(argnum--)
		var/list/value = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
		var/class = value["class"]
		if(!class)
			return null

		lst += value["value"]
	return lst

USER_VERB_VISIBILITY(air_status, VERB_VISIBILITY_FLAG_MOREDEBUG)
USER_VERB(air_status, R_DEBUG, "Air Status in Location", "Print out the local air contents.", VERB_CATEGORY_DEBUG)
	if(!client.mob)
		return
	var/turf/T = client.mob.loc

	if(!isturf(T))
		return

	var/datum/gas_mixture/env = T.get_readonly_air()

	var/t = ""
	t+= "Nitrogen : [env.nitrogen()]\n"
	t+= "Oxygen : [env.oxygen()]\n"
	t+= "Plasma : [env.toxins()]\n"
	t+= "CO2: [env.carbon_dioxide()]\n"

	usr.show_message(t, 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Air Status (Location)") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(delete_singulo, R_DEBUG, "Del Singulo / Tesla", "Delete all singularities and tesla balls.", VERB_CATEGORY_DEBUG)
	//This gets a confirmation check because it's way easier to accidentally hit this and delete things than it is with qdel-all
	var/confirm = alert(client, "This will delete ALL Singularities and Tesla orbs except for any that are on away mission z-levels or the centcomm z-level. Are you sure you want to delete them?", "Confirm Panic Button", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/I in GLOB.singularities)
		var/obj/singularity/S = I
		if(!is_level_reachable(S.z))
			continue
		qdel(S)
	log_admin("[key_name(client)] has deleted all Singularities and Tesla orbs.")
	message_admins("[key_name_admin(client)] has deleted all Singularities and Tesla orbs.", 0)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Del Singulo/Tesla") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(make_powernets, R_DEBUG, "Make Powernets", "Remake all powernets.", VERB_CATEGORY_DEBUG)
	SSmachines.makepowernets()
	log_admin("[key_name(client)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(client)] has remade the powernets. makepowernets() called.", 0)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Powernets") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB_VISIBILITY(assume_direct_control, VERB_VISIBILITY_FLAG_MOREDEBUG)
USER_VERB(assume_direct_control, R_ADMIN|R_DEBUG, "Assume direct control", "Direct intervention", VERB_CATEGORY_ADMIN, mob/M in GLOB.mob_list)
	if(M.ckey)
		if(alert(client, "This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.", null,"Yes","No") != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			ghost.ckey = M.ckey
	message_admins(SPAN_NOTICE("[key_name_admin(client)] assumed direct control of [M]."), 1)
	log_admin("[key_name(client)] assumed direct control of [M].")
	var/mob/adminmob = client.mob
	M.ckey = client.ckey
	if(isobserver(adminmob))
		qdel(adminmob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Assume Direct Control") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB_VISIBILITY(mapping_area_test, VERB_VISIBILITY_FLAG_MOREDEBUG)
USER_VERB(mapping_area_test, R_DEBUG, "Test areas", "Run mapping area test", VERB_CATEGORY_MAPPING)
	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()

	var/list/areas_with_multiple_APCs = list()
	var/list/areas_with_multiple_air_alarms = list()

	for(var/area/A in world)
		areas_all |= A.type

	for(var/thing in GLOB.apcs)
		var/obj/machinery/power/apc/APC = thing
		var/area/A = get_area(APC)
		if(!A)
			continue
		if(!(A.type in areas_with_APC))
			areas_with_APC |= A.type
		else
			areas_with_multiple_APCs |= A.type

	for(var/thing in GLOB.air_alarms)
		var/obj/machinery/alarm/alarm = thing
		var/area/A = get_area(alarm)
		if(!A)
			continue
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm |= A.type
		else
			areas_with_multiple_air_alarms |= A.type

	for(var/obj/machinery/requests_console/RC in SSmachines.get_by_type(/obj/machinery/requests_console))
		var/area/A = get_area(RC)
		if(!A)
			continue
		areas_with_RC |= A.type

	for(var/obj/machinery/light/L in SSmachines.get_by_type(/obj/machinery/light))
		var/area/A = get_area(L)
		if(!A)
			continue
		areas_with_light |= A.type

	for(var/obj/machinery/light_switch/LS in SSmachines.get_by_type(/obj/machinery/light_switch))
		var/area/A = get_area(LS)
		if(!A)
			continue
		areas_with_LS |= A.type

	for(var/obj/item/radio/intercom/I in SSmachines.get_by_type(/obj/item/radio/intercom))
		var/area/A = get_area(I)
		if(!A)
			continue
		areas_with_intercom |= A.type

	for(var/obj/machinery/camera/C in SSmachines.get_by_type(/obj/machinery/camera))
		var/area/A = get_area(C)
		if(!A)
			continue
		areas_with_camera |= A.type

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	to_chat(world, "<b>AREAS WITHOUT AN APC:</b>")
	for(var/areatype in areas_without_APC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT AN AIR ALARM:</b>")
	for(var/areatype in areas_without_air_alarm)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITH TOO MANY APCS:</b>")
	for(var/areatype in areas_with_multiple_APCs)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITH TOO MANY AIR ALARMS:</b>")
	for(var/areatype in areas_with_multiple_air_alarms)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A REQUEST CONSOLE:</b>")
	for(var/areatype in areas_without_RC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY LIGHTS:</b>")
	for(var/areatype in areas_without_light)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A LIGHT SWITCH:</b>")
	for(var/areatype in areas_without_LS)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY INTERCOMS:</b>")
	for(var/areatype in areas_without_intercom)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY CAMERAS:</b>")
	for(var/areatype in areas_without_camera)
		to_chat(world, "* [areatype]")

/client/proc/robust_dress_shop(list/potential_minds)
	var/list/special_outfits = list(
		"Naked",
		"As Job...",
		"Custom..."
	)
	if(length(potential_minds))
		special_outfits += "Recover destroyed body..."

	var/list/outfits = list()
	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job) - list(/datum/outfit/varedit, /datum/outfit/admin)
	for(var/path in paths)
		var/datum/outfit/O = path //not much to initalize here but whatever
		if(initial(O.can_be_admin_equipped))
			outfits[initial(O.name)] = path
	outfits = special_outfits + sortTim(outfits, GLOBAL_PROC_REF(cmp_text_asc))

	var/dresscode = input("Select outfit", "Robust quick dress shop") as null|anything in outfits
	if(isnull(dresscode))
		return

	if(outfits[dresscode])
		dresscode = outfits[dresscode]

	if(dresscode == "As Job...")
		var/list/job_paths = subtypesof(/datum/outfit/job)
		var/list/job_outfits = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				job_outfits[initial(O.name)] = path
		job_outfits = sortTim(job_outfits, GLOBAL_PROC_REF(cmp_text_asc))

		dresscode = input("Select job equipment", "Robust quick dress shop") as null|anything in job_outfits
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	if(dresscode == "Custom...")
		var/list/custom_names = list()
		for(var/datum/outfit/D in GLOB.custom_outfits)
			custom_names[D.name] = D
		var/selected_name = input("Select outfit", "Robust quick dress shop") as null|anything in custom_names
		dresscode = custom_names[selected_name]
		if(isnull(dresscode))
			return

	if(dresscode == "Recover destroyed body...")
		dresscode = input("Select body to rebuild", "Robust quick dress shop") as null|anything in potential_minds

	return dresscode

USER_VERB_VISIBILITY(start_singulo, VERB_VISIBILITY_FLAG_MOREDEBUG)
USER_VERB(start_singulo, R_DEBUG, "Start Singularity", "Sets up the singularity and all machines to get power flowing through the station", VERB_CATEGORY_DEBUG)
	if(alert(client, "Are you sure? This will start up the engine. Should only be used during debug!", null,"Yes","No") != "Yes")
		return

	for(var/obj/machinery/power/emitter/E in SSmachines.get_by_type(/obj/machinery/power/emitter))
		if(E.anchored)
			E.active = TRUE

	for(var/obj/machinery/field/generator/F in SSmachines.get_by_type(/obj/machinery/field/generator))
		if(!F.active)
			F.active = TRUE
			F.state = 2
			F.energy = 125
			F.anchored = TRUE
			F.warming_up = 3
			F.start_fields()
			F.update_icon()

	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in SSmachines.get_by_type(/obj/machinery/the_singularitygen))
			if(G.anchored)
				var/obj/singularity/S = new /obj/singularity(get_turf(G))
				S.energy = 800
				break

	for(var/obj/machinery/power/rad_collector/Rad in SSmachines.get_by_type(/obj/machinery/power/rad_collector))
		if(Rad.anchored)
			if(!Rad.loaded_tank)
				var/obj/item/tank/internals/plasma/Plasma = new/obj/item/tank/internals/plasma(Rad)
				Plasma.air_contents.set_toxins(70)
				Rad.drainratio = 0
				Rad.loaded_tank = Plasma
				Plasma.loc = Rad

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in SSmachines.get_by_type(/obj/machinery/power/smes))
		if(SMES.anchored)
			SMES.input_attempt = 1

USER_VERB(debug_mob_lists, R_DEBUG, "Debug Mob Lists", "For when you just gotta know", VERB_CATEGORY_DEBUG)
	switch(input(client, "Which list?") in list("Players", "Admins", "Mobs", "Living Mobs", "Alive Mobs", "Dead Mobs", "Silicons", "Clients", "Respawnable Mobs"))
		if("Players")
			to_chat(client, jointext(GLOB.player_list, ","))
		if("Admins")
			to_chat(client, jointext(GLOB.admins, ","))
		if("Mobs")
			to_chat(client, jointext(GLOB.mob_list, ","))
		if("Living Mobs")
			to_chat(client, jointext(GLOB.mob_living_list, ","))
		if("Alive Mobs")
			to_chat(client, jointext(GLOB.alive_mob_list, ","))
		if("Dead Mobs")
			to_chat(client, jointext(GLOB.dead_mob_list, ","))
		if("Silicons")
			to_chat(client, jointext(GLOB.silicon_mob_list, ","))
		if("Clients")
			to_chat(client, jointext(GLOB.clients, ","))
		if("Respawnable Mobs")
			var/list/respawnable_mobs
			for(var/mob/potential_respawnable in GLOB.player_list)
				if(HAS_TRAIT(potential_respawnable, TRAIT_RESPAWNABLE))
					respawnable_mobs += potential_respawnable
			to_chat(client, jointext(respawnable_mobs, ", "))

USER_VERB(display_del_log, R_DEBUG|R_VIEWRUNTIMES, "Display del() Log", "Display del's log of everything that's passed through it.", VERB_CATEGORY_DEBUG)
	var/list/dellog = list("<B>List of things that have gone through qdel this round</B><BR><BR><ol>")
	sortTim(SSgarbage.items, GLOBAL_PROC_REF(cmp_qdel_item_time), TRUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		dellog += "<li><u>[path]</u><ul>"
		if(I.failures)
			dellog += "<li>Failures: [I.failures]</li>"
		dellog += "<li>qdel() Count: [I.qdels]</li>"
		dellog += "<li>Destroy() Cost: [I.destroy_time]ms</li>"
		if(I.hard_deletes)
			dellog += "<li>Total Hard Deletes [I.hard_deletes]</li>"
			dellog += "<li>Time Spent Hard Deleting: [I.hard_delete_time]ms</li>"
			dellog += "<li>Average References During Hardel: [I.reference_average] references.</li>"
		if(I.slept_destroy)
			dellog += "<li>Sleeps: [I.slept_destroy]</li>"
		if(I.no_respect_force)
			dellog += "<li>Ignored force: [I.no_respect_force]</li>"
		if(I.no_hint)
			dellog += "<li>No hint: [I.no_hint]</li>"
		dellog += "</ul></li>"

	dellog += "</ol>"

	client << browse(dellog.Join(), "window=dellog")

USER_VERB(display_del_log_simple, R_DEBUG|R_VIEWRUNTIMES, "Display Simple del() Log", \
		"Display a compacted del's log.", VERB_CATEGORY_DEBUG)
	var/dat = "<B>List of things that failed to GC this round</B><BR><BR>"
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		if(I.failures)
			dat += "[I] - [I.failures] times<BR>"

	dat += "<B>List of paths that did not return a qdel hint in Destroy()</B><BR><BR>"
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		if(I.no_hint)
			dat += "[I]<BR>"

	dat += "<B>List of paths that slept in Destroy()</B><BR><BR>"
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		if(I.slept_destroy)
			dat += "[I]<BR>"

	client << browse(dat, "window=simpledellog")

USER_VERB(show_gc_queues, R_DEBUG|R_VIEWRUNTIMES, "View GC Queue", \
		"Shows the list of whats currently in a GC queue", VERB_CATEGORY_DEBUG)
	// Get the amount of queues
	var/queue_count = length(SSgarbage.queues)
	var/list/selectable_queues = list()
	// Setup choices
	for(var/i in 1 to queue_count)
		selectable_queues["Queue #[i] ([length(SSgarbage.queues[i])] item\s)"] = i

	// Ask the user
	var/choice = input(client, "Select a GC queue. Note that the queue lookup may lag the server.", "GC Queue") as null|anything in selectable_queues
	if(!choice)
		return

	// Get our target
	var/list/target_queue = SSgarbage.queues[selectable_queues[choice]]
	var/list/queue_counts = list()

	// Iterate that target and see whats what
	for(var/queue_entry in target_queue)
		var/datum/D = locate(queue_entry[GC_QUEUE_ITEM_REF])
		if(!istype(D))
			continue

		if(!queue_counts[D.type])
			queue_counts[D.type] = 0

		queue_counts[D.type]++

	// Sort it the right way
	var/list/sorted = sortTim(queue_counts, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)

	// And make a nice little menu
	var/list/text = list("<h1>Current status of [choice]</h1>", "<ul>")
	for(var/key in sorted)
		text += "<li>[key] - [sorted[key]]</li>"

	text += "</ul>"
	client << browse(text.Join(), "window=gcqueuestatus")

/client/proc/cmd_admin_toggle_block(mob/M, block)
	if(!check_rights(R_SPAWN))
		return

	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		M.dna.SetSEState(block,!M.dna.GetSEState(block))
		singlemutcheck(M, block, MUTCHK_FORCED)
		M.update_mutations()
		var/state = "[M.dna.GetSEState(block) ? "on" : "off"]"
		var/blockname = GLOB.assigned_blocks[block]
		message_admins("[key_name_admin(src)] has toggled [M.key]'s [blockname] block [state]!")
		log_admin("[key_name(src)] has toggled [M.key]'s [blockname] block [state]!")
	else
		alert("Invalid mob")

USER_VERB(view_runtimes, R_DEBUG|R_VIEWRUNTIMES, "View Runtimes", "Open the Runtime Viewer", VERB_CATEGORY_DEBUG)
	GLOB.error_cache.showTo(client)

USER_VERB(allow_browser_inspect, R_DEBUG, "Allow Browser Inspect", "Allow browser debugging via inspect", VERB_CATEGORY_DEBUG)
	if(client.byond_version < 516)
		to_chat(client, SPAN_WARNING("You can only use this on 516!"))
		return

	to_chat(client, SPAN_NOTICE("You can now right click to use inspect on browsers."))
	winset(client, "", "browser-options=byondstorage,find,devtools")

USER_VERB_VISIBILITY(debug_clean_radiation, VERB_VISIBILITY_FLAG_MOREDEBUG)
USER_VERB(debug_clean_radiation, R_DEBUG, "Remove All Radiation", "Remove all radiation in the world.", VERB_CATEGORY_DEBUG)
	if(alert(client, "Are you sure you want to remove all radiation in the world? This may lag the server. Alternatively, use the radiation cleaning buildmode.", "Lag warning", "Yes, I'm sure", "No, I want to live") != "Yes, I'm sure")
		return

	log_and_message_admins("is decontaminating the world of all radiation. (This may be laggy!)")

	var/counter = 0
	for(var/datum/component/radioactive/rad as anything in SSradiation.all_radiations)
		rad.admin_decontaminate()
		counter++
		CHECK_TICK

	log_and_message_admins_no_usr("The world has been decontaminated of [counter] radiation components.")

USER_VERB(view_bug_reports, R_DEBUG|R_VIEWRUNTIMES|R_ADMIN, "View Bug Reports", "Select a bug report to view", VERB_CATEGORY_DEBUG)
	if(!length(GLOB.bug_reports))
		to_chat(client, SPAN_WARNING("There are no bug reports to view"))
		return
	var/list/bug_report_selection = list()
	for(var/datum/tgui_bug_report_form/report in GLOB.bug_reports)
		bug_report_selection["[report.initial_key] - [report.bug_report_data["title"]]"] = report
	var/datum/tgui_bug_report_form/form = bug_report_selection[tgui_input_list(client, "Select a report to view:", "Bug Reports", bug_report_selection)]
	if(!form?.assign_approver(client.mob))
		return
	form.ui_interact(client.mob)

USER_VERB(debug_statpanel, R_DEBUG, "Debug Stat Panel", "Toggles local debug of the stat panel", VERB_CATEGORY_DEBUG)
	client.stat_panel.send_message("create_debug")

USER_VERB(profile_code, R_DEBUG|R_VIEWRUNTIMES, "Profile Code", "View code profiler", VERB_CATEGORY_DEBUG)
	winset(client, null, "command=.profile")

USER_VERB(raw_gas_scan, R_DEBUG|R_VIEWRUNTIMES, "Raw Gas Scan", "Scans your current tile, including LINDA data not normally displayed.", VERB_CATEGORY_DEBUG)
	atmos_scan(client.mob, get_turf(client.mob), silent = TRUE, milla_turf_details = TRUE)

USER_VERB(find_interesting_turf, R_DEBUG|R_VIEWRUNTIMES, "Interesting Turf", \
		"Teleports you to a random Interesting Turf from MILLA", VERB_CATEGORY_DEBUG)
	if(!isobserver(client.mob))
		to_chat(client.mob, SPAN_WARNING("You must be an observer to do this!"))
		return

	var/list/interesting_tile = get_random_interesting_tile()
	if(!length(interesting_tile))
		to_chat(client, SPAN_NOTICE("There are no interesting turfs. How interesting!"))
		return

	var/turf/T = interesting_tile[MILLA_INDEX_TURF]
	var/mob/dead/observer/O = client.mob
	admin_forcemove(O, T)
	O.manual_follow(T)

USER_VERB(visualize_interesting_turfs, R_DEBUG|R_VIEWRUNTIMES, "Visualize Interesting Turfs", "Shows all the Interesting Turfs from MILLA", VERB_CATEGORY_DEBUG)
	if(SSair.interesting_tile_count > 500)
		// This can potentially iterate through a list thats 20k things long. Give ample warning to the user
		if(tgui_alert(client, "WARNING: There are [SSair.interesting_tile_count] Interesting Turfs. This process will be lag intensive and should only be used if the atmos controller \
			is screaming bloody murder. Are you sure you with to continue", "WARNING", list("I am sure", "Nope")) != "I am sure")
			return
	else
		if(tgui_alert(client, "Visualizing turfs may cause server to lag. Are you sure?", "Warning", list("Yes", "No")) != "Yes")
			return

	var/display_turfs_overlay = FALSE
	if(tgui_alert(client, "Would you like to have all interesting turfs have a client side overlay applied as well?", "Optional", list("Yes", "No")) == "Yes")
		display_turfs_overlay = TRUE

	message_admins("[key_name_admin(client)] is visualizing interesting atmos turfs. Server may lag.")

	var/list/zlevel_turf_indexes = list()

	var/list/coords = get_interesting_atmos_tiles()
	if(!length(coords))
		to_chat(client, SPAN_NOTICE("There are no interesting turfs. How interesting!"))
		return

	while(length(coords))
		var/offset = length(coords) - MILLA_INTERESTING_TILE_SIZE
		var/turf/T = coords[offset + MILLA_INDEX_TURF]
		coords.len -= MILLA_INTERESTING_TILE_SIZE


		// ENSURE YOU USE STRING NUMBERS HERE, THIS IS A DICTIONARY KEY NOT AN INDEX!!!
		if(!zlevel_turf_indexes["[T.z]"])
			zlevel_turf_indexes["[T.z]"] = list()
		zlevel_turf_indexes["[T.z]"] |= T
		if(display_turfs_overlay)
			client.images += image('icons/effects/alphacolors.dmi', T, "red")
		CHECK_TICK

	// Sort the keys
	zlevel_turf_indexes = sortAssoc(zlevel_turf_indexes)

	for(var/key in zlevel_turf_indexes)
		to_chat(client, SPAN_NOTICE("Z[key]: <b>[length(zlevel_turf_indexes["[key]"])] Interesting Turfs</b>"))

	var/z_to_view = tgui_input_number(client, "A list of z-levels their ITs has appeared in chat. Please enter a Z to visualize. Enter 0 or close the window to cancel", "Selection", 0)

	if(!z_to_view)
		return

	// Do not combine these
	var/list/ui_dat = list()
	var/list/turf_markers = list()

	var/datum/browser/vis = new(client, "atvis", "Interesting Turfs (Z[z_to_view])", 300, 315)
	ui_dat += "<center><canvas width=\"255px\" height=\"255px\" id=\"atmos\"></canvas></center>"
	ui_dat += "<script>e=document.getElementById(\"atmos\");c=e.getContext('2d');c.fillStyle='#ffffff';c.fillRect(0,0,255,255);function s(x,y){var p=c.createImageData(1,1);p.data\[0]=255;p.data\[1]=0;p.data\[2]=0;p.data\[3]=255;c.putImageData(p,(x-1),255-Math.abs(y-1));}</script>"
	// Now generate the other list
	for(var/x in zlevel_turf_indexes["[z_to_view]"])
		var/turf/T = x
		turf_markers += "s([T.x],[T.y]);"
		CHECK_TICK

	ui_dat += "<script>[turf_markers.Join("")]</script>"

	vis.set_content(ui_dat.Join(""))
	vis.open(FALSE)
