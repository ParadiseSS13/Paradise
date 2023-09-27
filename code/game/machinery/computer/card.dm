//Keeps track of the time for the ID console. Having it as a global variable prevents people from dismantling/reassembling it to
//increase the slots of many jobs.
GLOBAL_VAR_INIT(time_last_changed_position, 0)

#define IDCOMPUTER_SCREEN_TRANSFER 0
#define IDCOMPUTER_SCREEN_SLOTS 1
#define IDCOMPUTER_SCREEN_ACCESS 2
#define IDCOMPUTER_SCREEN_RECORDS 3
#define IDCOMPUTER_SCREEN_DEPT 4

/obj/machinery/computer/card
	name = "identification computer"
	desc = "Terminal for programming Nanotrasen employee ID cards to access parts of the station."
	icon_keyboard = "id_key"
	icon_screen = "id"
	req_access = list(ACCESS_CHANGE_IDS)
	circuit = /obj/item/circuitboard/card
	light_color = LIGHT_COLOR_LIGHTBLUE
	var/obj/item/card/id/scan = null
	var/obj/item/card/id/modify = null
	var/mode = 0
	var/target_dept = 0 //Which department this computer has access to. 0=all departments
	var/obj/item/radio/Radio

	//Cooldown for closing positions in seconds
	//if set to -1: No cooldown... probably a bad idea
	//if set to 0: Not able to close "original" positions. You can only close positions that you have opened before
	var/change_position_cooldown = 60
	// Jobs that do not appear in the list at all.
	var/list/blacklisted_full = list(
		/datum/job/ntnavyofficer,
		/datum/job/ntspecops,
		/datum/job/ntspecops/solgovspecops,
		/datum/job/assistant,
		/datum/job/syndicateofficer,
		/datum/job/explorer // blacklisted so that HOPs don't try prioritizing it, then wonder why that doesn't work
	)
	// Jobs that appear in the list, and you can prioritize, but not open/close slots for
	var/list/blacklisted_partial = list(
		/datum/job/ai,
		/datum/job/cyborg,
		/datum/job/captain,
		/datum/job/hop,
		/datum/job/hos,
		/datum/job/chief_engineer,
		/datum/job/rd,
		/datum/job/cmo,
		/datum/job/judge,
		/datum/job/blueshield,
		/datum/job/nanotrasenrep,
		/datum/job/chaplain,
		/datum/job/officer,
		/datum/job/qm
)

	//The scaling factor of max total positions in relation to the total amount of people on board the station in %
	var/max_relative_positions = 30 //30%: Seems reasonable, limit of 6 @ 20 players

	//This is used to keep track of opened positions for jobs to allow instant closing
	//Assoc array: "JobName" = (int)<Opened Positions>
	var/list/opened_positions = list()


/obj/machinery/computer/card/Initialize()
	..()
	Radio = new /obj/item/radio(src)
	Radio.listening = FALSE
	Radio.config(list("Command" = 0))
	Radio.follow_target = src

/obj/machinery/computer/card/Destroy()
	QDEL_NULL(Radio)
	return ..()

/obj/machinery/computer/card/proc/is_centcom()
	return FALSE

/obj/machinery/computer/card/proc/is_authenticated(mob/user)
	if(user.can_admin_interact())
		return TRUE
	if(scan)
		return check_access(scan)
	return FALSE

/obj/machinery/computer/card/proc/format_jobs(list/jobs, targetrank, list/jobformats)
	var/list/formatted = list()
	for(var/job in jobs)
		if(job_in_department(SSjobs.GetJob(job)))
			formatted.Add(list(list(
				"display_name" = replacetext(job, " ", "&nbsp;"),
				"target_rank" = targetrank,
				"job" = job,
				"jlinkformat" = jobformats[job] ? jobformats[job] : null)))

	return formatted

/obj/machinery/computer/card/proc/format_job_slots(check_department, is_admin)
	var/list/formatted = list()
	for(var/datum/job/job in SSjobs.occupations)
		if(job_blacklisted_full(job))
			continue
		if(check_department && !job_in_department(job))
			continue
		formatted.Add(list(list(
			"title" = job.title,
			"current_positions" = job.current_positions,
			"total_positions" = job.total_positions,
			"can_open" = can_open_job(job),
			"can_close" = can_close_job(job),
			"can_prioritize" = can_prioritize_job(job, is_admin),
			"is_priority" = (job in SSjobs.prioritized_jobs)
			)))

	return formatted

