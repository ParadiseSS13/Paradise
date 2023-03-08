/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"

	if(!check_rights(R_DEBUG))
		return

	if(GLOB.debug2)
		GLOB.debug2 = 0
		message_admins("[key_name_admin(src)] toggled debugging off.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		GLOB.debug2 = 1
		message_admins("[key_name_admin(src)] toggled debugging on.")
		log_admin("[key_name(src)] toggled debugging on.")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug Game") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/Dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/callproc()
	set category = "Debug"
	set name = "Advanced ProcCall"

	if(!check_rights(R_PROCCALL))
		return

	spawn(0)
		var/target = null
		var/targetselected = 0
		var/returnval = null
		var/class = null

		switch(alert("Proc owned by something?",,"Yes","No"))
			if("Yes")
				targetselected = 1
				if(src.holder && src.holder.marked_datum)
					class = input("Proc owned by...","Owner",null) as null|anything in list("Obj","Mob","Area or Turf","Client","Marked datum ([holder.marked_datum.type])")
					if(class == "Marked datum ([holder.marked_datum.type])")
						class = "Marked datum"
				else
					class = input("Proc owned by...","Owner",null) as null|anything in list("Obj","Mob","Area or Turf","Client")
				switch(class)
					if("Obj")
						target = input("Enter target:","Target",usr) as obj in world
					if("Mob")
						target = input("Enter target:","Target",usr) as mob in world
					if("Area or Turf")
						target = input("Enter target:","Target",usr.loc) as area|turf in world
					if("Client")
						var/list/keys = list()
						for(var/client/C)
							keys += C
						target = input("Please, select a player!", "Selection", null, null) as null|anything in keys
					if("Marked datum")
						target = holder.marked_datum
					else
						return
			if("No")
				target = null
				targetselected = 0

		var/procname = clean_input("Proc path, eg: /proc/fake_blood","Path:", null)
		if(!procname)	return

		//strip away everything but the proc name
		var/list/proclist = splittext(procname, "/")
		if (!length(proclist))
			return
		procname = proclist[proclist.len]

		var/proctype = "proc"
		if ("verb" in proclist)
			proctype = "verb"

		if(targetselected && !hascall(target,procname))
			to_chat(usr, "<font color='red'>Error: callproc(): type [class] has no [proctype] named [procname].</font>")
			return

		var/list/lst = get_callproc_args()
		if(!lst)
			return

		if(targetselected)
			if(!target)
				to_chat(usr, "<font color='red'>Error: callproc(): owner of proc no longer exists.</font>")
				return
			message_admins("[key_name_admin(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			log_admin("[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = WrapAdminProcCall(target, procname, lst) // Pass the lst as an argument list to the proc
		else
			//this currently has no hascall protection. wasn't able to get it working.
			message_admins("[key_name_admin(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]")
			log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]")
			returnval = WrapAdminProcCall(GLOBAL_PROC, procname, lst) // Pass the lst as an argument list to the proc

		to_chat(usr, "<font color='#EB4E00'>[procname] returned: [!isnull(returnval) ? returnval : "null"]</font>")
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
			to_chat(usr, "<span class='adminnotice'>Another set of admin called procs are still running, your proc will be run after theirs finish.</span>")
			GLOB.AdminProcCallSpamPrevention[ckey] = TRUE
			UNTIL(!GLOB.AdminProcCaller)
			to_chat(usr, "<span class='adminnotice'>Running your proc</span>")
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
	catch
		to_chat(usr, "<span class='adminnotice'>Your proc call failed to execute, likely from runtimes. You <i>should</i> be out of safety mode. If not, god help you.</span>")

	if(--GLOB.AdminProcCallCount == 0)
		GLOB.AdminProcCaller = null

//adv proc call this, ya nerds
/world/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target == GLOBAL_PROC)
		return call(procname)(arglist(arguments))
	else if(target != world)
		return call(target, procname)(arglist(arguments))
	else
		to_chat(usr, "<span class='boldannounce'>Call to world/proc/[procname] blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to call world/proc/[procname] with arguments: [english_list(arguments)]")
		log_admin("[key_name(usr)] attempted to call world/proc/[procname] with arguments: [english_list(arguments)]l")

/proc/IsAdminAdvancedProcCall()
#ifdef TESTING
	return FALSE
#else
	return usr && usr.client && GLOB.AdminProcCaller == usr.client.ckey
#endif

/client/proc/callproc_datum(var/A as null|area|mob|obj|turf)
	set category = null
	set name = "\[Admin\] Atom ProcCall"

	if(!check_rights(R_PROCCALL))
		return

	var/procname = clean_input("Proc name, eg: fake_blood","Proc:", null)
	if(!procname)
		return

	if(!hascall(A,procname))
		to_chat(usr, "<span class='warning'>Error: callproc_datum(): target has no such call [procname].</span>")
		return

	var/list/lst = get_callproc_args()
	if(!lst)
		return

	if(!A || !IsValidSrc(A))
		to_chat(src, "<span class='warning'>Error: callproc_datum(): owner of proc no longer exists.</span>")
		return
	message_admins("[key_name_admin(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]")
	log_admin("[key_name(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]")

	spawn()
		var/returnval = WrapAdminProcCall(A, procname, lst) // Pass the lst as an argument list to the proc
		to_chat(src, "<span class='notice'>[procname] returned: [!isnull(returnval) ? returnval : "null"]</span>")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Atom Proc-Call") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/get_callproc_args()
	var/argnum = input("Number of arguments","Number:",0) as num|null
	if(!argnum && (argnum!=0))	return

	var/list/lst = list()
	//TODO: make a list to store whether each argument was initialised as null.
	//Reason: So we can abort the proccall if say, one of our arguments was a mob which no longer exists
	//this will protect us from a fair few errors ~Carn

	while(argnum--)
		var/class = null
		// Make a list with each index containing one variable, to be given to the proc
		if(src.holder && src.holder.marked_datum)
			class = input("What kind of variable?","Variable Type") in list("text","num","type","reference","mob reference","icon","file","client","mob's area","Marked datum ([holder.marked_datum.type])","CANCEL")
			if(holder.marked_datum && class == "Marked datum ([holder.marked_datum.type])")
				class = "Marked datum"
		else
			class = input("What kind of variable?","Variable Type") in list("text","num","type","reference","mob reference","icon","file","client","mob's area","CANCEL")
		switch(class)
			if("CANCEL")
				return null

			if("text")
				lst += clean_input("Enter new text:","Text",null)

			if("num")
				lst += input("Enter new number:","Num",0) as num

			if("type")
				lst += input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

			if("reference")
				lst += input("Select reference:","Reference",src) as mob|obj|turf|area in world

			if("mob reference")
				lst += input("Select reference:","Reference",usr) as mob in world

			if("file")
				lst += input("Pick file:","File") as file

			if("icon")
				lst += input("Pick icon:","Icon") as icon

			if("client")
				var/list/keys = list()
				for(var/mob/M in world)
					keys += M.client
				lst += input("Please, select a player!", "Selection", null, null) as null|anything in keys

			if("mob's area")
				var/mob/temp = input("Select mob", "Selection", usr) as mob in world
				lst += temp.loc

			if("Marked datum")
				lst += holder.marked_datum
	return lst

/client/proc/Cell()
	set category = "Debug"
	set name = "Air Status in Location"

	if(!check_rights(R_DEBUG))
		return

	if(!mob)
		return
	var/turf/T = mob.loc

	if(!( istype(T, /turf) ))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/t = ""
	t+= "Nitrogen : [env.nitrogen]\n"
	t+= "Oxygen : [env.oxygen]\n"
	t+= "Plasma : [env.toxins]\n"
	t+= "CO2: [env.carbon_dioxide]\n"

	usr.show_message(t, 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Air Status (Location)") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(var/mob/M in GLOB.mob_list)
	set category = "Event"
	set name = "Make Robot"

	if(!check_rights(R_SPAWN))
		return

	if(!SSticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		alert("Invalid mob")

/client/proc/cmd_admin_animalize(var/mob/M in GLOB.mob_list)
	set category = "Event"
	set name = "Make Simple Animal"

	if(!check_rights(R_SPAWN))
		return

	if(!SSticker)
		alert("Wait until the game starts")
		return

	if(!M)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(isnewplayer(M))
		alert("The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(10)
		M.Animalize()

/client/proc/cmd_admin_super(var/mob/M in GLOB.mob_list)
	set category = "Event"
	set name = "Make Superhero"

	if(!check_rights(R_SPAWN))
		return

	if(!SSticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		var/type = input("Pick the Superhero","Superhero") as null|anything in GLOB.all_superheroes
		var/datum/superheroes/S = GLOB.all_superheroes[type]
		if(S)
			S.create(M)
		log_and_message_admins("<span class='notice'>made [key_name(M)] into a Superhero.</span>")
	else
		alert("Invalid mob")

/client/proc/cmd_debug_del_sing()
	set category = "Debug"
	set name = "Del Singulo / Tesla"

	if(!check_rights(R_DEBUG))
		return

	//This gets a confirmation check because it's way easier to accidentally hit this and delete things than it is with qdel-all
	var/confirm = alert("This will delete ALL Singularities and Tesla orbs except for any that are on away mission z-levels or the centcomm z-level. Are you sure you want to delete them?", "Confirm Panic Button", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/I in GLOB.singularities)
		var/obj/singularity/S = I
		if(!is_level_reachable(S.z))
			continue
		qdel(S)
	log_and_message_admins("has deleted all Singularities and Tesla orbs.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Del Singulo/Tesla") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"

	if(!check_rights(R_DEBUG))
		return

	SSmachines.makepowernets()
	log_and_message_admins("has remade the powernets. makepowernets() called.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Powernets") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_grantfullaccess(var/mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "\[Admin\] Grant Full Access"

	if(!check_rights(R_EVENT))
		return

	if(!SSticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/card/id/id = null
		if(H.wear_id)
			id = H.wear_id.GetID()
		if(istype(id))
			id.icon_state = "gold"
			id.access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		if(!H.wear_id || !istype(id))
			id = new/obj/item/card/id(M)
			id.icon_state = "gold"
			id.access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
			id.registered_name = H.real_name
			id.assignment = "Captain"
			id.name = "[id.registered_name]'s ID Card ([id.assignment])"
			H.equip_to_slot_or_del(id, slot_wear_id)
			H.update_inv_wear_id()
	else
		alert("Invalid mob")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Grant Full Access") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_and_message_admins("<span class='notice'>has granted [M.key] full access.</span>")

/client/proc/cmd_assume_direct_control(var/mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "\[Admind\] Assume direct control"
	set desc = "Direct intervention"

	if(!check_rights(R_DEBUG|R_ADMIN))
		return

	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			ghost.ckey = M.ckey
	log_and_message_admins("<span class='notice'>assumed direct control of [M].</span>")
	var/mob/adminmob = src.mob
	M.ckey = src.ckey
	if( isobserver(adminmob) )
		qdel(adminmob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Assume Direct Control") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_areatest()
	set category = "Mapping"
	set name = "Test areas"

	if(!check_rights(R_DEBUG))
		return

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

	for(var/obj/machinery/requests_console/RC in GLOB.machines)
		var/area/A = get_area(RC)
		if(!A)
			continue
		areas_with_RC |= A.type

	for(var/obj/machinery/light/L in GLOB.machines)
		var/area/A = get_area(L)
		if(!A)
			continue
		areas_with_light |= A.type

	for(var/obj/machinery/light_switch/LS in GLOB.machines)
		var/area/A = get_area(LS)
		if(!A)
			continue
		areas_with_LS |= A.type

	for(var/obj/item/radio/intercom/I in GLOB.global_radios)
		var/area/A = get_area(I)
		if(!A)
			continue
		areas_with_intercom |= A.type

	for(var/obj/machinery/camera/C in GLOB.machines)
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

/client/proc/cmd_admin_dress(mob/living/carbon/human/M in GLOB.human_list)
	set category = "Event"
	set name = "\[Admin\] Select equipment"

	if(!check_rights(R_EVENT))
		return

	if(!ishuman(M) && !isobserver(M))
		alert("Invalid mob")
		return

	var/dresscode = robust_dress_shop()

	if(!dresscode)
		return

	var/delete_pocket
	var/mob/living/carbon/human/H
	if(isobserver(M))
		H = M.change_mob_type(/mob/living/carbon/human, null, null, TRUE)
	else
		H = M
		if(H.l_store || H.r_store || H.s_store) //saves a lot of time for admins and coders alike
			if(alert("Should the items in their pockets be dropped? Selecting \"No\" will delete them.", "Robust quick dress shop", "Yes", "No") == "No")
				delete_pocket = TRUE

	for (var/obj/item/I in H.get_equipped_items(delete_pocket))
		qdel(I)
	if(dresscode != "Naked")
		H.equipOutfit(dresscode)

	H.regenerate_icons()

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Select Equipment") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_and_message_admins("<span class='notice'>changed the equipment of [key_name_admin(M)] to [dresscode].</span>")

/client/proc/robust_dress_shop()
	var/list/outfits = list(
		"Naked",
		"As Job...",
		"Custom..."
	)

	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job)
	for(var/path in paths)
		var/datum/outfit/O = path //not much to initalize here but whatever
		if(initial(O.can_be_admin_equipped))
			outfits[initial(O.name)] = path

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

	return dresscode

/client/proc/startSinglo()
	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing through the station"

	if(!check_rights(R_DEBUG))
		return

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
		return

	for(var/obj/machinery/power/emitter/E in GLOB.machines)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field/generator/F in GLOB.machines)
		if(F.active == 0)
			F.active = 1
			F.state = 2
			F.power = 250
			F.anchored = 1
			F.warming_up = 3
			F.start_fields()
			F.update_icon()

	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in GLOB.machines)
			if(G.anchored)
				var/obj/singularity/S = new /obj/singularity(get_turf(G))
				S.energy = 800
				break

	for(var/obj/machinery/power/rad_collector/Rad in GLOB.machines)
		if(Rad.anchored)
			if(!Rad.P)
				var/obj/item/tank/internals/plasma/Plasma = new/obj/item/tank/internals/plasma(Rad)
				Plasma.air_contents.toxins = 70
				Rad.drainratio = 0
				Rad.P = Plasma
				Plasma.loc = Rad

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in GLOB.machines)
		if(SMES.anchored)
			SMES.input_attempt = 1

/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	if(!check_rights(R_DEBUG))
		return

	switch(input("Which list?") in list("Players", "Admins", "Mobs", "Living Mobs", "Alive Mobs", "Dead Mobs", "Silicons", "Clients", "Respawnable Mobs"))
		if("Players")
			to_chat(usr, jointext(GLOB.player_list, ","))
		if("Admins")
			to_chat(usr, jointext(GLOB.admins, ","))
		if("Mobs")
			to_chat(usr, jointext(GLOB.mob_list, ","))
		if("Living Mobs")
			to_chat(usr, jointext(GLOB.mob_living_list, ","))
		if("Alive Mobs")
			to_chat(usr, jointext(GLOB.alive_mob_list, ","))
		if("Dead Mobs")
			to_chat(usr, jointext(GLOB.dead_mob_list, ","))
		if("Silicons")
			to_chat(usr, jointext(GLOB.silicon_mob_list, ","))
		if("Clients")
			to_chat(usr, jointext(GLOB.clients, ","))
		if("Respawnable Mobs")
			to_chat(usr, jointext(GLOB.respawnable_list, ","))

/client/proc/cmd_display_del_log()
	set category = "Debug"
	set name = "Display del() Log"
	set desc = "Display del's log of everything that's passed through it."

	if(!check_rights(R_DEBUG))
		return

	var/list/dellog = list("<B>List of things that have gone through qdel this round</B><BR><BR><ol>")
	sortTim(SSgarbage.items, cmp=/proc/cmp_qdel_item_time, associative = TRUE)
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
		if(I.slept_destroy)
			dellog += "<li>Sleeps: [I.slept_destroy]</li>"
		if(I.no_respect_force)
			dellog += "<li>Ignored force: [I.no_respect_force]</li>"
		if(I.no_hint)
			dellog += "<li>No hint: [I.no_hint]</li>"
		dellog += "</ul></li>"

	dellog += "</ol>"

	usr << browse(dellog.Join(), "window=dellog")

/client/proc/cmd_display_del_log_simple()
	set category = "Debug"
	set name = "Display Simple del() Log"
	set desc = "Display a compacted del's log."

	if(!check_rights(R_DEBUG))
		return

	var/dat = {"<meta charset="UTF-8"><B>List of things that failed to GC this round</B><BR><BR>"}
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

	usr << browse(dat, "window=simpledellog")

/client/proc/cmd_admin_toggle_block(var/mob/M,var/block)
	if(!check_rights(R_SPAWN))
		return

	if(!SSticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon))
		M.dna.SetSEState(block,!M.dna.GetSEState(block))
		genemutcheck(M,block,null,MUTCHK_FORCED)
		M.update_mutations()
		var/state="[M.dna.GetSEState(block)?"on":"off"]"
		var/blockname=GLOB.assigned_blocks[block]
		message_admins("[key_name_admin(src)] has toggled [M.key]'s [blockname] block [state]!")
		log_admin("[key_name(src)] has toggled [M.key]'s [blockname] block [state]!")
	else
		alert("Invalid mob")

/client/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the Runtime Viewer"

	if(!check_rights(R_DEBUG|R_VIEWRUNTIMES))
		return

	GLOB.error_cache.showTo(usr)

/client/proc/jump_to_ruin()
	set category = "Debug"
	set name = "Jump to Ruin"
	set desc = "Displays a list of all placed ruins to teleport to."

	if(!check_rights(R_DEBUG))
		return

	var/list/names = list()
	for(var/i in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/ruin_landmark = i
		var/datum/map_template/ruin/template = ruin_landmark.ruin_template

		var/count = 1
		var/name = template.name
		var/original_name = name

		while(name in names)
			count++
			name = "[original_name] ([count])"

		names[name] = ruin_landmark

	var/ruinname = input("Select ruin", "Jump to Ruin") as null|anything in names

	var/obj/effect/landmark/ruin/landmark = names[ruinname]

	if(istype(landmark))
		var/datum/map_template/ruin/template = landmark.ruin_template
		if(isobj(usr.loc))
			var/obj/O = usr.loc
			O.force_eject_occupant(usr)
		admin_forcemove(usr, get_turf(landmark))

		to_chat(usr, "<span class='name'>[template.name]</span>")
		to_chat(usr, "<span class='italics'>[template.description]</span>")

		log_admin("[key_name(usr)] jumped to ruin [ruinname]")
		if(!isobserver(usr))
			message_admins("[key_name_admin(usr)] jumped to ruin [ruinname]")

		SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Ruin") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_medal_disable()
	set category = "Debug"
	set name = "Toggle Medal Disable"
	set desc = "Toggles the safety lock on trying to contact the medal hub."

	if(!check_rights(R_DEBUG))
		return

	SSmedals.hub_enabled = !SSmedals.hub_enabled

	message_admins("<span class='adminnotice'>[key_name_admin(src)] [SSmedals.hub_enabled ? "disabled" : "enabled"] the medal hub lockout.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Medal Disable") // If...
	log_admin("[key_name(src)] [SSmedals.hub_enabled ? "disabled" : "enabled"] the medal hub lockout.")


/client/proc/visualise_active_turfs()
	set category = "Debug"
	set name = "Visualise Active Turfs"

	if(!check_rights(R_DEBUG))
		return

	// This can potentially iterate through a list thats 20k things long. Give ample warning to the user
	var/confirm = alert(usr, "WARNING: This process is lag intensive and should only be used if the atmos controller is screaming bloody murder. Are you sure you with to continue", "WARNING", "Im sure", "Nope")
	if(confirm != "Im sure")
		return

	message_admins("[key_name_admin(usr)] is visualising active atmos turfs. Server may lag.")

	var/list/zlevel_turf_indexes = list()

	for(var/i in SSair.active_turfs)
		var/turf/T = i
		// ENSURE YOU USE STRING NUMBERS HERE, THIS IS A DICTIONARY KEY NOT AN INDEX!!!
		if(!zlevel_turf_indexes["[T.z]"])
			zlevel_turf_indexes["[T.z]"] = list()
		zlevel_turf_indexes["[T.z]"] |= T
		CHECK_TICK

	// Sort the keys
	zlevel_turf_indexes = sortAssoc(zlevel_turf_indexes)

	for(var/key in zlevel_turf_indexes)
		to_chat(usr, "<span class='notice'>Z[key]: <b>[length(zlevel_turf_indexes["[key]"])] ATs</b></span>")

	var/z_to_view = input(usr, "A list of z-levels their ATs has appeared in chat. Please enter a Z to visualise. Enter 0 to cancel.", "Selection", 0) as num

	if(!z_to_view)
		return

	// Do not combine these
	var/list/ui_dat = list()
	var/list/turf_markers = list()

	var/datum/browser/vis = new(usr, "atvis", "Active Turfs (Z[z_to_view])", 300, 315)
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

/client/proc/view_pingstat()
	set category = "Debug"
	set name = "View Pingstat"
	set desc = "Open the Pingstat Report"

	if(holder && holder.rights != R_HOST)
		return

	var/msg = {"<html><meta charset="UTF-8"><head><title>Pingstat Report</title></head><body>"}
	var/color
	msg += "<TABLE border ='1'><TR>"
	msg += "<TH>Player</TH>"
	msg += "<TH>Quality</TH>"
	msg += "<TH>Ping</TH>"
	msg += "<TH>AvgPing</TH>"
	msg += "<TH>Url</TH>"
	msg += "<TH>IP</TH>"
	msg += "<TH>Country</TH>"
	msg += "<TH>CountryCode</TH>"
	msg += "<TH>Region</TH>"
	msg += "<TH>Region Name</TH>"
	msg += "<TH>City</TH>"
	msg += "<TH>Timezone</TH>"
	msg += "<TH>ISP</TH>"
	msg += "<TH>Mobile</TH>"
	msg += "<TH>Proxy</TH>"
	msg += "<TH>Status</TH>"

	msg += "</TR>"
	for(var/client/C in GLOB.clients)
		msg += "<TR>"

		msg += "<TD>[key_name_admin(C.mob)]</TD>"
		color = "rgb([C.lastping], [255 - clamp(text2num(C.lastping), 0, 255)], 0)"
		msg += "<TD bgcolor='[color]' >&nbsp;</TD>"
		msg += "<TD><b>[C.lastping]<b></TD>"
		msg += "<TD><b>[round(C.avgping,1)]<b></TD>"
		msg += "<TD>[C.url]</TD>"

		if(C.geoip.status != "updated")
			C.geoip.try_update_geoip(C, C.address)
		msg += "<TD>[C.geoip.ip]</TD>"
		msg += "<TD>[C.geoip.country]</TD>"
		msg += "<TD>[C.geoip.countryCode]</TD>"
		msg += "<TD>[C.geoip.region]</TD>"
		msg += "<TD>[C.geoip.regionName]</TD>"
		msg += "<TD>[C.geoip.city]</TD>"
		msg += "<TD>[C.geoip.timezone]</TD>"
		msg += "<TD>[C.geoip.isp]</TD>"
		msg += "<TD>[C.geoip.mobile]</TD>"
		msg += "<TD>[C.geoip.proxy]</TD>"
		msg += "<TD>[C.geoip.status]</TD>"

		msg += "</TR>"

	msg += "</TABLE></BODY></HTML>"
	src << browse(msg, "window=pingstat_report;size=1500x600")
