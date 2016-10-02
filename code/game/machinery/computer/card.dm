//Keeps track of the time for the ID console. Having it as a global variable prevents people from dismantling/reassembling it to
//increase the slots of many jobs.
var/time_last_changed_position = 0

/obj/machinery/computer/card
	name = "identification computer"
	desc = "Terminal for programming Nanotrasen employee ID cards to access parts of the station."
	icon_keyboard = "id_key"
	icon_screen = "id"
	req_access = list(access_change_ids)
	circuit = /obj/item/weapon/circuitboard/card
	light_color = LIGHT_COLOR_LIGHTBLUE
	var/obj/item/weapon/card/id/scan = null
	var/obj/item/weapon/card/id/modify = null
	var/mode = 0.0
	var/printing = null

	//Cooldown for closing positions in seconds
	//if set to -1: No cooldown... probably a bad idea
	//if set to 0: Not able to close "original" positions. You can only close positions that you have opened before
	var/change_position_cooldown = 60
	//Jobs you cannot open new positions for
	var/list/blacklisted = list(
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
		/datum/job/pilot,
		/datum/job/brigdoc,
		/datum/job/mechanic,
		/datum/job/barber,
		/datum/job/chaplain,
		/datum/job/ntnavyofficer,
		/datum/job/ntspecops,
		/datum/job/civilian
	)

	//The scaling factor of max total positions in relation to the total amount of people on board the station in %
	var/max_relative_positions = 30 //30%: Seems reasonable, limit of 6 @ 20 players

	//This is used to keep track of opened positions for jobs to allow instant closing
	//Assoc array: "JobName" = (int)<Opened Positions>
	var/list/opened_positions = list();

/obj/machinery/computer/card/proc/is_centcom()
	return istype(src, /obj/machinery/computer/card/centcom)

/obj/machinery/computer/card/proc/is_authenticated(var/mob/user)
	if(user.can_admin_interact())
		return 1
	if(scan)
		return check_access(scan)
	return 0

/obj/machinery/computer/card/proc/get_target_rank()
	return modify && modify.assignment ? modify.assignment : "Unassigned"

/obj/machinery/computer/card/proc/format_jobs(list/jobs)
	var/list/formatted = list()
	for(var/job in jobs)
		formatted.Add(list(list(
			"display_name" = replacetext(job, " ", "&nbsp;"),
			"target_rank" = get_target_rank(),
			"job" = job)))

	return formatted

/obj/machinery/computer/card/proc/format_job_slots()
	var/list/formatted = list()
	for(var/datum/job/job in job_master.occupations)
		if(job_blacklisted(job))
			continue
		formatted.Add(list(list(
			"title" = job.title,
			"current_positions" = job.current_positions,
			"total_positions" = job.total_positions,
			"can_open" = can_open_job(job),
			"can_close" = can_close_job(job))))

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

	if(!usr || usr.stat || usr.lying)	return

	if(scan)
		to_chat(usr, "You remove \the [scan] from \the [src].")
		scan.loc = get_turf(src)
		if(!usr.get_active_hand())
			usr.put_in_hands(scan)
		scan = null
	else if(modify)
		to_chat(usr, "You remove \the [modify] from \the [src].")
		modify.loc = get_turf(src)
		if(!usr.get_active_hand())
			usr.put_in_hands(modify)
		modify = null
	else
		to_chat(usr, "There is nothing to remove from the console.")
	return

/obj/machinery/computer/card/attackby(obj/item/weapon/card/id/id_card, mob/user, params)
	if(!istype(id_card))
		return ..()

	if(!scan && access_change_ids in id_card.access)
		user.drop_item()
		id_card.loc = src
		scan = id_card
	else if(!modify)
		user.drop_item()
		id_card.loc = src
		modify = id_card

	nanomanager.update_uis(src)
	attack_hand(user)

//Check if you can't open a new position for a certain job
/obj/machinery/computer/card/proc/job_blacklisted(datum/job/job)
	return (job.type in blacklisted)

//Logic check for Topic() if you can open the job
/obj/machinery/computer/card/proc/can_open_job(datum/job/job)
	if(job)
		if(!job_blacklisted(job))
			if((job.total_positions <= player_list.len * (max_relative_positions / 100)))
				var/delta = (world.time / 10) - time_last_changed_position
				if((change_position_cooldown < delta) || (opened_positions[job.title] < 0))
					return 1
				return -2
			return -1
	return 0

