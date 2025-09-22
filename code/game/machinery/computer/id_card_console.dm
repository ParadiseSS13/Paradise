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
	var/reset_timer

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
		/datum/job/qm,
		/datum/job/nanotrasentrainer
)

	//The scaling factor of max total positions in relation to the total amount of people on board the station in %
	var/max_relative_positions = 30 //30%: Seems reasonable, limit of 6 @ 20 players

	//This is used to keep track of opened positions for jobs to allow instant closing
	//Assoc array: "JobName" = (int)<Opened Positions>
	var/list/opened_positions = list()


/obj/machinery/computer/card/Initialize(mapload)
	. = ..()
	Radio = new /obj/item/radio(src)
	Radio.listening = FALSE
	Radio.config(list("Command" = 0))
	Radio.follow_target = src

/obj/machinery/computer/card/Destroy()
	QDEL_NULL(Radio)
	return ..()

/obj/machinery/computer/card/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can <b>Alt-Click</b> [src] to remove the ID cards in it.</span>"

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

/proc/format_card_skins(list/card_skins)
	var/list/formatted = list()
	for(var/skin in card_skins)
		formatted.Add(list(list(
			"display_name" = get_skin_desc(skin),
			"skin" = skin)))
	return formatted

/obj/machinery/computer/card/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(scan)
		to_chat(user, "<span class='notice'>You remove \the [scan] from \the [src].</span>")
		if(!user.get_active_hand())
			user.put_in_hands(scan)
		else if(!user.put_in_inactive_hand(scan))
			scan.forceMove(get_turf(src))
		scan = null
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
		SStgui.update_uis(src)
		return
	else if(modify)
		to_chat(user, "<span class='notice'>You remove \the [modify] from \the [src].</span>")
		if(!user.get_active_hand())
			user.put_in_hands(modify)
		else if(!user.put_in_inactive_hand(modify))
			modify.forceMove(get_turf(src))
		modify = null
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
		SStgui.update_uis(src)
	else
		to_chat(user, "There is nothing to remove from the console.")

/obj/machinery/computer/card/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	var/obj/item/card/id/id_card = used
	if(!istype(id_card))
		return ..()
	if(istype(id_card, /obj/item/card/id/nct_data_chip))
		return ..()

	if(!scan && check_access(id_card))
		user.drop_item()
		id_card.forceMove(src)
		scan = id_card
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	else if(!modify)
		user.drop_item()
		id_card.forceMove(src)
		modify = id_card
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

	SStgui.update_uis(src)
	attack_hand(user)

	return ITEM_INTERACT_COMPLETE

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
		if((job.total_positions > length(GLOB.player_list) * (max_relative_positions / 100)))
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
		if(length(SSjobs.prioritized_jobs) >= 3)
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

/obj/machinery/computer/card/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/card/proc/change_ui_autoupdate(value, mob/user)
	var/datum/tgui/ui = SStgui.try_update_ui(user, src)
	reset_timer = null
	if(ui)
		ui.set_autoupdate(value)

/obj/machinery/computer/card/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CardComputer",  name)
		var/delta = (world.time / 10) - GLOB.time_last_changed_position
		if(change_position_cooldown < delta && !reset_timer)
			ui.set_autoupdate(FALSE)
		else
			reset_timer = addtimer(CALLBACK(src, PROC_REF(change_ui_autoupdate), FALSE, user), delta SECONDS)
		ui.open()

/obj/machinery/computer/card/ui_data(mob/user)
	var/list/data = list()
	data["mode"] = mode

	// slam in nulls because UIs that aren't autoupdate can get weird about
	// refreshing data even at the points when it's supposed to (like on UI
	// interactions)
	data["modifying_card"] = modify?.to_tgui()
	data["scanned_card"] = scan?.to_tgui()

	data["authenticated"] = is_authenticated(user) ? TRUE : FALSE
	data["auth_or_ghost"] = data["authenticated"] || isobserver(user)
	data["target_dept"] = target_dept
	data["is_centcom"] = is_centcom() ? TRUE : FALSE

	switch(mode)
		if(IDCOMPUTER_SCREEN_TRANSFER) // JOB TRANSFER
			if(modify)
				if(!scan)
					return data

				data["job_formats"] = SSjobs.format_jobs_for_id_computer(modify)
				data["can_terminate"] = has_idchange_access()

				if(target_dept)
					data["jobs_dept"] = get_subordinates(scan.rank, FALSE)
				else
					data["jobs"] = SSjobs.get_job_titles_for_id_computer()
					data["card_skins"] = format_card_skins(get_station_card_skins())
					data["all_centcom_skins"] = is_centcom() ? format_card_skins(get_centcom_card_skins()) : FALSE

		if(IDCOMPUTER_SCREEN_SLOTS) // JOB SLOTS
			data["job_slots"] = format_job_slots(!isobserver(user), user.can_admin_interact())
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
				data["records"] = SSjobs.format_job_change_records(data["is_centcom"])
		if(IDCOMPUTER_SCREEN_DEPT) // DEPARTMENT EMPLOYEE LIST
			if(is_authenticated(user) && scan) // .requires both (aghosts don't count)
				data["jobs_dept"] = get_subordinates(scan.rank, FALSE)
				data["people_dept"] = get_employees(data["jobs_dept"])
	return data

/obj/machinery/computer/card/proc/regenerate_id_name()
	if(modify)
		modify.regenerate_name()

/obj/machinery/computer/card/proc/eject_card(mob/user, obj/card)
	if(ishuman(user))
		card.forceMove(get_turf(user))
		if(Adjacent(user))
			user.put_in_hands(card)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	else
		card.forceMove(get_turf(src))
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

