/datum/ui_module/ds_manager
	name = "DS Manager"
	var/leader_slot = 1
	var/squad_slots = 5
	var/safety = TRUE
	var/mission = "<br>#1 Work as a team.<br>#2 Accomplish your objective at all costs.<br>#3 Leave no witnesses." //default mission

/datum/ui_module/ds_manager/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "DSManager", name, 450, 370, master_ui, state)
		ui.autoupdate = TRUE
		ui.open()

/datum/ui_module/ds_manager/ui_data(mob/user)
	var/list/data = list()
	data["str_security_level"] = capitalize(get_security_level())
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			data["security_level_color"] = "green"
		if(SEC_LEVEL_BLUE)
			data["security_level_color"] = "blue"
		if(SEC_LEVEL_RED)
			data["security_level_color"] = "red"
		else
			data["security_level_color"] = "purple"
	data["lead"] = leader_slot
	data["squad"] = squad_slots
	data["total"] = leader_slot + squad_slots
	data["spawnpoints"] = GLOB.emergencyresponseteamspawn.len
	data["safety"] = safety
	return data

/datum/ui_module/ds_manager/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("toggle_lead")
			leader_slot = leader_slot ? 0 : 1
		if("set_squad")
			squad_slots = text2num(params["set_sec"])
		if("toggle_safety")
			safety = !(safety)
			if ("safety" = TRUE)
				message_admins("<span class='notice'>[key_name_admin(usr)] has preparing to send a Deathsquad.</span>", 1)
		if("dispatch_ds")
			safety = !(safety)
			var/slots_list = list()
			if(leader_slot > 0)
				slots_list += "commander: [leader_slot]"
			if(squad_slots > 0)
				slots_list += "security: [squad_slots]"
			var/slot_text = english_list(slots_list)
			if(alert("Do you want to send in the CentComm death squad? Once enabled, this is irreversible.",,"Yes","No")!="Yes")
				return
			alert("This 'mode' will go on until everyone is dead or the station is destroyed. You may also admin-call the evac shuttle when appropriate. Spawned commandos have internals cameras which are viewable through a monitor inside the Spec. Ops. Office. The first one selected/spawned will be the team leader.")

			var/input = "<br>#1 Work as a team.<br>#2 Accomplish your objective at all costs.<br>#3 Leave no witnesses." //default mission
			while(!input)
				input = sanitize(copytext(input(src, "Please specify which mission the deathsquad shall undertake.", "Specify Mission", ""),1,MAX_MESSAGE_LEN))
				if(!input)
					if(alert("Error, no mission set. Do you want to exit the setup process?",,"Yes","No")=="Yes")
						return
			notify_ghosts("A Deathsquad is being dispatched. Open positions: [slot_text]")
			message_admins("[key_name_admin(usr)] dispatched a Deathsquad. Slots: [slot_text]", 1)
			log_admin("[key_name(usr)] dispatched a Deathsquad. Slots: [slot_text]")
			// Find ghosts willing to be DS
			var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_deathsquad")
			var/list/commando_ghosts = pollCandidatesWithVeto(src, usr, COMMANDOS_POSSIBLE, "Join the DeathSquad?",, 21, 60 SECONDS, TRUE, GLOB.role_playtime_requirements[ROLE_DEATHSQUAD], TRUE, FALSE, source = source)
			if(!length(commando_ghosts))
				to_chat(usr, "<span class='userdanger'>Nobody volunteered to join the DeathSquad.</span>")
				return
			trigger_deathsquad(leader_slot, squad_slots, mission, commando_ghosts)
		else
			return FALSE
