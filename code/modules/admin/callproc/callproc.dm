/client/proc/callproc()
	set category = "Debug"
	set name = "Advanced ProcCall"
	set waitfor = FALSE
	callproc_blocking()

/client/proc/callproc_blocking(list/get_retval)
	if(!check_rights(R_DEBUG))
		return

	var/datum/target
	var/targetselected = FALSE
	var/returnval

	switch(alert("Proc owned by something?",,"Yes","No"))
		if("Yes")
			targetselected = TRUE
			var/list/value = vv_get_value(default_class = VV_ATOM_REFERENCE, classes = list(VV_ATOM_REFERENCE, VV_DATUM_REFERENCE, VV_MOB_REFERENCE, VV_CLIENT, VV_MARKED_DATUM, VV_TEXT_LOCATE, VV_PROCCALL_RETVAL))
			if (!value["class"] || !value["value"])
				return
			target = value["value"]
			if(!istype(target))
				return
		if("No")
			target = null
			targetselected = FALSE

	var/procpath = input("Proc path, eg: /proc/fake_blood","Path:", null) as text|null
	if(!procpath)
		return

	//strip away everything but the proc name
	var/list/proclist = splittext(procpath, "/")
	if (!length(proclist))
		return

	var/procname = proclist[proclist.len]
	var/proctype = ("verb" in proclist) ? "verb" :"proc"

	if(targetselected)
		if(!hascall(target, procname))
			return
	else
		procpath = "/[proctype]/[procname]"
		if(!text2path(procpath))
			return

	var/list/lst = get_callproc_args()
	if(!lst)
		return

	if(targetselected)
		if(!target)
			return
		var/msg = "[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]."
		log_admin(msg)
		message_admins(msg) //Proccall announce removed.
		returnval = WrapAdminProcCall(target, procname, lst) // Pass the lst as an argument list to the proc
	else
		//this currently has no hascall protection. wasn't able to get it working.
		log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
		message_admins("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].") //Proccall announce removed.
		returnval = WrapAdminProcCall(GLOBAL_PROC, procname, lst) // Pass the lst as an argument list to the proc
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Advanced ProcCall") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	if(get_retval)
		get_retval += returnval
	. = get_callproc_returnval(returnval, procname)

GLOBAL_VAR(LastAdminCalledTargetRef)
GLOBAL_PROTECT(LastAdminCalledTargetRef)

/// Wrapper for proccalls where the datum is flagged as vareditted
/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target && procname == "Del")
		return

	if(target != GLOBAL_PROC && !target.CanProcCall(procname))
		return
	var/current_caller = GLOB.AdminProcCaller
	var/ckey = usr ? usr.client.ckey : GLOB.AdminProcCaller
	if(!ckey)
		CRASH("WrapAdminProcCall with no ckey: [target] [procname] [english_list(arguments)]")

	if(current_caller && current_caller != ckey)
		return

	GLOB.LastAdminCalledProc = procname
	if(target != GLOBAL_PROC)
		GLOB.LastAdminCalledTargetRef = REF(target)
	GLOB.AdminProcCaller = ckey //if this runtimes, too bad for you
	++GLOB.AdminProcCallCount
	. = world.WrapAdminProcCall(target, procname, arguments)
	if(--GLOB.AdminProcCallCount == 0)
		GLOB.AdminProcCaller = null

/proc/IsAdminAdvancedProcCall()
#ifdef TESTING
	return FALSE
#else
	return usr && usr.client && GLOB.AdminProcCaller == usr.client.ckey
#endif

/client/proc/callproc_datum(datum/A as null|area|mob|obj|turf)
	set category = "Debug"
	set name = "Atom ProcCall"
	set waitfor = FALSE

	if(!check_rights(R_DEBUG))
		return

	var/procname = input("Proc name, eg: fake_blood","Proc:", null) as text|null
	if(!procname)
		return
	if(!hascall(A,procname))
		return
	var/list/lst = get_callproc_args()
	if(!lst)
		return

	if(!A || !IsValidSrc(A))
		return
	log_admin("[key_name(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
	var/msg = "[key_name(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]."
	message_admins(msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Atom ProcCall") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	var/returnval = WrapAdminProcCall(A, procname, lst) // Pass the lst as an argument list to the proc
	. = get_callproc_returnval(returnval,procname)

/client/proc/get_callproc_args()
	var/argnum = input("Number of arguments","Number:",0) as num|null
	if(isnull(argnum))
		return

	. = list()
	var/list/named_args = list()
	while(argnum--)
		var/named_arg = input("Leave blank for positional argument. Positional arguments will be considered as if they were added first.", "Named argument") as text|null
		var/value = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
		if (!value["class"])
			return
		if(named_arg)
			named_args[named_arg] = value["value"]
		else
			. += value["value"]
	if(LAZYLEN(named_args))
		. += named_args

/client/proc/get_callproc_returnval(returnval,procname)
	. = ""
	if(islist(returnval))
		var/list/returnedlist = returnval
		. = "<font color='blue'>"
		if(returnedlist.len)
			var/assoc_check = returnedlist[1]
			if(istext(assoc_check) && (returnedlist[assoc_check] != null))
				. += "[procname] returned an associative list:"
				for(var/key in returnedlist)
					. += "\n[key] = [returnedlist[key]]"

			else
				. += "[procname] returned a list:"
				for(var/elem in returnedlist)
					. += "\n[elem]"
		else
			. = "[procname] returned an empty list"
		. += "</font>"

	else
		. = "<font color='blue'>[procname] returned: [!isnull(returnval) ? html_encode(returnval) : "null"]</font>"
