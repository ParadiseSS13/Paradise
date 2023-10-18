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

		if(targetselected && !hascall(target,procname))
			to_chat(usr, "<font color='red'>Error: callproc(): target has no such call [procname].</font>")
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
		return call("/proc/[procname]")(arglist(arguments))
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

/client/proc/callproc_datum(A as null|area|mob|obj|turf)
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
	if(argnum <= 0)
		return list() // to allow for calling with 0 args

	argnum = clamp(argnum, 1, 50)

	var/list/lst = list()
	//TODO: make a list to store whether each argument was initialised as null.
	//Reason: So we can abort the proccall if say, one of our arguments was a mob which no longer exists
	//this will protect us from a fair few errors ~Carn

	while(argnum--)
		var/class = null
		// Make a list with each index containing one variable, to be given to the proc
		if(src.holder && src.holder.marked_datum)
			class = input("What kind of variable?","Variable Type") in list("text","num","type","reference","reference in range","reference in view", "mob reference","icon","file","client","mob's area","Marked datum ([holder.marked_datum.type])","CANCEL")
			if(holder.marked_datum && class == "Marked datum ([holder.marked_datum.type])")
				class = "Marked datum"
		else
			class = input("What kind of variable?","Variable Type") in list("text","num","type","reference","mob reference","reference in range","reference in view","icon","file","client","mob's area","CANCEL")
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

			if("reference in range")
				lst += input("Select reference in range:", "Reference in range", src) as mob|obj|turf|area in range(view)

			if("reference in view")
				lst += input("Select reference in view:", "Reference in view", src) as mob|obj|turf|area in view(view)

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

	if(!isturf(T))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/t = ""
	t+= "Nitrogen : [env.nitrogen]\n"
	t+= "Oxygen : [env.oxygen]\n"
	t+= "Plasma : [env.toxins]\n"
	t+= "CO2: [env.carbon_dioxide]\n"

	usr.show_message(t, 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Air Status (Location)") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(mob/M in GLOB.mob_list)
	set category = "Event"
	set name = "Make Robot"

	if(!check_rights(R_SPAWN))
		return

	if(!SSticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		alert("Invalid mob")

/client/proc/cmd_admin_animalize(mob/M in GLOB.mob_list)
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


/client/proc/makepAI(turf/T in GLOB.mob_list)
	set category = "Event"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	if(!check_rights(R_SPAWN))
		return

	var/list/available = list()
	for(var/mob/C in GLOB.mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = input("Choose a player to play the pAI", "Spawn pAI") in available
	if(!choice)
		return 0
	if(!isobserver(choice))
		var/confirm = input("[choice.key] isn't ghosting right now. Are you sure you want to yank [choice.p_them()] out of [choice.p_their()] body and place [choice.p_them()] in this pAI?", "Spawn pAI Confirmation", "No") in list("Yes", "No")
		if(confirm != "Yes")
			return 0
	var/obj/item/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)
	var/raw_name = clean_input("Enter your pAI name:", "pAI Name", "Personal AI", choice)
	var/new_name = reject_bad_name(raw_name, 1)
	if(new_name)
		pai.name = new_name
		pai.real_name = new_name
	else
		to_chat(usr, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/pai_save/candidate in GLOB.paiController.pai_candidates)
		if(candidate.owner.ckey == choice.ckey)
			GLOB.paiController.pai_candidates.Remove(candidate)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make pAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_alienize(mob/M in GLOB.mob_list)
	set category = "Event"
	set name = "Make Alien"

	if(!check_rights(R_SPAWN))
		return

	if(!SSticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has alienized [M.key].")
		spawn(10)
			M:Alienize()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Alien") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into an alien.")
		message_admins("<span class='notice'>[key_name_admin(usr)] made [key_name(M)] into an alien.</span>", 1)
	else
		alert("Invalid mob")

/client/proc/cmd_admin_slimeize(mob/M in GLOB.mob_list)
	set category = "Event"
	set name = "Make slime"

	if(!check_rights(R_SPAWN))
		return

	if(!SSticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has slimeized [M.key].")
		spawn(10)
			M:slimeize()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Slime") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into a slime.")
		message_admins("<span class='notice'>[key_name_admin(usr)] made [key_name(M)] into a slime.</span>", 1)
	else
		alert("Invalid mob")

/client/proc/cmd_admin_super(mob/M in GLOB.mob_list)
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
		log_admin("[key_name(src)] has turned [M.key] into a Superhero.")
		message_admins("<span class='notice'>[key_name_admin(usr)] made [key_name(M)] into a Superhero.</span>", 1)
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
	log_admin("[key_name(src)] has deleted all Singularities and Tesla orbs.")
	message_admins("[key_name_admin(src)] has deleted all Singularities and Tesla orbs.", 0)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Del Singulo/Tesla") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"

	if(!check_rights(R_DEBUG))
		return

	SSmachines.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.", 0)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Powernets") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_grantfullaccess(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Grant Full Access"

	if(!check_rights(R_EVENT))
		return

	if(!SSticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.wear_id)
			var/obj/item/card/id/id = H.wear_id
			if(istype(H.wear_id, /obj/item/pda))
				var/obj/item/pda/pda = H.wear_id
				id = pda.id
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		else
			var/obj/item/card/id/id = new/obj/item/card/id(M)
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
			id.registered_name = H.real_name
			id.assignment = "Captain"
			id.name = "[id.registered_name]'s ID Card ([id.assignment])"
			H.equip_to_slot_or_del(id, SLOT_HUD_WEAR_ID)
			H.update_inv_wear_id()
	else
		alert("Invalid mob")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Grant Full Access") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins("<span class='notice'>[key_name_admin(usr)] has granted [M.key] full access.</span>", 1)

/client/proc/cmd_assume_direct_control(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(!check_rights(R_DEBUG|R_ADMIN))
		return

	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			ghost.ckey = M.ckey
	message_admins("<span class='notice'>[key_name_admin(usr)] assumed direct control of [M].</span>", 1)
	log_admin("[key_name(usr)] assumed direct control of [M].")
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
	log_admin("[key_name(usr)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins("<span class='notice'>[key_name_admin(usr)] changed the equipment of [key_name_admin(M)] to [dresscode].</span>", 1)

/client/proc/robust_dress_shop()
	var/list/special_outfits = list(
		"Naked",
		"As Job...",
		"Custom..."
	)

	var/list/outfits = list()
	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job)
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
			E.active = TRUE

	for(var/obj/machinery/field/generator/F in GLOB.machines)
		if(!F.active)
			F.active = TRUE
			F.state = 2
			F.power = 250
			F.anchored = TRUE
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
			if(!Rad.loaded_tank)
				var/obj/item/tank/internals/plasma/Plasma = new/obj/item/tank/internals/plasma(Rad)
				Plasma.air_contents.toxins = 70
				Rad.drainratio = 0
				Rad.loaded_tank = Plasma
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
			var/list/respawnable_mobs
			for(var/mob/potential_respawnable in GLOB.player_list)
				if(HAS_TRAIT(potential_respawnable, TRAIT_RESPAWNABLE))
					respawnable_mobs += potential_respawnable
			to_chat(usr, jointext(respawnable_mobs, ", "))

/client/proc/cmd_display_del_log()
	set category = "Debug"
	set name = "Display del() Log"
	set desc = "Display del's log of everything that's passed through it."

	if(!check_rights(R_DEBUG|R_VIEWRUNTIMES))
		return

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

	if(!check_rights(R_DEBUG|R_VIEWRUNTIMES))
		return

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

	usr << browse(dat, "window=simpledellog")

/client/proc/show_gc_queues()
	set name = "View GC Queue"
	set category = "Debug"
	set desc = "Shows the list of whats currently in a GC queue"

	if(!check_rights(R_DEBUG|R_VIEWRUNTIMES))
		return

	// Get the amount of queues
	var/queue_count = length(SSgarbage.queues)
	var/list/selectable_queues = list()
	// Setup choices
	for(var/i in 1 to queue_count)
		selectable_queues["Queue #[i] ([length(SSgarbage.queues[i])] item\s)"] = i

	// Ask the user
	var/choice = input(usr, "Select a GC queue. Note that the queue lookup may lag the server.", "GC Queue") as null|anything in selectable_queues
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
	usr << browse(text.Join(), "window=gcqueuestatus")

/client/proc/cmd_admin_toggle_block(mob/M, block)
	if(!check_rights(R_SPAWN))
		return

	if(!SSticker)
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

/client/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the Runtime Viewer"

	if(!check_rights(R_DEBUG|R_VIEWRUNTIMES))
		return

	GLOB.error_cache.showTo(usr)

/client/proc/visualise_active_turfs()
	set category = "Debug"
	set name = "Visualise Active Turfs"

	if(!check_rights(R_DEBUG | R_VIEWRUNTIMES))
		return

	// This can potentially iterate through a list thats 20k things long. Give ample warning to the user
	var/confirm = alert(usr, "WARNING: This process is lag intensive and should only be used if the atmos controller is screaming bloody murder. Are you sure you with to continue", "WARNING", "Im sure", "Nope")
	if(confirm != "Im sure")
		return

	var/display_turfs_overlay = FALSE
	var/do_display_turf_overlay = alert(usr, "Would you like to have all active turfs have a client side overlay applied as well?", "Optional", "Yep", "Nope")
	if(do_display_turf_overlay == "Yep")
		display_turfs_overlay = TRUE

	message_admins("[key_name_admin(usr)] is visualising active atmos turfs. Server may lag.")

	var/list/zlevel_turf_indexes = list()

	for(var/i in SSair.active_turfs)
		var/turf/T = i
		// ENSURE YOU USE STRING NUMBERS HERE, THIS IS A DICTIONARY KEY NOT AN INDEX!!!
		if(!zlevel_turf_indexes["[T.z]"])
			zlevel_turf_indexes["[T.z]"] = list()
		zlevel_turf_indexes["[T.z]"] |= T
		if(display_turfs_overlay)
			usr.client.images += image('icons/effects/alphacolors.dmi', T, "red")
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
