/datum/event/shuttle_loan
	name = "Shuttle Loan"
	announceWhen = 1
	endWhen = 500
	/// what type of shuttle loan situation the station faces.
	var/datum/shuttle_loan_situation/situation
	/// Whether the station has let Centcom commandeer the shuttle yet.
	var/dispatched = FALSE
	/// How many times can it try to take the shuttle before it gives up and rerolls?
	var/dispatch_attempts = 3

/datum/event/shuttle_loan/setup()
	var/situation_type = pick(subtypesof(/datum/shuttle_loan_situation))
	situation = new situation_type
	if(!SSshuttle.supply.canMove())
		log_debug("Shuttle loan event fired while shuttle cannot move. Reattempting in 30s.")
		if(dispatch_attempts)
			dispatch_attempts--
			addtimer(CALLBACK(src, PROC_REF(setup)), 30 SECONDS)
			return
		// Failed to run, reroll a new moderate in 60 seconds
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MODERATE]
		EC.next_event_time = world.time + (60 SECONDS)
		endWhen = activeFor
		return
	if(SSshuttle.supply.getDockedId() == "supply_home")
		SSshuttle.supply.dock(SSshuttle.getDock("supply_away"))
	addtimer(CALLBACK(src, PROC_REF(loan_shuttle)), 5 SECONDS) // Needed to prevent a runtime in SSshuttle

/datum/event/shuttle_loan/fake_announce()
	. = TRUE
	situation = pick(subtypesof(/datum/shuttle_loan_situation))
	GLOB.minor_announcement.Announce("Cargo: [situation.announcement_text]", situation.sender)

/datum/event/shuttle_loan/proc/loan_shuttle()
	SSshuttle.shuttle_loan_UID = UID()
	SSblackbox.record_feedback("tally", "Shuttle Loan Event Type", 1, situation.type)
	GLOB.minor_announcement.Announce("Cargo: [situation.announcement_text]", situation.sender)
	log_debug("Shuttle loan event firing with type '[situation.logging_desc]'.")

	dispatched = TRUE
	GLOB.station_money_database.credit_account(SSeconomy.cargo_account, situation.bonus_points, "Central Command Cargo Shuttle Reimbursement", "Central Command Supply Master", supress_log = FALSE)
	SSshuttle.supply.request(SSshuttle.getDock("supply_home"))
	SSshuttle.supply.setTimer(5 MINUTES)
	SSshuttle.supply.mode = SHUTTLE_CALL
	endWhen = activeFor + 1

/datum/event/shuttle_loan/tick()
	if(dispatched)
		if(SSshuttle.supply.mode != SHUTTLE_IDLE)
			endWhen = activeFor
		else
			endWhen = activeFor + 1

/datum/event/shuttle_loan/end()
	if(!SSshuttle.shuttle_loan_UID)
		return
	var/datum/event/shuttle_loan/shuttle_loan = locateUID(SSshuttle.shuttle_loan_UID)
	if(!shuttle_loan.dispatched)
		return