/obj/machinery/computer/card/proc/format_card_skins(list/card_skins)
	var/list/formatted = list()
	for(var/skin in card_skins)
		formatted.Add(list(list(
			"display_name" = get_skin_desc(skin),
			"skin" = skin)))
	return formatted

/obj/machinery/computer/card/verb/eject_id()
	set category = null
	set name = "Eject ID Card"
	set src in oview(1)

	if(usr.incapacitated())
		return

	if(scan)
		to_chat(usr, "You remove \the [scan] from \the [src].")
		scan.forceMove(get_turf(src))
		if(!usr.get_active_hand() && Adjacent(usr))
			usr.put_in_hands(scan)
		scan = null
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	else if(modify)
		to_chat(usr, "You remove \the [modify] from \the [src].")
		modify.forceMove(get_turf(src))
		if(!usr.get_active_hand() && Adjacent(usr))
			usr.put_in_hands(modify)
		modify = null
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	else
		to_chat(usr, "There is nothing to remove from the console.")

/obj/machinery/computer/card/attackby(obj/item/card/id/id_card, mob/user, params)
	if(!istype(id_card))
		return ..()

	if(!scan && check_access(id_card))
		user.drop_item()
		id_card.forceMove(src)
		scan = id_card
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	else if(!modify)
		user.drop_item()
		id_card.forceMove(src)
		modify = id_card
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)

	SStgui.update_uis(src)
	attack_hand(user)

//Check if you can't touch a job in any way whatsoever
/obj/machinery/computer/card/proc/job_blacklisted_full(datum/job/job)
	return (job.type in blacklisted_full)

//Check if you can't open/close positions for a certain job
/obj/machinery/computer/card/proc/job_blacklisted_partial(datum/job/job)
	return (job.type in blacklisted_partial)

// Logic check for if you can open the job
/obj/machinery/computer/card/proc/can_open_job(datum/job/job)
	if(job)
		if(job_blacklisted_full(job))
			return FALSE
		if(job_blacklisted_partial(job))
			return FALSE
		if(!job_in_department(job, FALSE))
			return FALSE
		if(job.job_banned_gamemode) // you cannot open a slot for more sec/legal after revs win
			return FALSE
		if((job.total_positions > GLOB.player_list.len * (max_relative_positions / 100)))
			return FALSE
		if(opened_positions[job.title] < 0)
			return TRUE
		var/delta = (world.time / 10) - GLOB.time_last_changed_position
		if(change_position_cooldown < delta)
			return TRUE
	return FALSE

// Logic check for if you can close the job
/obj/machinery/computer/card/proc/can_close_job(datum/job/job)
	if(job)
		if(job_blacklisted_full(job))
			return FALSE
		if(job_blacklisted_partial(job))
			return FALSE
		if(!job_in_department(job, FALSE))
			return FALSE
		if(job.job_banned_gamemode) // you cannot edit this slot after revs win
			return FALSE
		if(job in SSjobs.prioritized_jobs) // different to above
			return FALSE
		if(job.total_positions <= job.current_positions) // different to above
			return FALSE
		if(opened_positions[job.title] > 0) // different to above
			return TRUE
		var/delta = (world.time / 10) - GLOB.time_last_changed_position
		if(change_position_cooldown < delta)
			return TRUE
	return FALSE

/obj/machinery/computer/card/proc/can_prioritize_job(datum/job/job, is_admin)
	if(job)
		if(job_blacklisted_full(job))
			return FALSE
		if(!is_admin && !job_in_department(job, FALSE))
			return FALSE
		if(job in SSjobs.prioritized_jobs)
			return TRUE // because this also lets us un-prioritize the job
		if(SSjobs.prioritized_jobs.len >= 3)
			return FALSE
		if(job.total_positions <= job.current_positions)
			return FALSE
		return TRUE
	return FALSE

/obj/machinery/computer/card/proc/has_idchange_access()
	return scan && scan.access && (ACCESS_CHANGE_IDS in scan.access) ? TRUE : FALSE

