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

USER_VERB(admin_robotize, R_SPAWN, "Make Robot", "Turn the target into a borg.", VERB_CATEGORY_EVENT, mob/M in GLOB.mob_list)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert(client, "Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(client)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		alert(client, "Invalid mob")

USER_VERB(admin_animalize, R_SPAWN, "Make Simple Animal", "Turn the target into a simple animal.", VERB_CATEGORY_EVENT, mob/M in GLOB.mob_list)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert(client, "Wait until the game starts")
		return

	if(!M)
		alert(client, "That mob doesn't seem to exist, close the panel and try again.")
		return

	if(isnewplayer(M))
		alert(client, "The mob must not be a new_player.")
		return

	log_admin("[key_name(client)] has animalized [M.key].")
	spawn(10)
		M.Animalize()

USER_VERB(admin_make_pai, R_SPAWN, "Make pAI", "Specify a location to spawn a pAI device, then specify a key to play that pAI", VERB_CATEGORY_EVENT, turf/T in GLOB.mob_list)
	var/list/available = list()
	for(var/mob/C in GLOB.mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = input(client, "Choose a player to play the pAI", "Spawn pAI") in available
	if(!choice)
		return 0
	if(!isobserver(choice))
		var/confirm = input(client, "[choice.key] isn't ghosting right now. Are you sure you want to yank [choice.p_them()] out of [choice.p_their()] body and place [choice.p_them()] in this pAI?", "Spawn pAI Confirmation", "No") in list("Yes", "No")
		if(confirm != "Yes")
			return 0
	var/obj/item/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)
	var/raw_name = clean_input("Enter your pAI name:", "pAI Name", "Personal AI", choice, user = client)
	var/new_name = reject_bad_name(raw_name, 1)
	if(new_name)
		pai.name = new_name
		pai.real_name = new_name
	else
		to_chat(client, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/pai_save/candidate in GLOB.paiController.pai_candidates)
		if(candidate.owner.ckey == choice.ckey)
			GLOB.paiController.pai_candidates.Remove(candidate)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make pAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(admin_alienize, R_SPAWN, "Make Alien", "Turn the target mob into an alien.", VERB_CATEGORY_EVENT, mob/M in GLOB.mob_list)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert(client, "Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(client)] has alienized [M.key].")
		spawn(10)
			M:Alienize()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Alien") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(client)] made [key_name(M)] into an alien.")
		message_admins(SPAN_NOTICE("[key_name_admin(client)] made [key_name(M)] into an alien."), 1)
	else
		alert(client, "Invalid mob")

USER_VERB(admin_slimezie, R_SPAWN, "Make slime", "Turn the target mob into a slime.", VERB_CATEGORY_EVENT, mob/M in GLOB.mob_list)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert(client, "Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(client)] has slimeized [M.key].")
		spawn(10)
			M:slimeize()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Slime") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(client)] made [key_name(M)] into a slime.")
		message_admins(SPAN_NOTICE("[key_name_admin(client)] made [key_name(M)] into a slime."), 1)
	else
		alert(client, "Invalid mob")

USER_VERB(admin_super, R_SPAWN, "Make Superhero", "Turn the target mob into a superhero.", VERB_CATEGORY_EVENT, mob/M in GLOB.mob_list)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert(client, "Wait until the game starts")
		return
	if(ishuman(M))
		var/type = input(client, "Pick the Superhero","Superhero") as null|anything in GLOB.all_superheroes
		var/datum/superheroes/S = GLOB.all_superheroes[type]
		if(S)
			S.create(M)
		log_admin("[key_name(client)] has turned [M.key] into a Superhero.")
		message_admins(SPAN_NOTICE("[key_name_admin(client)] made [key_name(M)] into a Superhero."), 1)
	else
		alert(client, "Invalid mob")

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

USER_VERB_VISIBILITY(grant_full_access, VERB_VISIBILITY_FLAG_MOREDEBUG)
USER_VERB(grant_full_access, R_EVENT, "Grant Full Access", "Gives mob all-access.", VERB_CATEGORY_ADMIN, mob/M in GLOB.mob_list)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		alert(client, "Wait until the game starts")
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
			H.equip_to_slot_or_del(id, ITEM_SLOT_ID)
			H.update_inv_wear_id()
	else
		alert(client, "Invalid mob")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Grant Full Access") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(client)] has granted [M.key] full access.")
	message_admins(SPAN_NOTICE("[key_name_admin(client)] has granted [M.key] full access."), 1)

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

USER_CONTEXT_MENU(select_equipment, R_EVENT, "\[Admin\] Select equipment", mob/living/carbon/human/M in GLOB.human_list)
	if(!ishuman(M) && !isobserver(M))
		alert(client, "Invalid mob")
		return

	var/dresscode = client.robust_dress_shop()

	if(!dresscode)
		return

	var/delete_pocket
	var/mob/living/carbon/human/H
	if(isobserver(M))
		H = M.change_mob_type(/mob/living/carbon/human, null, null, TRUE)
	else
		H = M
		if(H.l_store || H.r_store || H.s_store) //saves a lot of time for admins and coders alike
			if(alert(client, "Should the items in their pockets be dropped? Selecting \"No\" will delete them.", "Robust quick dress shop", "Yes", "No") == "No")
				delete_pocket = TRUE

	for(var/obj/item/I in H.get_equipped_items(delete_pocket))
		qdel(I)
	if(dresscode != "Naked")
		H.equipOutfit(dresscode)

	H.regenerate_icons()

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Select Equipment") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(client)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins(SPAN_NOTICE("[key_name_admin(client)] changed the equipment of [key_name_admin(M)] to [dresscode]."), 1)

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