//Logic check for Topic() if you can close the job
/obj/machinery/computer/card/proc/can_close_job(datum/job/job)
	if(job)
		if(!job_blacklisted(job))
			if(job.total_positions > job.current_positions)
				var/delta = (world.time / 10) - time_last_changed_position
				if((change_position_cooldown < delta) || (opened_positions[job.title] > 0))
					return 1
				return -2
			return -1
	return 0

/obj/machinery/computer/card/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/card/attack_hand(mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	ui_interact(user)

/obj/machinery/computer/card/ui_interact(mob/user, ui_key="main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)

	var/data[0]
	data["src"] = UID()
	data["station_name"] = station_name()
	data["mode"] = mode
	data["printing"] = printing
	data["manifest"] = data_core ? data_core.get_manifest(0) : null
	data["target_name"] = modify ? modify.name : "-----"
	data["target_owner"] = modify && modify.registered_name ? modify.registered_name : "-----"
	data["target_rank"] = get_target_rank()
	data["scan_name"] = scan ? scan.name : "-----"
	data["authenticated"] = is_authenticated(user)
	data["has_modify"] = !!modify
	data["account_number"] = modify ? modify.associated_account_number : null
	data["centcom_access"] = is_centcom()
	data["all_centcom_access"] = null
	data["regions"] = null

	data["engineering_jobs"] = format_jobs(engineering_positions)
	data["medical_jobs"] = format_jobs(medical_positions)
	data["science_jobs"] = format_jobs(science_positions)
	data["security_jobs"] = format_jobs(security_positions)
	data["support_jobs"] = format_jobs(support_positions)
	data["civilian_jobs"] = format_jobs(civilian_positions)
	data["special_jobs"] = format_jobs(whitelisted_positions)
	data["centcom_jobs"] = format_jobs(get_all_centcom_jobs())
	data["card_skins"] = format_card_skins(get_station_card_skins())

	data["job_slots"] = format_job_slots()

	var/time_to_wait = round(change_position_cooldown - ((world.time / 10) - time_last_changed_position), 1)
	var/mins = round(time_to_wait / 60)
	var/seconds = time_to_wait - (60*mins)
	data["cooldown_mins"] = mins
	data["cooldown_secs"] = (seconds < 10) ? "0[seconds]" : seconds

	if(modify)
		data["current_skin"] = modify.icon_state

	if(modify && is_centcom())
		var/list/all_centcom_access = list()
		for(var/access in get_all_centcom_access())
			all_centcom_access.Add(list(list(
				"desc" = replacetext(get_centcom_access_desc(access), " ", "&nbsp;"),
				"ref" = access,
				"allowed" = (access in modify.access) ? 1 : 0)))

		data["all_centcom_access"] = all_centcom_access
		data["all_centcom_skins"] = format_card_skins(get_centcom_card_skins())

	else if(modify)
		var/list/regions = list()
		for(var/i = 1; i <= 7; i++)
			var/list/accesses = list()
			for(var/access in get_region_accesses(i))
				if(get_access_desc(access))
					accesses.Add(list(list(
						"desc" = replacetext(get_access_desc(access), " ", "&nbsp;"),
						"ref" = access,
						"allowed" = (access in modify.access) ? 1 : 0)))

			regions.Add(list(list(
				"name" = get_region_accesses_name(i),
				"accesses" = accesses)))

		data["regions"] = regions

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "identification_computer.tmpl", src.name, 775, 700)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/card/Topic(href, href_list)
	if(..())
		return 1

	switch(href_list["choice"])
		if("modify")
			if(modify)
				data_core.manifest_modify(modify.registered_name, modify.assignment)
				modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")
				if(ishuman(usr))
					modify.loc = usr.loc
					if(!usr.get_active_hand())
						usr.put_in_hands(modify)
					modify = null
				else
					modify.loc = loc
					modify = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I.loc = src
					modify = I

		if("scan")
			if(scan)
				if(ishuman(usr))
					scan.loc = usr.loc
					if(!usr.get_active_hand())
						usr.put_in_hands(scan)
					scan = null
				else
					scan.loc = src.loc
					scan = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I.loc = src
					scan = I

		if("access")
			if(href_list["allowed"])
				if(is_authenticated(usr))
					var/access_type = text2num(href_list["access_target"])
					var/access_allowed = text2num(href_list["allowed"])
					if(access_type in (is_centcom() ? get_all_centcom_access() : get_all_accesses()))
						modify.access -= access_type
						if(!access_allowed)
							modify.access += access_type

		if("skin")
			var/skin = href_list["skin_target"]
			if(is_authenticated(usr) && modify && ((skin in get_station_card_skins()) || ((skin in get_centcom_card_skins()) && is_centcom())))
				modify.icon_state = href_list["skin_target"]

		if("assign")
			if(is_authenticated(usr) && modify)
				var/t1 = href_list["assign_target"]
				if(t1 == "Custom")
					var/temp_t = sanitize(copytext(input("Enter a custom job assignment.","Assignment"),1,MAX_MESSAGE_LEN))
					//let custom jobs function as an impromptu alt title, mainly for sechuds
					if(temp_t && modify)
						modify.assignment = temp_t
				else
					var/list/access = list()
					if(is_centcom())
						access = get_centcom_access(t1)
					else
						var/datum/job/jobdatum
						for(var/jobtype in typesof(/datum/job))
							var/datum/job/J = new jobtype
							if(ckey(J.title) == ckey(t1))
								jobdatum = J
								break
						if(!jobdatum)
							to_chat(usr, "\red No log exists for this job: [t1]")
							return

						access = jobdatum.get_access()

					modify.access = access
					modify.assignment = t1
					modify.rank = t1

				callHook("reassign_employee", list(modify))

		if("reg")
			if(is_authenticated(usr))
				var/t2 = modify
				if((modify == t2 && (in_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(loc, /turf)))
					var/temp_name = reject_bad_name(href_list["reg"])
					if(temp_name)
						modify.registered_name = temp_name
					else
						src.visible_message("<span class='notice'>[src] buzzes rudely.</span>")
			nanomanager.update_uis(src)

		if("account")
			if(is_authenticated(usr))
				var/t2 = modify
				if((modify == t2 && (in_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(loc, /turf)))
					var/account_num = text2num(href_list["account"])
					modify.associated_account_number = account_num
			nanomanager.update_uis(src)

		if("mode")
			mode = text2num(href_list["mode_target"])

		if("print")
			if(!printing)
				printing = 1
				playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
				spawn(50)
					printing = null
					nanomanager.update_uis(src)

					var/obj/item/weapon/paper/P = new(loc)
					if(mode == 2)
						P.name = text("crew manifest ([])", worldtime2text())
						P.info = {"<h4>Crew Manifest</h4>
							<br>
							[data_core ? data_core.get_manifest(0) : ""]
						"}
					else if(modify && !mode)
						P.name = "access report"
						P.info = {"<h4>Access Report</h4>
							<u>Prepared By:</u> [scan && scan.registered_name ? scan.registered_name : "Unknown"]<br>
							<u>For:</u> [modify.registered_name ? modify.registered_name : "Unregistered"]<br>
							<hr>
							<u>Assignment:</u> [modify.assignment]<br>
							<u>Account Number:</u> #[modify.associated_account_number]<br>
							<u>Blood Type:</u> [modify.blood_type]<br><br>
							<u>Access:</u><div style="margin-left:1em">
						"}

						var/first = 1
						for(var/A in modify.access)
							P.info += "[first ? "" : ", "][get_access_desc(A)]"
							first = 0
						P.info += "</div>"

		if("terminate")
			if(is_authenticated(usr))
				modify.assignment = "Terminated"
				modify.access = list()

				callHook("terminate_employee", list(modify))

		if("make_job_available")
			// MAKE ANOTHER JOB POSITION AVAILABLE FOR LATE JOINERS
			if(is_authenticated(usr))
				var/edit_job_target = href_list["job"]
				var/datum/job/j = job_master.GetJob(edit_job_target)
				if(!j)
					return 0
				if(can_open_job(j) != 1)
					return 0
				if(opened_positions[edit_job_target] >= 0)
					time_last_changed_position = world.time / 10
				j.total_positions++
				opened_positions[edit_job_target]++
				nanomanager.update_uis(src)

		if("make_job_unavailable")
			// MAKE JOB POSITION UNAVAILABLE FOR LATE JOINERS
			if(is_authenticated(usr))
				var/edit_job_target = href_list["job"]
				var/datum/job/j = job_master.GetJob(edit_job_target)
				if(!j)
					return 0
				if(can_close_job(j) != 1)
					return 0
				//Allow instant closing without cooldown if a position has been opened before
				if(opened_positions[edit_job_target] <= 0)
					time_last_changed_position = world.time / 10
				j.total_positions--
				opened_positions[edit_job_target]--
				nanomanager.update_uis(src)

	if(modify)
		modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")

	return 1

/obj/machinery/computer/card/centcom
	name = "\improper CentComm identification computer"
	circuit = /obj/item/weapon/circuitboard/card/centcom
	req_access = list(access_cent_commander)