/obj/machinery/computer/card/proc/interact_modify(mob/user)
	if(modify)
		GLOB.data_core.manifest_modify(modify.registered_name, modify.assignment)
		regenerate_id_name()
		eject_card(user, modify)
		modify = null
	else if(Adjacent(usr))
		var/obj/item/I = usr.get_active_hand()
		if(istype(I, /obj/item/card/id))
			if(istype(I, /obj/item/card/id/nct_data_chip))
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, FALSE)
				to_chat(usr, "<span class='warning'>The data chip doesn't fit!</span>")
				return FALSE
			usr.drop_item()
			I.forceMove(src)
			modify = I
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

/obj/machinery/computer/card/proc/interact_scanned(mob/user)
	if(scan)
		eject_card(user, scan)
		scan = null
	else if(Adjacent(usr))
		var/obj/item/I = usr.get_active_hand()
		if(istype(I, /obj/item/card/id))
			if(istype(I, /obj/item/card/id/nct_data_chip))
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, FALSE)
				to_chat(usr, "<span class='warning'>The data chip doesn't fit!</span>")
				return FALSE
			if(!check_access(I))
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, FALSE)
				to_chat(usr, "<span class='warning'>This card does not have access.</span>")
				return FALSE
			usr.drop_item()
			I.forceMove(src)
			scan = I
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

/obj/machinery/computer/card/ui_act(action, params)
	if(..())
		return
	. = TRUE

	// 1st, handle the functions that require no authorization at all
	switch(action)
		if("interact_modify") // inserting or removing the card being modified
			interact_modify(usr)
			return
		if("interact_scanned") // inserting or removing the card with your access credentials
			interact_scanned(usr)
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
				var/temp_t = sanitize(reject_bad_name(copytext_char(input("Enter a custom job assignment.", "Assignment"), 1, MAX_MESSAGE_LEN), TRUE))
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
				var/datum/job/jobdatum
				if(is_centcom() && islist(get_centcom_access(t1)))
					access = get_centcom_access(t1)
				else
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
				var/datum/money_account/account = modify.get_card_account()
				if(account && jobdatum)
					account.payday_amount = jobdatum.standard_paycheck

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
			modify.RebuildHTML()
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
			var/reason = sanitize(copytext_char(input("Enter legal reason for demotion. Enter nothing to cancel.","Legal Demotion"), 1, MAX_MESSAGE_LEN))
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
			SSjobs.slot_job_transfer(modify.rank, "Assistant")
			var/datum/money_account/account = modify.get_card_account()
			if(account)
				account.payday_amount = jobdatum.standard_paycheck
			modify.access = access
			modify.assignment = "Demoted"
			modify.icon_state = "id"
			modify.rank = "Assistant"
			regenerate_id_name()
			modify.RebuildHTML()
			return
		if("terminate")
			if(!has_idchange_access()) // because captain/HOP can use this even on dept consoles
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 0)
				visible_message("<span class='warning'>[src]: Only the Captain or HOP may completely terminate the employment of a crew member.</span>")
				return FALSE
			var/jobnamedata = modify.getRankAndAssignment()
			var/reason = sanitize(copytext_char(input("Enter legal reason for termination. Enter nothing to cancel.", "Employment Termination"), 1, MAX_MESSAGE_LEN))
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
			var/datum/job/job = SSjobs.GetJob(modify.rank)
			if(modify.assignment != "Demoted" && !(job.title in GLOB.command_positions))
				job.current_positions--
			var/datum/money_account/account = modify.get_card_account()
			if(account)
				account.payday_amount = 0
			modify.assignment = "Terminated"
			modify.access = list()
			modify.rank = "Terminated"
			regenerate_id_name()
			modify.RebuildHTML()
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
				change_ui_autoupdate(TRUE, usr)
				reset_timer = addtimer(CALLBACK(src, PROC_REF(change_ui_autoupdate), FALSE, usr), GLOB.time_last_changed_position SECONDS)

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
				change_ui_autoupdate(TRUE, usr)
				reset_timer = addtimer(CALLBACK(src, PROC_REF(change_ui_autoupdate), FALSE, usr), (GLOB.time_last_changed_position + 1) SECONDS)
			j.total_positions--
			opened_positions[edit_job_target]--
			log_game("[key_name(usr)] ([scan.assignment]) has closed a job slot for job \"[j.title]\".")
			message_admins("[key_name_admin(usr)] has closed a job slot for job \"[j.title]\".")
			return
		if("remote_demote")
			var/reason = sanitize(copytext_char(input("Enter legal reason for demotion. Enter nothing to cancel.","Legal Demotion"), 1, MAX_MESSAGE_LEN))
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
								Radio.autosay("[scan.registered_name] ([scan.assignment]) has set [tempname] ([temprank]) to demote for: [reason]", name, "Command")
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
		if("set_card_account_number") // card account number
			var/account_num = tgui_input_number(usr, "Account Number", "Input Number", modify.associated_account_number, 9999999, 1000000)
			if(isnull(account_num) || !scan || !modify)
				return FALSE
			modify.associated_account_number = account_num
			//for future reference, you should never be able to modify the money account datum through the card computer
			return
		if("set_card_skin")
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
			modify.access |= get_all_accesses()
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

#undef IDCOMPUTER_SCREEN_TRANSFER
#undef IDCOMPUTER_SCREEN_SLOTS
#undef IDCOMPUTER_SCREEN_ACCESS
#undef IDCOMPUTER_SCREEN_RECORDS
#undef IDCOMPUTER_SCREEN_DEPT