/obj/machinery/computer/card/proc/job_in_department(datum/job/targetjob, include_assistants = TRUE)
	if(!scan || !scan.access)
		return FALSE
	if(!target_dept)
		return TRUE
	if(!scan.assignment)
		return FALSE
	if(has_idchange_access())
		return TRUE
	if(!targetjob || !targetjob.title)
		return FALSE
	if(targetjob.title in get_subordinates(scan.rank, include_assistants))
		return TRUE
	return FALSE

/obj/machinery/computer/card/proc/get_subordinates(rank, add_assistants)
	var/list/jobs_returned = list()
	for(var/datum/job/thisjob in SSjobs.occupations)
		if(thisjob.title in GLOB.nonhuman_positions) // hides AI from list when Captain ID is inserted into dept console
			continue
		if(rank in thisjob.department_head)
			jobs_returned += thisjob.title
	if(add_assistants)
		jobs_returned += "Assistant"
	return jobs_returned

/obj/machinery/computer/card/proc/get_employees(list/selectedranks)
	var/list/names_returned = list()
	if(isnull(GLOB.data_core.general) || isnull(GLOB.data_core.security))
		return names_returned
	for(var/datum/data/record/R in GLOB.data_core.general)
		if(!R.fields || !R.fields["name"] || !R.fields["real_rank"])
			continue
		if(!(R.fields["real_rank"] in selectedranks))
			continue
		for(var/datum/data/record/E in GLOB.data_core.security)
			if(E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"])
				var/buttontext
				var/isdemotable = FALSE
				if(status_valid_for_demotion(E.fields["criminal"]))
					buttontext = "Demote"
					isdemotable = TRUE
				else if(E.fields["criminal"] == SEC_RECORD_STATUS_DEMOTE)
					buttontext = "Pending Demotion"
				else
					buttontext = "Ineligible"
				names_returned.Add(list(list(
					"name" = E.fields["name"],
					"crimstat" = E.fields["criminal"],
					"title" = R.fields["real_rank"],
					"buttontext" = buttontext,
					"demotable" = isdemotable
				)))
				break
	return names_returned

/obj/machinery/computer/card/proc/status_valid_for_demotion(crimstat)
	if(crimstat in list(SEC_RECORD_STATUS_NONE, SEC_RECORD_STATUS_MONITOR, SEC_RECORD_STATUS_RELEASED, SEC_RECORD_STATUS_SEARCH))
		return TRUE
	return FALSE

/obj/machinery/computer/card/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/card/attack_hand(mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	ui_interact(user)

/obj/machinery/computer/card/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "CardComputer",  name, 800, 800, master_ui, state)
		ui.open()

/obj/machinery/computer/card/ui_data(mob/user)
	var/list/data = list()
	data["mode"] = mode
	data["modify_name"] = modify ? modify.name : FALSE
	data["modify_owner"] = modify && modify.registered_name ? modify.registered_name : "-----"
	data["modify_rank"] = modify?.rank ? modify.rank : FALSE
	data["modify_assignment"] = modify?.assignment ? modify.assignment : "Unassigned"
	data["modify_lastlog"] = modify && modify.lastlog ? modify.lastlog : FALSE
	data["scan_name"] = scan ? scan.name : FALSE
	data["scan_rank"] = scan ? scan.rank : FALSE

	data["authenticated"] = is_authenticated(user) ? TRUE : FALSE
	data["auth_or_ghost"] = data["authenticated"] || isobserver(user)
	data["target_dept"] = target_dept
	data["iscentcom"] = is_centcom() ? TRUE : FALSE
	data["isadmin"] = user.can_admin_interact()

	switch(mode)
		if(IDCOMPUTER_SCREEN_TRANSFER) // JOB TRANSFER
			if(modify)
				if(!scan)
					return data

				data["jobFormats"] = SSjobs.format_jobs_for_id_computer(modify)
				data["jobs_assistant"] = GLOB.assistant_positions
				data["canterminate"] = has_idchange_access()

				if(target_dept)
					data["jobs_dept"] = get_subordinates(scan.rank, FALSE)
				else
					data["account_number"] = modify ? modify.associated_account_number : null
					data["jobs_top"] = list("Captain", "Custom")
					data["jobs_engineering"] = GLOB.engineering_positions
					data["jobs_medical"] = GLOB.medical_positions
					data["jobs_science"] = GLOB.science_positions
					data["jobs_security"] = GLOB.active_security_positions
					data["jobs_service"] = GLOB.service_positions
					data["jobs_supply"] = GLOB.supply_positions - "Head of Personnel"
					data["jobs_centcom"] = get_all_centcom_jobs() + get_all_ERT_jobs()
					data["current_skin"] = modify.icon_state
					data["card_skins"] = format_card_skins(get_station_card_skins())
					data["all_centcom_skins"] = is_centcom() ? format_card_skins(get_centcom_card_skins()) : FALSE

		if(IDCOMPUTER_SCREEN_SLOTS) // JOB SLOTS
			data["job_slots"] = format_job_slots(!isobserver(user), data["isadmin"])
			data["priority_jobs"] = list()
			for(var/datum/job/a in SSjobs.prioritized_jobs)
				data["priority_jobs"] += a.title
			var/time_to_wait = round(change_position_cooldown - ((world.time / 10) - GLOB.time_last_changed_position), 1)
			if(time_to_wait > 0)
				var/mins = round(time_to_wait / 60)
				var/seconds = time_to_wait - (60*mins)
				seconds = (seconds < 10) ? "0[seconds]" : seconds
				data["cooldown_time"] = "[mins]:[seconds]"
			else
				data["cooldown_time"] = FALSE
		if(IDCOMPUTER_SCREEN_ACCESS) // ACCESS CHANGES
			if(modify)
				data["selectedAccess"] = modify.access
				data["regions"] = get_accesslist_static_data(REGION_GENERAL, is_centcom() ? REGION_CENTCOMM : REGION_COMMAND)
		if(IDCOMPUTER_SCREEN_RECORDS) // RECORDS
			if(is_authenticated(user))
				data["records"] = SSjobs.format_job_change_records(data["iscentcom"])
		if(IDCOMPUTER_SCREEN_DEPT) // DEPARTMENT EMPLOYEE LIST
			if(is_authenticated(user) && scan) // .requires both (aghosts don't count)
				data["jobs_dept"] = get_subordinates(scan.rank, FALSE)
				data["people_dept"] = get_employees(data["jobs_dept"])
	return data

/obj/machinery/computer/card/proc/regenerate_id_name()
	if(modify)
		modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")

/obj/machinery/computer/card/ui_act(action, params)
	if(..())
		return
	. = TRUE

	// 1st, handle the functions that require no authorization at all

	switch(action)
		if("scan") // inserting or removing your authorizing ID
			if(scan)
				if(ishuman(usr))
					scan.forceMove(get_turf(src))
					if(Adjacent(usr))
						usr.put_in_hands(scan)
					scan = null
					playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
				else
					scan.forceMove(get_turf(src))
					scan = null
					playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			else if(Adjacent(usr))
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/card/id))
					if(!check_access(I))
						playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
						to_chat(usr, "<span class='warning'>This card does not have access.</span>")
						return FALSE
					usr.drop_item()
					I.forceMove(src)
					scan = I
					playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			return
		if("modify") // inserting or removing the ID you plan to modify
			if(modify)
				GLOB.data_core.manifest_modify(modify.registered_name, modify.assignment)
				regenerate_id_name()
				if(ishuman(usr))
					modify.forceMove(get_turf(src))
					if(Adjacent(usr))
						usr.put_in_hands(modify)
					modify = null
					playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
				else
					modify.forceMove(get_turf(src))
					modify = null
					playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			else if(Adjacent(usr))
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/card/id))
					usr.drop_item()
					I.forceMove(src)
					modify = I
					playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			return
		if("mode") // changing mode in the menu
			mode = text2num(params["mode"])
			return

	// Everything below HERE requires auth
	if(!is_authenticated(usr))
		playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
		to_chat(usr, "<span class='warning'>This function is not available unless you are logged in.</span>")
		return FALSE

	// 2nd, handle the functions that are available to head-level consoles (department consoles)
	switch(action)
		if("assign") // transfer to a new job
			if(!modify)
				return
			var/t1 = params["assign_target"]
			if(target_dept)
				if(modify.assignment == "Demoted" || modify.assignment == "Terminated")
					playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
					visible_message("<span class='warning'>[src]: Reassigning a demoted or terminated individual requires a full ID computer.</span>")
					return FALSE
				if(!job_in_department(SSjobs.GetJob(modify.rank), FALSE))
					playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
					visible_message("<span class='warning'>[src]: Reassigning someone outside your department requires a full ID computer.</span>")
					return FALSE
				if(!job_in_department(SSjobs.GetJob(t1)))
					return FALSE
			if(t1 == "Custom")
				var/temp_t = sanitize(reject_bad_name(copytext_char(input("Enter a custom job assignment.", "Assignment"), 1, MAX_MESSAGE_LEN), TRUE)) // SS220 EDIT - ORIGINAL: copytext
				//let custom jobs function as an impromptu alt title, mainly for sechuds
				if(temp_t && scan && modify)
					var/oldrank = modify.getRankAndAssignment()
					SSjobs.log_job_transfer(modify.registered_name, oldrank, temp_t, scan.registered_name, null)
					modify.lastlog = "[station_time_timestamp()]: Reassigned by \"[scan.registered_name]\" from \"[oldrank]\" to \"[temp_t]\"."
					modify.assignment = temp_t
					log_game("[key_name(usr)] ([scan.assignment]) has reassigned \"[modify.registered_name]\" from \"[oldrank]\" to \"[temp_t]\".")
					SSjobs.notify_dept_head(modify.rank, "[scan.registered_name] has transferred \"[modify.registered_name]\" the \"[oldrank]\" to \"[temp_t]\".")
			else
				var/list/access = list()
				if(is_centcom() && islist(get_centcom_access(t1)))
					access = get_centcom_access(t1)
				else
					var/datum/job/jobdatum
					for(var/jobtype in typesof(/datum/job))
						var/datum/job/J = new jobtype
						if(ckey(J.title) == ckey(t1))
							jobdatum = J
							break
					if(!jobdatum)
						to_chat(usr, "<span class='warning'>No log exists for this job: [t1]</span>")
						return

					access = jobdatum.get_access()

				var/jobnamedata = modify.getRankAndAssignment()
				log_game("[key_name(usr)] ([scan.assignment]) has reassigned \"[modify.registered_name]\" from \"[jobnamedata]\" to \"[t1]\".")
				if(t1 == "Assistant")
					message_admins("[key_name_admin(usr)] has reassigned \"[modify.registered_name]\" from \"[jobnamedata]\" to \"[t1]\".")

				SSjobs.log_job_transfer(modify.registered_name, jobnamedata, t1, scan.registered_name, null)
				modify.lastlog = "[station_time_timestamp()]: Reassigned by \"[scan.registered_name]\" from \"[jobnamedata]\" to \"[t1]\"."
				SSjobs.notify_dept_head(t1, "[scan.registered_name] has transferred \"[modify.registered_name]\" the \"[jobnamedata]\" to \"[t1]\".")
				if(modify.owner_uid)
					SSjobs.slot_job_transfer(modify.rank, t1)

				var/mob/living/carbon/human/H = modify.getPlayer()
				if(istype(H))
					if(jobban_isbanned(H, t1))
						message_admins("[ADMIN_FULLMONTY(H)] has been assigned the job [t1], in possible violation of their job ban.")
					if(H.mind)
						H.mind.playtime_role = t1

				modify.access = access
				modify.rank = t1
				modify.assignment = t1
			regenerate_id_name()
			return
		if("demote")
			if(modify.assignment == "Demoted")
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
				visible_message("<span class='warning'>[src]: Demoted crew cannot be demoted any further. If further action is warranted, ask the Captain about Termination.</span>")
				return FALSE
			if(!job_in_department(SSjobs.GetJob(modify.rank), FALSE))
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
				visible_message("<span class='warning'>[src]: Heads may only demote members of their own department.</span>")
				return FALSE
			var/reason = sanitize(copytext_char(input("Enter legal reason for demotion. Enter nothing to cancel.","Legal Demotion"), 1, MAX_MESSAGE_LEN))	// SS220 EDIT - ORIGINAL: copytext
			if(!reason || !is_authenticated(usr) || !modify)
				return FALSE
			var/list/access = list()
			var/datum/job/jobdatum = new /datum/job/assistant
			access = jobdatum.get_access()
			var/jobnamedata = modify.getRankAndAssignment()
			var/m_ckey = modify.getPlayerCkey()
			var/m_ckey_text = m_ckey ? "([m_ckey])" : "(no ckey)"
			log_game("[key_name(usr)] ([scan.assignment]) has demoted \"[modify.registered_name]\" [m_ckey_text] the \"[jobnamedata]\" for: \"[reason]\".")
			message_admins("[key_name_admin(usr)] has demoted \"[modify.registered_name]\" [m_ckey_text] the \"[jobnamedata]\" for: \"[reason]\".")
			usr.create_log(MISC_LOG, "demoted \"[modify.registered_name]\" [m_ckey_text] the \"[jobnamedata]\"")
			SSjobs.log_job_transfer(modify.registered_name, jobnamedata, "Demoted", scan.registered_name, reason)
			modify.lastlog = "[station_time_timestamp()]: DEMOTED by \"[scan.registered_name]\" ([scan.assignment]) from \"[jobnamedata]\" for: \"[reason]\"."
			SSjobs.notify_dept_head(modify.rank, "[scan.registered_name] ([scan.assignment]) has demoted \"[modify.registered_name]\" ([jobnamedata]) for \"[reason]\".")
			modify.access = access
			modify.rank = "Assistant"
			modify.assignment = "Demoted"
			modify.icon_state = "id"
			regenerate_id_name()
			return
		if("terminate")
			if(!has_idchange_access()) // because captain/HOP can use this even on dept consoles
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
				visible_message("<span class='warning'>[src]: Only the Captain or HOP may completely terminate the employment of a crew member.</span>")
				return FALSE
			var/jobnamedata = modify.getRankAndAssignment()
			var/reason = sanitize(copytext_char(input("Enter legal reason for termination. Enter nothing to cancel.", "Employment Termination"), 1, MAX_MESSAGE_LEN))	// SS220 EDIT - ORIGINAL: copytext
			if(!reason || !has_idchange_access() || !modify)
				return FALSE
			var/m_ckey = modify.getPlayerCkey()
			var/m_ckey_text = m_ckey ? "([m_ckey])" : "(no ckey)"
			log_game("[key_name(usr)] ([scan.assignment]) has terminated \"[modify.registered_name]\" [m_ckey_text] the \"[jobnamedata]\" for: \"[reason]\".")
			message_admins("[key_name_admin(usr)] has terminated \"[modify.registered_name]\" [m_ckey_text] the \"[jobnamedata]\" for: \"[reason]\".")
			usr.create_log(MISC_LOG, "terminated the employment of \"[modify.registered_name]\" [m_ckey_text] the \"[jobnamedata]\"")
			SSjobs.log_job_transfer(modify.registered_name, jobnamedata, "Terminated", scan.registered_name, reason)
			modify.lastlog = "[station_time_timestamp()]: TERMINATED by \"[scan.registered_name]\" ([scan.assignment]) from \"[jobnamedata]\" for: \"[reason]\"."
			SSjobs.notify_dept_head(modify.rank, "[scan.registered_name] ([scan.assignment]) has terminated the employment of \"[modify.registered_name]\" the \"[jobnamedata]\" for \"[reason]\".")
			modify.assignment = "Terminated"
			modify.access = list()
			regenerate_id_name()
			return
		if("make_job_available") // MAKE ANOTHER JOB POSITION AVAILABLE FOR LATE JOINERS
			var/edit_job_target = params["job"]
			var/datum/job/j = SSjobs.GetJob(edit_job_target)
			if(!job_in_department(j, FALSE))
				return FALSE
			if(!j)
				return FALSE
			if(!can_open_job(j))
				return FALSE
			if(opened_positions[edit_job_target] >= 0)
				GLOB.time_last_changed_position = world.time / 10
			j.total_positions++
			opened_positions[edit_job_target]++
			log_game("[key_name(usr)] ([scan.assignment]) has opened a job slot for job \"[j.title]\".")
			message_admins("[key_name_admin(usr)] has opened a job slot for job \"[j.title]\".")
			return
		if("make_job_unavailable") // MAKE JOB POSITION UNAVAILABLE FOR LATE JOINERS
			var/edit_job_target = params["job"]
			var/datum/job/j = SSjobs.GetJob(edit_job_target)
			if(!job_in_department(j, FALSE))
				return FALSE
			if(!j)
				return FALSE
			if(!can_close_job(j))
				return FALSE
			//Allow instant closing without cooldown if a position has been opened before
			if(opened_positions[edit_job_target] <= 0)
				GLOB.time_last_changed_position = world.time / 10
			j.total_positions--
			opened_positions[edit_job_target]--
			log_game("[key_name(usr)] ([scan.assignment]) has closed a job slot for job \"[j.title]\".")
			message_admins("[key_name_admin(usr)] has closed a job slot for job \"[j.title]\".")
			return
		if("remote_demote")
			var/reason = sanitize(copytext_char(input("Enter legal reason for demotion. Enter nothing to cancel.","Legal Demotion"), 1, MAX_MESSAGE_LEN))	// SS220 EDIT - ORIGINAL: copytext
			if(!reason || !is_authenticated(usr) || !scan)
				return FALSE
			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == params["remote_demote"])
					var/datum/job/j = SSjobs.GetJob(E.fields["real_rank"])
					var/tempname = params["remote_demote"]
					var/temprank = E.fields["real_rank"]
					if(!j)
						visible_message("<span class='warning'>[src]: This employee has either no job, or a customized job ([temprank]).</span>")
						return FALSE
					if(!job_in_department(j, FALSE))
						visible_message("<span class='warning'>[src]: Only the head of this employee may demote them.</span>")
						return FALSE
					for(var/datum/data/record/R in GLOB.data_core.security)
						if(R.fields["id"] == E.fields["id"])
							if(status_valid_for_demotion(R.fields["criminal"]))
								set_criminal_status(usr, R, SEC_RECORD_STATUS_DEMOTE, reason, scan.assignment)
								Radio.autosay("[scan.registered_name] ([scan.assignment]) has set [tempname] ([temprank]) to demote for: [reason]", name, "Command", list(z))
								message_admins("[key_name_admin(usr)] ([scan.assignment]) has set [tempname] ([temprank]) to demote for: \"[reason]\"")
								log_game("[key_name(usr)] ([scan.assignment]) has set \"[tempname]\" ([temprank]) to demote for: \"[reason]\".")
								SSjobs.notify_by_name(tempname, "[scan.registered_name] ([scan.assignment]) has ordered your demotion. Report to their office, or the HOP. Reason given: \"[reason]\"")
							else
								playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
								to_chat(usr, "<span class='warning'>[src]: Cannot demote, due to their current security status.</span>")
								return FALSE
							return
			return

	// Everything below here requires a full ID computer (dept consoles do not qualify)
	if(target_dept)
		playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
		to_chat(usr, "<span class='warning'>This function is not available on department-level consoles.</span>")
		return

	// 3rd, handle the functions that require a full ID computer
	switch(action)
		// Changing basic card info
		if("reg") // registered name on card
			var/temp_name = reject_bad_name(input(usr, "Who is this ID for?", "ID Card Renaming", modify.registered_name), TRUE)
			if(!modify || !temp_name)
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
				visible_message("<span class='warning'>[src] buzzes rudely.</span>")
				return FALSE
			modify.registered_name = temp_name
			regenerate_id_name()
			return
		if("account") // card account number
			var/account_num = input(usr, "Account Number", "Input Number", null) as num|null
			if(!scan || !modify)
				return FALSE
			modify.associated_account_number = clamp(round(account_num), 1000000, 9999999) //force a 7 digit number
			//for future reference, you should never be able to modify the money account datum through the card computer
			return
		if("skin")
			if(!modify)
				return FALSE
			var/skin = params["skin_target"]
			var/skin_list = is_centcom() ? get_centcom_card_skins() : get_station_card_skins()
			if(skin in skin_list)
				modify.icon_state = skin
			return
		// Changing card access
		if("set") // add/remove a single access number
			var/access = text2num(params["access"])
			var/list/changable = is_centcom() ? get_all_centcom_access() + get_all_accesses() : get_all_accesses()
			if(access in changable)
				if(access in modify.access)
					modify.access -= access
				else
					modify.access += access
			return
		if("grant_region")
			var/region = text2num(params["region"])
			if(isnull(region) || region < REGION_GENERAL || region > (is_centcom() ? REGION_CENTCOMM : REGION_COMMAND))
				return
			modify.access |= get_region_accesses(region)
			return
		if("deny_region")
			var/region = text2num(params["region"])
			if(isnull(region) || region < REGION_GENERAL || region > (is_centcom() ? REGION_CENTCOMM : REGION_COMMAND))
				return
			modify.access -= get_region_accesses(region)
			return
		if("clear_all")
			modify.access = list()
			return
		if("grant_all")
			modify.access = get_all_accesses()
			return

		// JOB SLOT MANAGEMENT functions

		if("prioritize_job") // TOGGLE WHETHER JOB APPEARS AS PRIORITIZED IN THE LOBBY
			var/priority_target = params["job"]
			var/datum/job/j = SSjobs.GetJob(priority_target)
			if(!j)
				return FALSE
			if(!can_prioritize_job(j, usr.can_admin_interact()))
				return FALSE
			var/priority = TRUE
			if(j in SSjobs.prioritized_jobs)
				SSjobs.prioritized_jobs -= j
				priority = FALSE
			else
				SSjobs.prioritized_jobs += j
			log_game("[key_name(usr)] ([scan ? scan.assignment : "ADMIN"]) [priority ?  "prioritized" : "unprioritized"] the job \"[j.title]\".")
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
			return

		if("wipe_all_logs") // Delete all records from 'records' section
			if(is_authenticated(usr) && !target_dept)
				var/delcount = SSjobs.delete_log_records(scan.registered_name, TRUE)
				if(delcount)
					message_admins("[key_name_admin(usr)] has wiped all ID computer logs.")
					usr.create_log(MISC_LOG, "wiped all ID computer logs.")
					playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
			return

	// Everything below here is exclusive to the CC card computer.
	if(!is_centcom())
		return

	switch(action)
		if("wipe_my_logs")
			var/delcount = SSjobs.delete_log_records(scan.registered_name, FALSE)
			if(delcount)
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)


/obj/machinery/computer/card/centcom
	name = "\improper CentComm identification computer"
	circuit = /obj/item/circuitboard/card/centcom
	req_access = list(ACCESS_CENT_COMMANDER)
	change_position_cooldown = -1
	blacklisted_full = list()
	blacklisted_partial = list()

/obj/machinery/computer/card/centcom/is_centcom()
	return TRUE

/obj/machinery/computer/card/minor
	name = "department management console"
	target_dept = TARGET_DEPT_GENERIC
	desc = "You can use this to change ID's for specific departments."
	icon_screen = "idminor"
	circuit = /obj/item/circuitboard/card/minor

/obj/machinery/computer/card/minor/hos
	name = "security management console"
	target_dept = TARGET_DEPT_SEC
	icon_screen = "idhos"
	light_color = LIGHT_COLOR_RED
	req_access = list(ACCESS_HOS)
	circuit = /obj/item/circuitboard/card/minor/hos

/obj/machinery/computer/card/minor/cmo
	name = "medical management console"
	target_dept = TARGET_DEPT_MED
	icon_screen = "idcmo"
	req_access = list(ACCESS_CMO)
	circuit = /obj/item/circuitboard/card/minor/cmo

/obj/machinery/computer/card/minor/qm
	name = "supply management console"
	target_dept = TARGET_DEPT_SUP
	icon_screen = "idqm"
	light_color = COLOR_BROWN_ORANGE
	req_access = list(ACCESS_QM)
	circuit = /obj/item/circuitboard/card/minor/qm

/obj/machinery/computer/card/minor/rd
	name = "science management console"
	target_dept = TARGET_DEPT_SCI
	icon_screen = "idrd"
	light_color = LIGHT_COLOR_PINK
	req_access = list(ACCESS_RD)
	circuit = /obj/item/circuitboard/card/minor/rd

/obj/machinery/computer/card/minor/ce
	name = "engineering management console"
	target_dept = TARGET_DEPT_ENG
	icon_screen = "idce"
	light_color = COLOR_YELLOW
	req_access = list(ACCESS_CE)
	circuit = /obj/item/circuitboard/card/minor/ce
