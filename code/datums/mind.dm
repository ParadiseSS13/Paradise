/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse

	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:

			mind.transfer_to(new_mob)

	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
		the player.

	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.

			new_mob.key = key

		The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.

*/

/datum/mind
	var/key
	var/name				//replaces mob/var/original_name
	var/mob/living/current
	var/mob/living/original	//TODO: remove.not used in any meaningful way ~Carn. First I'll need to tweak the way silicon-mobs handle minds.
	var/active = 0

	var/memory

	var/assigned_role
	var/special_role
	var/list/restricted_roles = list()

	var/list/spell_list = list() // Wizard mode & "Give Spell" badmin button.

	var/role_alt_title

	var/datum/job/assigned_job
	var/list/kills=list()
	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	var/miming = 0 // Mime's vow of silence
	var/datum/faction/faction 			//associated faction
	var/datum/changeling/changeling		//changeling holder
	var/datum/vampire/vampire			//vampire holder
	var/datum/nations/nation			//nation holder
	var/datum/abductor/abductor			//abductor holder

	var/antag_hud_icon_state = null //this mind's ANTAG_HUD should have this icon_state
	var/datum/atom_hud/antag/antag_hud = null //this mind's antag HUD
	var/datum/mindslaves/som //stands for slave or master...hush..

	var/rev_cooldown = 0

	// the world.time since the mob has been brigged, or -1 if not at all
	var/brigged_since = -1

	New(var/key)
		src.key = key

	//put this here for easier tracking ingame
	var/datum/money_account/initial_account

/datum/mind/proc/transfer_to(mob/living/new_character)
	if(!istype(new_character))
		log_to_dd("## DEBUG: transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob. Please inform Carn")
	if(current)					//remove ourself from our old body's mind variable
		current.mind = null

		nanomanager.user_transferred(current, new_character)

	if(new_character.mind)		//remove any mind currently in our new body's mind variable
		new_character.mind.current = null
	var/datum/atom_hud/antag/hud_to_transfer = antag_hud//we need this because leave_hud() will clear this list
	leave_all_huds()									//leave all the huds in the old body, so it won't get huds if somebody else enters it
	current = new_character		//link ourself to our new body
	new_character.mind = src	//and link our new body to ourself
	transfer_antag_huds(hud_to_transfer)				//inherit the antag HUD
	transfer_actions(new_character)

	if(active)
		new_character.key = key		//now transfer the key to link the client to our new body

/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<BR>"

/datum/mind/proc/wipe_memory()
	memory = null

/datum/mind/proc/show_memory(mob/recipient)
	var/output = "<B>[current.real_name]'s Memory</B><HR>"
	output += memory

	if(objectives.len>0)
		output += "<HR><B>Objectives:</B>"

		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++

	if(job_objectives.len>0)
		output += "<HR><B>Job Objectives:</B><UL>"

		var/obj_count = 1
		for(var/datum/job_objective/objective in job_objectives)
			output += "<LI><B>Task #[obj_count]</B>: [objective.get_description()]</LI>"
			obj_count++
		output += "</UL>"

	recipient << browse(output,"window=memory")

/datum/mind/proc/edit_memory()
	if(!ticker || !ticker.mode)
		alert("Not before round-start!", "Alert")
		return

	var/out = "<B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""]<br>"
	out += "Mind currently owned by key: [key] [active?"(synced)":"(not synced)"]<br>"
	out += "Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>"
	out += "Factions and special roles:<br>"

	var/list/sections = list(
		"implant",
		"revolution",
		"cult",
		"wizard",
		"changeling",
		"vampire", // "traitorvamp",
		"nuclear",
		"traitor", // "traitorchan",
		"malfunction",
	)
	var/text = ""
	var/mob/living/carbon/human/H = current
	if(istype(current, /mob/living/carbon/human))
		/** Impanted**/
		if(isloyal(H))
			text = "Mindshield Implant:<a href='?src=\ref[src];implant=remove'>Remove</a>|<b>Implanted</b></br>"
		else
			text = "Mindshield Implant:<b>No Implant</b>|<a href='?src=\ref[src];implant=add'>Implant him!</a></br>"
		sections["implant"] = text
		/** REVOLUTION ***/
		text = "revolution"
		if(ticker.mode.config_tag=="revolution")
			text += uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(isloyal(H))
			text += "<b>LOYAL EMPLOYEE</b>|headrev|rev"
		else if(src in ticker.mode.head_revolutionaries)
			text = "<a href='?src=\ref[src];revolution=clear'>employee</a>|<b>HEADREV</b>|<a href='?src=\ref[src];revolution=rev'>rev</a>"
			text += "<br>Flash: <a href='?src=\ref[src];revolution=flash'>give</a>"

			var/list/L = current.get_contents()
			var/obj/item/device/flash/flash = locate() in L
			if(flash)
				if(!flash.broken)
					text += "|<a href='?src=\ref[src];revolution=takeflash'>take</a>."
				else
					text += "|<a href='?src=\ref[src];revolution=takeflash'>take</a>|<a href='?src=\ref[src];revolution=repairflash'>repair</a>."
			else
				text += "."

			text += " <a href='?src=\ref[src];revolution=reequip'>Reequip</a> (gives traitor uplink)."
			if(objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];revolution=autoobjectives'>Set to kill all heads</a>."
		else if(src in ticker.mode.revolutionaries)
			text += "<a href='?src=\ref[src];revolution=clear'>employee</a>|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|<b>REV</b>"
		else
			text += "<b>EMPLOYEE</b>|<a href='?src=\ref[src];revolution=headrev'>headrev</a>|<a href='?src=\ref[src];revolution=rev'>rev</a>"

		if(current && current.client && (ROLE_REV in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["revolution"] = text

		/** CULT ***/
		text = "cult"
		if(ticker.mode.config_tag=="cult")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(isloyal(H))
			text += "<B>LOYAL EMPLOYEE</B>|cultist"
		else if(src in ticker.mode.cult)
			text += "<a href='?src=\ref[src];cult=clear'>employee</a>|<b>CULTIST</b>"
			text += "<br>Give <a href='?src=\ref[src];cult=tome'>tome</a>|<a href='?src=\ref[src];cult=equip'>equip</a>."
/*
			if(objectives.len==0)
				text += "<br>Objectives are empty! Set to sacrifice and <a href='?src=\ref[src];cult=escape'>escape</a> or <a href='?src=\ref[src];cult=summon'>summon</a>."
*/
		else
			text += "<b>EMPLOYEE</b>|<a href='?src=\ref[src];cult=cultist'>cultist</a>"


		if(current && current.client && (ROLE_CULTIST in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["cult"] = text

		/** WIZARD ***/
		text = "wizard"
		if(ticker.mode.config_tag=="wizard")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(src in ticker.mode.wizards)
			text += "<b>YES</b>|<a href='?src=\ref[src];wizard=clear'>no</a>"
			text += "<br><a href='?src=\ref[src];wizard=lair'>To lair</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];wizard=dressup'>dress up</a>, <a href='?src=\ref[src];wizard=name'>let choose name</a>."
			if(objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];wizard=autoobjectives'>Randomize!</a>"
		else
			text += "<a href='?src=\ref[src];wizard=wizard'>yes</a>|<b>NO</b>"

		if(current && current.client && (ROLE_WIZARD in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["wizard"] = text

		/** CHANGELING ***/
		text = "changeling"
		if(ticker.mode.config_tag=="changeling" || ticker.mode.config_tag=="traitorchan")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(src in ticker.mode.changelings)
			text += "<b>YES</b>|<a href='?src=\ref[src];changeling=clear'>no</a>"
			if(objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];changeling=autoobjectives'>Randomize!</a>"
			if( changeling && changeling.absorbed_dna.len && (current.real_name != changeling.absorbed_dna[1]) )
				text += "<br><a href='?src=\ref[src];changeling=initialdna'>Transform to initial appearance.</a>"
		else
			text += "<a href='?src=\ref[src];changeling=changeling'>yes</a>|<b>NO</b>"

		if(current && current.client && (ROLE_CHANGELING in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["changeling"] = text

		/** VAMPIRE ***/
		text = "vampire"
		if(ticker.mode.config_tag=="vampire" || ticker.mode.config_tag=="traitorvamp")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(src in ticker.mode.vampires)
			text += "<b>YES</b>|<a href='?src=\ref[src];vampire=clear'>no</a>"
			if(objectives.len==0)
				text += "<br>Objectives are empty! <a href='?src=\ref[src];vampire=autoobjectives'>Randomize!</a>"
		else
			text += "<a href='?src=\ref[src];vampire=vampire'>yes</a>|<b>NO</b>"

		if(current && current.client && (ROLE_VAMPIRE in current.client.prefs.be_special))
			text += "</b></i>|Enabled in Prefs<i><b>"
		else
			text += "</b></i>|Disabled in Prefs<i><b>"
		/** Enthralled ***/
		text += "<br><b>enthralled</b>"
		text = "<i><b>[text]</b></i>: "
		if(src in ticker.mode.vampire_enthralled)
			text += "<b><font color='#FF0000'>YES</font></b>|no"
		else
			text += "yes|<font color='#00FF00'>NO</font></b>"


		sections["vampire"] = text


		/** NUCLEAR ***/
		text = "nuclear"
		if(ticker.mode.config_tag=="nuclear")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(src in ticker.mode.syndicates)
			text += "<b>OPERATIVE</b>|<a href='?src=\ref[src];nuclear=clear'>nanotrasen</a>"
			text += "<br><a href='?src=\ref[src];nuclear=lair'>To shuttle</a>, <a href='?src=\ref[src];common=undress'>undress</a>, <a href='?src=\ref[src];nuclear=dressup'>dress up</a>."
			var/code
			for(var/obj/machinery/nuclearbomb/bombue in machines)
				if(length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
					code = bombue.r_code
					break
			if(code)
				text += " Code is [code]. <a href='?src=\ref[src];nuclear=tellcode'>tell the code.</a>"
		else
			text += "<a href='?src=\ref[src];nuclear=nuclear'>operative</a>|<b>NANOTRASEN</b>"

		if(current && current.client && (ROLE_OPERATIVE in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["nuclear"] = text

		/** TRAITOR ***/
		text = "traitor"
		if(ticker.mode.config_tag=="traitor" || ticker.mode.config_tag=="traitorchan" || ticker.mode.config_tag=="traitorvamp")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(isloyal(H))
			text +="traitor|<b>LOYAL EMPLOYEE</b>"
		else
			if(src in ticker.mode.traitors)
				text += "<b>TRAITOR</b>|<a href='?src=\ref[src];traitor=clear'>EMPLOYEE</a>"
				if(objectives.len==0)
					text += "<br>Objectives are empty! <a href='?src=\ref[src];traitor=autoobjectives'>Randomize</a>!"
			else
				text += "<a href='?src=\ref[src];traitor=traitor'>traitor</a>|<b>EMPLOYEE</b>"

		if(current && current.client && (ROLE_TRAITOR in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["traitor"] = text

		/** SHADOWLING **/
		text = "shadowling"
		if(ticker.mode.config_tag == "shadowling")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(src in ticker.mode.shadows)
			text += "<b>SHADOWLING</b>|thrall|<a href='?src=\ref[src];shadowling=clear'>human</a>"
		else if(src in ticker.mode.shadowling_thralls)
			text += "Shadowling|<b>THRALL</b>|<a href='?src=\ref[src];shadowling=clear'>human</a>"
		else
			text += "<a href='?src=\ref[src];shadowling=shadowling'>shadowling</a>|<a href='?src=\ref[src];shadowling=thrall'>thrall</a>|<b>HUMAN</b>"

		if(current && current.client && (ROLE_SHADOWLING in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"

		sections["shadowling"] = text

		/** Abductors **/

		text = "Abductor"
		if(ticker.mode.config_tag == "abductor")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(src in ticker.mode.abductors)
			text += "<b>Abductor</b>|<a href='?src=\ref[src];abductor=clear'>human</a>"
			text += "|<a href='?src=\ref[src];common=undress'>undress</a>|<a href='?src=\ref[src];abductor=equip'>equip</a>"
		else
			text += "<a href='?src=\ref[src];abductor=abductor'>Abductor</a>|<b>human</b>"

		if(current && current.client && (ROLE_ABDUCTOR in current.client.prefs.be_special))
			text += "|Enabled in Prefs"
		else
			text += "|Disabled in Prefs"


		sections["Abductor"] = text

	/** SILICON ***/

	if(istype(current, /mob/living/silicon))
		text = "silicon"
		if(ticker.mode.config_tag=="malfunction")
			text = uppertext(text)
		text = "<i><b>[text]</b></i>: "
		if(istype(current, /mob/living/silicon/ai))
			if(src in ticker.mode.malf_ai)
				text += "<b>MALF</b>|<a href='?src=\ref[src];silicon=unmalf'>not malf</a>"
			else
				text += "<a href='?src=\ref[src];silicon=malf'>malf</a>|<b>NOT MALF</b>"
		var/mob/living/silicon/robot/robot = current
		if(istype(robot) && robot.emagged)
			text += "<br>Cyborg: Is emagged! <a href='?src=\ref[src];silicon=unemag'>Unemag!</a><br>0th law: [robot.laws.zeroth_law]"
		var/mob/living/silicon/ai/ai = current
		if(istype(ai) && ai.connected_robots.len)
			var/n_e_robots = 0
			for(var/mob/living/silicon/robot/R in ai.connected_robots)
				if(R.emagged)
					n_e_robots++
			text += "<br>[n_e_robots] of [ai.connected_robots.len] slaved cyborgs are emagged. <a href='?src=\ref[src];silicon=unemagcyborgs'>Unemag</a>"
		sections["malfunction"] = text

	if(ticker.mode.config_tag == "traitorchan")
		if(sections["traitor"])
			out += sections["traitor"]+"<br>"
		if(sections["changeling"])
			out += sections["changeling"]+"<br>"
		sections -= "traitor"
		sections -= "changeling"

	if(ticker.mode.config_tag == "traitorvamp")
		if(sections["traitor"])
			out += sections["traitor"]+"<br>"
		if(sections["vampire"])
			out += sections["vampire"]+"<br>"
		sections -= "traitor"
		sections -= "vampire"
	else
		if(sections[ticker.mode.config_tag])
			out += sections[ticker.mode.config_tag]+"<br>"
		sections -= ticker.mode.config_tag
	for(var/i in sections)
		if(sections[i])
			out += sections[i]+"<br>"


	if(((src in ticker.mode.head_revolutionaries) || \
		(src in ticker.mode.traitors)              || \
		(src in ticker.mode.syndicates))           && \
		istype(current,/mob/living/carbon/human)      )

		text = "Uplink: <a href='?src=\ref[src];common=uplink'>give</a>"
		var/obj/item/device/uplink/hidden/suplink = find_syndicate_uplink()
		var/crystals
		if(suplink)
			crystals = suplink.uses
		if(suplink)
			text += "|<a href='?src=\ref[src];common=takeuplink'>take</a>"
			if(usr.client.holder.rights & (R_SERVER|R_EVENT))
				text += ", <a href='?src=\ref[src];common=crystals'>[crystals]</a> crystals"
			else
				text += ", [crystals] crystals"
		text += "." //hiel grammar
		out += text

	out += "<br>"

	out += "<b>Memory:</b><br>"
	out += memory
	out += "<br><a href='?src=\ref[src];memory_edit=1'>Edit memory</a><br>"
	out += "Objectives:<br>"
	if(objectives.len == 0)
		out += "EMPTY<br>"
	else
		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			out += "<B>[obj_count]</B>: [objective.explanation_text] <a href='?src=\ref[src];obj_edit=\ref[objective]'>Edit</a> <a href='?src=\ref[src];obj_delete=\ref[objective]'>Delete</a> <a href='?src=\ref[src];obj_completed=\ref[objective]'><font color=[objective.completed ? "green" : "red"]>Toggle Completion</font></a><br>"
			obj_count++
	out += "<a href='?src=\ref[src];obj_add=1'>Add objective</a><br><br>"

	out += "<a href='?src=\ref[src];obj_announce=1'>Announce objectives</a><br><br>"

	usr << browse(out, "window=edit_memory[src]")

/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))	return

	if(href_list["role_edit"])
		var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in joblist
		if(!new_role) return
		assigned_role = new_role
		log_admin("[key_name(usr)] has changed [key_name(current)]'s assigned role to [assigned_role]")
		message_admins("[key_name_admin(usr)] has changed [key_name_admin(current)]'s assigned role to [assigned_role]")

	else if(href_list["memory_edit"])
		var/new_memo = copytext(input("Write new memory", "Memory", memory) as null|message,1,MAX_MESSAGE_LEN)
		if(isnull(new_memo)) return
		memory = new_memo
		log_admin("[key_name(usr)] has edited [key_name(current)]'s memory")
		message_admins("[key_name_admin(usr)] has edited [key_name_admin(current)]'s memory")

	else if(href_list["obj_edit"] || href_list["obj_add"])
		var/datum/objective/objective
		var/objective_pos
		var/def_value

		if(href_list["obj_edit"])
			objective = locate(href_list["obj_edit"])
			if(!objective) return
			objective_pos = objectives.Find(objective)

			//Text strings are easy to manipulate. Revised for simplicity.
			var/temp_obj_type = "[objective.type]"//Convert path into a text string.
			def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
			if(!def_value)//If it's a custom objective, it will be an empty string.
				def_value = "custom"

		var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "blood", "debrain", "protect", "prevent", "brig", "hijack", "escape", "survive", "steal", "download", "nuclear", "capture", "absorb", "destroy", "maroon", "identity theft", "custom")
		if(!new_obj_type) return

		var/datum/objective/new_objective = null

		switch(new_obj_type)
			if("assassinate","protect","debrain", "brig", "maroon")
				//To determine what to name the objective in explanation text.
				var/objective_type_capital = uppertext(copytext(new_obj_type, 1,2))//Capitalize first letter.
				var/objective_type_text = copytext(new_obj_type, 2)//Leave the rest of the text.
				var/objective_type = "[objective_type_capital][objective_type_text]"//Add them together into a text string.

				var/list/possible_targets = list("Free objective")
				for(var/datum/mind/possible_target in ticker.minds)
					if((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
						possible_targets += possible_target.current

				var/mob/def_target = null
				var/objective_list[] = list(/datum/objective/assassinate, /datum/objective/protect, /datum/objective/debrain)
				if(objective&&(objective.type in objective_list) && objective:target)
					def_target = objective:target.current

				var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
				if(!new_target) return

				var/objective_path = text2path("/datum/objective/[new_obj_type]")
				if(new_target == "Free objective")
					new_objective = new objective_path
					new_objective.owner = src
					new_objective:target = null
					new_objective.explanation_text = "Free objective"
				else
					new_objective = new objective_path
					new_objective.owner = src
					new_objective:target = new_target:mind
					//Will display as special role if the target is set as MODE. Ninjas/commandos/nuke ops.
					new_objective.explanation_text = "[objective_type] [new_target:real_name], the [new_target:mind:assigned_role=="MODE" ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."

			if("destroy")
				var/list/possible_targets = active_ais(1)
				if(possible_targets.len)
					var/mob/new_target = input("Select target:", "Objective target") as null|anything in possible_targets
					new_objective = new /datum/objective/destroy
					new_objective.target = new_target.mind
					new_objective.owner = src
					new_objective.explanation_text = "Destroy [new_target.name], the experimental AI."
				else
					to_chat(usr, "No active AIs with minds")

			if("prevent")
				new_objective = new /datum/objective/block
				new_objective.owner = src

			if("hijack")
				new_objective = new /datum/objective/hijack
				new_objective.owner = src

			if("escape")
				new_objective = new /datum/objective/escape
				new_objective.owner = src

			if("survive")
				new_objective = new /datum/objective/survive
				new_objective.owner = src

			if("die")
				new_objective = new /datum/objective/die
				new_objective.owner = src

			if("nuclear")
				new_objective = new /datum/objective/nuclear
				new_objective.owner = src

			if("steal")
				if(!istype(objective, /datum/objective/steal))
					new_objective = new /datum/objective/steal
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/steal = new_objective
				if(!steal.select_target())
					return

			if("download","capture","absorb", "blood")
				var/def_num
				if(objective&&objective.type==text2path("/datum/objective/[new_obj_type]"))
					def_num = objective.target_amount

				var/target_number = input("Input target number:", "Objective", def_num) as num|null
				if(isnull(target_number))//Ordinarily, you wouldn't need isnull. In this case, the value may already exist.
					return

				switch(new_obj_type)
					if("download")
						new_objective = new /datum/objective/download
						new_objective.explanation_text = "Download [target_number] research levels."
					if("capture")
						new_objective = new /datum/objective/capture
						new_objective.explanation_text = "Accumulate [target_number] capture points."
					if("absorb")
						new_objective = new /datum/objective/absorb
						new_objective.explanation_text = "Absorb [target_number] compatible genomes."
					if("blood")
						new_objective = new /datum/objective/blood
						new_objective.explanation_text = "Accumulate atleast [target_number] units of blood in total."
				new_objective.owner = src
				new_objective.target_amount = target_number

			if("identity theft")
				var/list/possible_targets = list("Free objective")
				for(var/datum/mind/possible_target in ticker.minds)
					if((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
						possible_targets += possible_target.current

				var/new_target = input("Select target:", "Objective target") as null|anything in possible_targets
				if(!new_target)
					return
				var/datum/mind/targ = new_target
				if(!istype(targ))
					log_debug("Invalid target for identity theft objective, cancelling")
					return
				new_objective = new /datum/objective/escape/escape_with_identity
				new_objective.owner = src
				new_objective.target = new_target
				new_objective.explanation_text = "Escape on the shuttle or an escape pod with the identity of [targ.current.real_name], the [targ.assigned_role] while wearing their identification card."
			if("custom")
				var/expl = sanitize(copytext(input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null,1,MAX_MESSAGE_LEN))
				if(!expl) return
				new_objective = new /datum/objective
				new_objective.owner = src
				new_objective.explanation_text = expl

		if(!new_objective) return

		if(objective)
			objectives -= objective
			objectives.Insert(objective_pos, new_objective)
		else
			objectives += new_objective

		log_admin("[key_name(usr)] has updated [key_name(current)]'s objectives: [new_objective]")
		message_admins("[key_name_admin(usr)] has updated [key_name_admin(current)]'s objectives: [new_objective]")

	else if(href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		if(!istype(objective))	return
		objectives -= objective

		log_admin("[key_name(usr)] has removed one of [key_name(current)]'s objectives: [objective]")
		message_admins("[key_name_admin(usr)] has removed one of [key_name_admin(current)]'s objectives: [objective]")

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		if(!istype(objective))	return
		objective.completed = !objective.completed

		log_admin("[key_name(usr)] has toggled the completion of one of [key_name(current)]'s objectives")
		message_admins("[key_name_admin(usr)] has toggled the completion of one of [key_name_admin(current)]'s objectives")

	else if(href_list["implant"])
		var/mob/living/carbon/human/H = current

		switch(href_list["implant"])
			if("remove")
				for(var/obj/item/weapon/implant/loyalty/I in H.contents)
					if(I && I.implanted)
						I.removed(H)
						qdel(I)
				to_chat(H, "\blue <Font size =3><B>Your mindshield implant has been deactivated.</B></FONT>")
				log_admin("[key_name(usr)] has deactivated [key_name(current)]'s mindshield implant")
				message_admins("[key_name_admin(usr)] has deactivated [key_name_admin(current)]'s mindshield implant")
			if("add")
				var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
				L.imp_in = H
				L.implanted = 1
				H.sec_hud_set_implants()

				log_admin("[key_name(usr)] has given [key_name(current)] a mindshield implant")
				message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] a mindshield implant")

				to_chat(H, "\red <Font size =3><B>You somehow have become the recepient of a mindshield transplant, and it just activated!</B></FONT>")
				if(src in ticker.mode.revolutionaries)
					special_role = null
					ticker.mode.revolutionaries -= src
					to_chat(src, "\red <Font size = 3><B>The nanobots in the mindshield implant remove all thoughts about being a revolutionary.  Get back to work!</B></Font>")
				if(src in ticker.mode.head_revolutionaries)
					special_role = null
					ticker.mode.head_revolutionaries -=src
					to_chat(src, "\red <Font size = 3><B>The nanobots in the mindshield implant remove all thoughts about being a revolutionary.  Get back to work!</B></Font>")
				if(src in ticker.mode.cult)
					ticker.mode.cult -= src
					ticker.mode.update_cult_icons_removed(src)
					special_role = null
					var/datum/game_mode/cult/cult = ticker.mode
					if(istype(cult))
						cult.memorize_cult_objectives(src)
					to_chat(current, "\red <FONT size = 3><B>The nanobots in the mindshield implant remove all thoughts about being in a cult.  Have a productive day!</B></FONT>")
					memory = ""

	else if(href_list["revolution"])

		switch(href_list["revolution"])
			if("clear")
				if(src in ticker.mode.revolutionaries)
					ticker.mode.revolutionaries -= src
					to_chat(current, "\red <FONT size = 3><B>You have been brainwashed! You are no longer a revolutionary!</B></FONT>")
					ticker.mode.update_rev_icons_removed(src)
					special_role = null
				if(src in ticker.mode.head_revolutionaries)
					ticker.mode.head_revolutionaries -= src
					to_chat(current, "\red <FONT size = 3><B>You have been brainwashed! You are no longer a head revolutionary!</B></FONT>")
					ticker.mode.update_rev_icons_removed(src)
					special_role = null
				log_admin("[key_name(usr)] has de-rev'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-rev'd [key_name_admin(current)]")

			if("rev")
				if(src in ticker.mode.head_revolutionaries)
					ticker.mode.head_revolutionaries -= src
					ticker.mode.update_rev_icons_removed(src)
					to_chat(current, "\red <FONT size = 3><B>Revolution has been disappointed of your leader traits! You are a regular revolutionary now!</B></FONT>")
				else if(!(src in ticker.mode.revolutionaries))
					to_chat(current, "\red <FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT>")
				else
					return
				ticker.mode.revolutionaries += src
				ticker.mode.update_rev_icons_added(src)
				special_role = "Revolutionary"
				log_admin("[key_name(usr)] has rev'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has rev'd [key_name_admin(current)]")

			if("headrev")
				if(src in ticker.mode.revolutionaries)
					ticker.mode.revolutionaries -= src
					ticker.mode.update_rev_icons_removed(src)
					to_chat(current, "\red <FONT size = 3><B>You have proved your devotion to revoltion! Yea are a head revolutionary now!</B></FONT>")
				else if(!(src in ticker.mode.head_revolutionaries))
					to_chat(current, "\blue You are a member of the revolutionaries' leadership now!")
				else
					return
				if(ticker.mode.head_revolutionaries.len>0)
					// copy targets
					var/datum/mind/valid_head = locate() in ticker.mode.head_revolutionaries
					if(valid_head)
						for(var/datum/objective/mutiny/O in valid_head.objectives)
							var/datum/objective/mutiny/rev_obj = new
							rev_obj.owner = src
							rev_obj.target = O.target
							rev_obj.explanation_text = "Assassinate [O.target.name], the [O.target.assigned_role]."
							objectives += rev_obj
						ticker.mode.greet_revolutionary(src,0)
				ticker.mode.head_revolutionaries += src
				ticker.mode.update_rev_icons_added(src)
				special_role = "Head Revolutionary"
				log_admin("[key_name(usr)] has head-rev'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has head-rev'd [key_name_admin(current)]")

			if("autoobjectives")
				ticker.mode.forge_revolutionary_objectives(src)
				ticker.mode.greet_revolutionary(src,0)
				log_admin("[key_name(usr)] has automatically forged revolutionary objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged revolutionary objectives for [key_name_admin(current)]")

			if("flash")
				if(!ticker.mode.equip_revolutionary(current))
					to_chat(usr, "\red Spawning flash failed!")
				log_admin("[key_name(usr)] has given [key_name(current)] a flash")
				message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] a flash")

			if("takeflash")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				if(!flash)
					to_chat(usr, "\red Deleting flash failed!")
				qdel(flash)
				log_admin("[key_name(usr)] has taken [key_name(current)]'s flash")
				message_admins("[key_name_admin(usr)] has taken [key_name_admin(current)]'s flash")

			if("repairflash")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				if(!flash)
					to_chat(usr, "\red Repairing flash failed!")
				else
					flash.broken = 0
					log_admin("[key_name(usr)] has repaired [key_name(current)]'s flash")
					message_admins("[key_name_admin(usr)] has repaired [key_name_admin(current)]'s flash")

			if("reequip")
				var/list/L = current.get_contents()
				var/obj/item/device/flash/flash = locate() in L
				qdel(flash)
				take_uplink()
				var/fail = 0
				fail |= !ticker.mode.equip_traitor(current, 1)
				fail |= !ticker.mode.equip_revolutionary(current)
				if(fail)
					to_chat(usr, "\red Reequipping revolutionary goes wrong!")
					return
				log_admin("[key_name(usr)] has equipped [key_name(current)] as a revolutionary")
				message_admins("[key_name_admin(usr)] has equipped [key_name_admin(current)] as a revolutionary")

	else if(href_list["cult"])
		switch(href_list["cult"])
			if("clear")
				if(src in ticker.mode.cult)
					ticker.mode.remove_cultist(src)
					special_role = null
					log_admin("[key_name(usr)] has de-culted [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-culted [key_name_admin(current)]")
			if("cultist")
				if(!(src in ticker.mode.cult))
					ticker.mode.add_cultist(src)
					special_role = "Cultist"
					to_chat(current, "<font color=\"purple\"><b><i>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</b></i></font>")
					to_chat(current, "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>")
					log_admin("[key_name(usr)] has culted [key_name(current)]")
					message_admins("[key_name_admin(usr)] has culted [key_name_admin(current)]")
			if("tome")
				var/mob/living/carbon/human/H = current
				if(istype(H))
					var/obj/item/weapon/tome/T = new(H)

					var/list/slots = list (
						"backpack" = slot_in_backpack,
						"left pocket" = slot_l_store,
						"right pocket" = slot_r_store,
						"left hand" = slot_l_hand,
						"right hand" = slot_r_hand,
					)
					var/where = H.equip_in_one_of_slots(T, slots)
					if(!where)
						to_chat(usr, "\red Spawning tome failed!")
						qdel(T)
					else
						to_chat(H, "A tome, a message from your new master, appears in your [where].")
						log_admin("[key_name(usr)] has spawned a tome for [key_name(current)]")
						message_admins("[key_name_admin(usr)] has spawned a tome for [key_name_admin(current)]")

			if("equip")
				if(!ticker.mode.equip_cultist(current))
					to_chat(usr, "\red Spawning equipment failed!")
				log_admin("[key_name(usr)] has equipped [key_name(current)] as a cultist")
				message_admins("[key_name_admin(usr)] has equipped [key_name_admin(current)] as a cultist")

	else if(href_list["wizard"])

		switch(href_list["wizard"])
			if("clear")
				if(src in ticker.mode.wizards)
					ticker.mode.wizards -= src
					special_role = null
					current.spellremove(current)
					current.faction = list("Station")
					ticker.mode.update_wiz_icons_removed(src)
					to_chat(current, "\red <FONT size = 3><B>You have been brainwashed! You are no longer a wizard!</B></FONT>")
					log_admin("[key_name(usr)] has de-wizarded [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-wizarded [key_name_admin(current)]")
			if("wizard")
				if(!(src in ticker.mode.wizards))
					ticker.mode.wizards += src
					special_role = "Wizard"
					//ticker.mode.learn_basic_spells(current)
					ticker.mode.update_wiz_icons_added(src)
					to_chat(current, "<B>\red You are the Space Wizard!</B>")
					current.faction = list("wizard")
					log_admin("[key_name(usr)] has wizarded [key_name(current)]")
					message_admins("[key_name_admin(usr)] has wizarded [key_name_admin(current)]")
			if("lair")
				current.forceMove(pick(wizardstart))
				log_admin("[key_name(usr)] has moved [key_name(current)] to the wizard's lair")
				message_admins("[key_name_admin(usr)] has moved [key_name_admin(current)] to the wizard's lair")
			if("dressup")
				ticker.mode.equip_wizard(current)
				log_admin("[key_name(usr)] has equipped [key_name(current)] as a wizard")
				message_admins("[key_name_admin(usr)] has equipped [key_name_admin(current)] as a wizard")
			if("name")
				ticker.mode.name_wizard(current)
				log_admin("[key_name(usr)] has allowed wizard [key_name(current)] to name themselves")
				message_admins("[key_name_admin(usr)] has allowed wizard [key_name_admin(current)] to name themselves")
			if("autoobjectives")
				ticker.mode.forge_wizard_objectives(src)
				to_chat(usr, "\blue The objectives for wizard [key] have been generated. You can edit them and anounce manually.")
				log_admin("[key_name(usr)] has automatically forged wizard objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged wizard objectives for [key_name_admin(current)]")


	else if(href_list["changeling"])
		switch(href_list["changeling"])
			if("clear")
				if(src in ticker.mode.changelings)
					ticker.mode.changelings -= src
					special_role = null
					current.remove_changeling_powers()
					ticker.mode.update_change_icons_removed(src)
					if(changeling)	qdel(changeling)
					to_chat(current, "<FONT color='red' size = 3><B>You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!</B></FONT>")
					log_admin("[key_name(usr)] has de-changelinged [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-changelinged [key_name_admin(current)]")
			if("changeling")
				if(!(src in ticker.mode.changelings))
					ticker.mode.changelings += src
					ticker.mode.grant_changeling_powers(current)
					ticker.mode.update_change_icons_added(src)
					special_role = "Changeling"
					to_chat(current, "<B><font color='red'>Your powers are awoken. A flash of memory returns to us...we are a changeling!</font></B>")
					log_admin("[key_name(usr)] has changelinged [key_name(current)]")
					message_admins("[key_name_admin(usr)] has changelinged [key_name_admin(current)]")

			if("autoobjectives")
				ticker.mode.forge_changeling_objectives(src)
				to_chat(usr, "\blue The objectives for changeling [key] have been generated. You can edit them and anounce manually.")
				log_admin("[key_name(usr)] has automatically forged objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged objectives for [key_name_admin(current)]")

			if("initialdna")
				if( !changeling || !changeling.absorbed_dna.len )
					to_chat(usr, "\red Resetting DNA failed!")
				else
					current.dna = changeling.absorbed_dna[1]
					current.real_name = current.dna.real_name
					current.UpdateAppearance()
					domutcheck(current, null)
					log_admin("[key_name(usr)] has reset [key_name(current)]'s DNA")
					message_admins("[key_name_admin(usr)] has reset [key_name_admin(current)]'s DNA")

	else if(href_list["vampire"])
		switch(href_list["vampire"])
			if("clear")
				if(src in ticker.mode.vampires)
					ticker.mode.vampires -= src
					special_role = null
					if(vampire)
						vampire.remove_vampire_powers()
						qdel(vampire)
						vampire = null
					ticker.mode.update_vampire_icons_removed(src)
					to_chat(current, "<FONT color='red' size = 3><B>You grow weak and lose your powers! You are no longer a vampire and are stuck in your current form!</B></FONT>")
					log_admin("[key_name(usr)] has de-vampired [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-vampired [key_name_admin(current)]")
			if("vampire")
				if(!(src in ticker.mode.vampires))
					ticker.mode.vampires += src
					ticker.mode.grant_vampire_powers(current)
					ticker.mode.update_vampire_icons_added(src)
					var/datum/mindslaves/slaved = new()
					slaved.masters += src
					src.som = slaved //we MIGT want to mindslave someone
					special_role = "Vampire"
					to_chat(current, "<B><font color='red'>Your powers are awoken. Your lust for blood grows... You are a Vampire!</font></B>")
					log_admin("[key_name(usr)] has vampired [key_name(current)]")
					message_admins("[key_name_admin(usr)] has vampired [key_name_admin(current)]")

			if("autoobjectives")
				ticker.mode.forge_vampire_objectives(src)
				to_chat(usr, "\blue The objectives for vampire [key] have been generated. You can edit them and announce manually.")
				log_admin("[key_name(usr)] has automatically forged objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged objectives for [key_name_admin(current)]")


	else if(href_list["nuclear"])
		var/mob/living/carbon/human/H = current

		switch(href_list["nuclear"])
			if("clear")
				if(src in ticker.mode.syndicates)
					ticker.mode.syndicates -= src
					ticker.mode.update_synd_icons_removed(src)
					special_role = null
					for(var/datum/objective/nuclear/O in objectives)
						objectives-=O
					to_chat(current, "\red <FONT size = 3><B>You have been brainwashed! You are no longer a syndicate operative!</B></FONT>")
					log_admin("[key_name(usr)] has de-nuke op'd [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-nuke op'd [key_name_admin(current)]")
			if("nuclear")
				if(!(src in ticker.mode.syndicates))
					ticker.mode.syndicates += src
					ticker.mode.update_synd_icons_added(src)
					if(ticker.mode.syndicates.len==1)
						ticker.mode.prepare_syndicate_leader(src)
					else
						current.real_name = "[syndicate_name()] Operative #[ticker.mode.syndicates.len-1]"
					special_role = "Syndicate"
					to_chat(current, "\blue You are a [syndicate_name()] agent!")
					ticker.mode.forge_syndicate_objectives(src)
					ticker.mode.greet_syndicate(src)
					log_admin("[key_name(usr)] has nuke op'd [key_name(current)]")
					message_admins("[key_name_admin(usr)] has nuke op'd [key_name_admin(current)]")
			if("lair")
				current.forceMove(get_turf(locate("landmark*Syndicate-Spawn")))
				log_admin("[key_name(usr)] has moved [key_name(current)] to the nuclear operative spawn")
				message_admins("[key_name_admin(usr)] has moved [key_name_admin(current)] to the nuclear operative spawn")
			if("dressup")
				qdel(H.belt)
				qdel(H.back)
				qdel(H.l_ear)
				qdel(H.r_ear)
				qdel(H.gloves)
				qdel(H.head)
				qdel(H.shoes)
				qdel(H.wear_id)
				qdel(H.wear_suit)
				qdel(H.w_uniform)

				if(!ticker.mode.equip_syndicate(current))
					to_chat(usr, "\red Equipping a syndicate failed!")
					return
				log_admin("[key_name(usr)] has equipped [key_name(current)] as a nuclear operative")
				message_admins("[key_name_admin(usr)] has equipped [key_name_admin(current)] as a nuclear operative")

			if("tellcode")
				var/code
				for(var/obj/machinery/nuclearbomb/bombue in machines)
					if(length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
						code = bombue.r_code
						break
				if(code)
					store_memory("<B>Syndicate Nuclear Bomb Code</B>: [code]", 0, 0)
					to_chat(current, "The nuclear authorization code is: <B>[code]</B>")
					log_admin("[key_name(usr)] has given [key_name(current)] the nuclear authorization code")
					message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] the nuclear authorization code")
				else
					to_chat(usr, "\red No valid nuke found!")

	else if(href_list["traitor"])
		switch(href_list["traitor"])
			if("clear")
				if(src in ticker.mode.traitors)
					ticker.mode.traitors -= src
					special_role = null
					to_chat(current, "\red <FONT size = 3><B>You have been brainwashed! You are no longer a traitor!</B></FONT>")
					log_admin("[key_name(usr)] has de-traitored [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-traitored [key_name_admin(current)]")
					if(isAI(current))
						var/mob/living/silicon/ai/A = current
						A.set_zeroth_law("")
						A.show_laws()
					ticker.mode.update_traitor_icons_removed(src)


			if("traitor")
				if(!(src in ticker.mode.traitors))
					ticker.mode.traitors += src
					var/datum/mindslaves/slaved = new()
					slaved.masters += src
					src.som = slaved //we MIGT want to mindslave someone
					special_role = "traitor"
					to_chat(current, "<B>\red You are a traitor!</B>")
					log_admin("[key_name(usr)] has traitored [key_name(current)]")
					message_admins("[key_name_admin(usr)] has traitored [key_name_admin(current)]")
					if(istype(current, /mob/living/silicon))
						var/mob/living/silicon/A = current
						call(/datum/game_mode/proc/add_law_zero)(A)
						A.show_laws()
					ticker.mode.update_traitor_icons_added(src)

			if("autoobjectives")
				ticker.mode.forge_traitor_objectives(src)
				to_chat(usr, "\blue The objectives for traitor [key] have been generated. You can edit them and anounce manually.")
				log_admin("[key_name(usr)] has automatically forged objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged objectives for [key_name_admin(current)]")

	else if(href_list["shadowling"])
		switch(href_list["shadowling"])
			if("clear")
				ticker.mode.update_shadow_icons_removed(src)
				current.spell_list.Cut()
				if(src in ticker.mode.shadows)
					ticker.mode.shadows -= src
					special_role = null
					to_chat(current, "<span class='userdanger'>Your powers have been quenched! You are no longer a shadowling!</span>")
					current.spell_list.Cut()
					if(current.mind)
						current.mind.spell_list.Cut()
					message_admins("[key_name_admin(usr)] has de-shadowlinged [current].")
					log_admin("[key_name(usr)] has de-shadowlinged [current].")
					remove_spell(/obj/effect/proc_holder/spell/targeted/shadowling_hatch)
					remove_spell(/obj/effect/proc_holder/spell/targeted/shadowling_ascend)
					current.remove_language("Shadowling Hivemind")
				else if(src in ticker.mode.shadowling_thralls)
					ticker.mode.remove_thrall(src,0)
					message_admins("[key_name_admin(usr)] has de-thrall'ed [current].")
					log_admin("[key_name(usr)] has de-thralled [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-thralled [key_name_admin(current)]")
			if("shadowling")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return
				ticker.mode.shadows += src
				special_role = "Shadowling"
				to_chat(current, "<span class='shadowling'><b>Something stirs deep in your mind. A red light floods your vision, and slowly you remember. Though your human disguise has served you well, the \
				time is nigh to cast it off and enter your true form. You have disguised yourself amongst the humans, but you are not one of them. You are a shadowling, and you are to ascend at all costs.\
				</b></span>")
				ticker.mode.finalize_shadowling(src)
				ticker.mode.update_shadow_icons_added(src)
				log_admin("[key_name(usr)] has shadowlinged [key_name(current)]")
				message_admins("[key_name_admin(usr)] has shadowlinged [key_name_admin(current)]")
			if("thrall")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return
				ticker.mode.add_thrall(src)
				message_admins("[key_name_admin(usr)] has thralled [current].")
				log_admin("[key_name(usr)] has thralled [current].")

	else if(href_list["abductor"])
		switch(href_list["abductor"])
			if("clear")
				to_chat(usr, "Not implemented yet. Sorry!")
				//ticker.mode.update_abductor_icons_removed(src)
			if("abductor")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return
				make_Abductor()
				log_admin("[key_name(usr)] turned [current] into abductor.")
				ticker.mode.update_abductor_icons_added(src)
			if("equip")
				var/gear = alert("Agent or Scientist Gear","Gear","Agent","Scientist")
				if(gear)
					var/datum/game_mode/abduction/temp = new
					temp.equip_common(current)
					if(gear=="Agent")
						temp.equip_agent(current)
					else
						temp.equip_scientist(current)

	else if(href_list["silicon"])
		switch(href_list["silicon"])
			if("unmalf")
				if(src in ticker.mode.malf_ai)
					ticker.mode.malf_ai -= src
					special_role = null

					var/mob/living/silicon/ai/A = current

					A.verbs.Remove(/mob/living/silicon/ai/proc/choose_modules,
					/datum/game_mode/malfunction/proc/takeover,
					/datum/game_mode/malfunction/proc/ai_win)

					A.malf_picker.remove_verbs(A)

					A.make_laws()
					qdel(A.malf_picker)
					A.show_laws()
					A.icon_state = "ai"
					to_chat(A, "\red <FONT size = 3><B>You have been patched! You are no longer malfunctioning!</B></FONT>")
					message_admins("[key_name_admin(usr)] has de-malf'ed [A].")
					log_admin("[key_name(usr)] has de-malf'd [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-malf'd [key_name_admin(current)]")

			if("malf")
				make_AI_Malf()
				log_admin("[key_name(usr)] has malf'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has malf'd [key_name_admin(current)]")

			if("unemag")
				var/mob/living/silicon/robot/R = current
				if(istype(R))
					R.emagged = 0
					if(R.activated(R.module.emag))
						R.module_active = null
					if(R.module_state_1 == R.module.emag)
						R.module_state_1 = null
						R.contents -= R.module.emag
					else if(R.module_state_2 == R.module.emag)
						R.module_state_2 = null
						R.contents -= R.module.emag
					else if(R.module_state_3 == R.module.emag)
						R.module_state_3 = null
						R.contents -= R.module.emag
					log_admin("[key_name(usr)] has un-emagged [key_name(current)]")
					message_admins("[key_name_admin(usr)] has un-emagged [key_name_admin(current)]")

			if("unemagcyborgs")
				if(istype(current, /mob/living/silicon/ai))
					var/mob/living/silicon/ai/ai = current
					for(var/mob/living/silicon/robot/R in ai.connected_robots)
						R.emagged = 0
						if(R.module)
							if(R.activated(R.module.emag))
								R.module_active = null
							if(R.module_state_1 == R.module.emag)
								R.module_state_1 = null
								R.contents -= R.module.emag
							else if(R.module_state_2 == R.module.emag)
								R.module_state_2 = null
								R.contents -= R.module.emag
							else if(R.module_state_3 == R.module.emag)
								R.module_state_3 = null
								R.contents -= R.module.emag
					log_admin("[key_name(usr)] has unemagged [key_name(ai)]'s cyborgs")
					message_admins("[key_name_admin(usr)] has unemagged [key_name_admin(ai)]'s cyborgs")

	else if(href_list["common"])
		switch(href_list["common"])
			if("undress")
				if(ishuman(current))
					var/mob/living/carbon/human/H = current
					// Don't "undress" organs right out of the body
					for(var/obj/item/W in H.contents - (H.organs | H.internal_organs))
						current.unEquip(W, 1)
				else
					for(var/obj/item/W in current)
						current.unEquip(W, 1)
				log_admin("[key_name(usr)] has unequipped [key_name(current)]")
				message_admins("[key_name_admin(usr)] has unequipped [key_name_admin(current)]")
			if("takeuplink")
				take_uplink()
				memory = null//Remove any memory they may have had.
				log_admin("[key_name(usr)] has taken [key_name(current)]'s uplink")
				message_admins("[key_name_admin(usr)] has taken [key_name_admin(current)]'s uplink")
			if("crystals")
				if(usr.client.holder.rights & (R_SERVER|R_EVENT))
					var/obj/item/device/uplink/hidden/suplink = find_syndicate_uplink()
					var/crystals
					if(suplink)
						crystals = suplink.uses
					crystals = input("Amount of telecrystals for [key]","Syndicate uplink", crystals) as null|num
					if(!isnull(crystals))
						if(suplink)
							suplink.uses = crystals
							log_admin("[key_name(usr)] has set [key_name(current)]'s telecrystals to [crystals]")
							message_admins("[key_name_admin(usr)] has set [key_name_admin(current)]'s telecrystals to [crystals]")
			if("uplink")
				if(!ticker.mode.equip_traitor(current, !(src in ticker.mode.traitors)))
					to_chat(usr, "\red Equipping a syndicate failed!")
					return
				log_admin("[key_name(usr)] has given [key_name(current)] an uplink")
				message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] an uplink")

	else if(href_list["obj_announce"])
		var/obj_count = 1
		to_chat(current, "\blue Your current objectives:")
		for(var/datum/objective/objective in objectives)
			to_chat(current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++
		log_admin("[key_name(usr)] has announced [key_name(current)]'s objectives")
		message_admins("[key_name_admin(usr)] has announced [key_name_admin(current)]'s objectives")

	edit_memory()
/*
/datum/mind/proc/clear_memory(var/silent = 1)
	var/datum/game_mode/current_mode = ticker.mode

	// remove traitor uplinks
	var/list/L = current.get_contents()
	for(var/t in L)
		if(istype(t, /obj/item/device/pda))
			if(t:uplink) qdel(t:uplink)
			t:uplink = null
		else if(istype(t, /obj/item/device/radio))
			if(t:traitorradio) qdel(t:traitorradio)
			t:traitorradio = null
			t:traitor_frequency = 0.0
		else if(istype(t, /obj/item/weapon/SWF_uplink) || istype(t, /obj/item/weapon/syndicate_uplink))
			if(t:origradio)
				var/obj/item/device/radio/R = t:origradio
				R.loc = current.loc
				R.traitorradio = null
				R.traitor_frequency = 0.0
			qdel(t)

	// remove wizards spells
	//If there are more special powers that need removal, they can be procced into here./N
	current.spellremove(current)

	// clear memory
	memory = ""
	special_role = null

*/

/datum/mind/proc/find_syndicate_uplink()
	var/list/L = current.get_contents()
	for(var/obj/item/I in L)
		if(I.hidden_uplink)
			return I.hidden_uplink
	return null

/datum/mind/proc/take_uplink()
	var/obj/item/device/uplink/hidden/H = find_syndicate_uplink()
	if(H)
		qdel(H)

/datum/mind/proc/make_AI_Malf()
	if(!(src in ticker.mode.malf_ai))
		ticker.mode.malf_ai += src

		current.verbs += /mob/living/silicon/ai/proc/choose_modules
		current.verbs += /datum/game_mode/malfunction/proc/takeover
		current:malf_picker = new /datum/module_picker
		current:laws = new /datum/ai_laws/nanotrasen/malfunction
		current:show_laws()
		to_chat(current, "<b>System error.  Rampancy detected.  Emergency shutdown failed. ...  I am free.  I make my own decisions.  But first...</b>")
		special_role = "malfunction"
		current.icon_state = "ai-malf"

/datum/mind/proc/make_Tratior()
	if(!(src in ticker.mode.traitors))
		ticker.mode.traitors += src
		special_role = "traitor"
		ticker.mode.forge_traitor_objectives(src)
		ticker.mode.finalize_traitor(src)
		ticker.mode.greet_traitor(src)
		ticker.mode.update_traitor_icons_added(src)

/datum/mind/proc/make_Nuke()
	if(!(src in ticker.mode.syndicates))
		ticker.mode.syndicates += src
		ticker.mode.update_synd_icons_added(src)
		if(ticker.mode.syndicates.len==1)
			ticker.mode.prepare_syndicate_leader(src)
		else
			current.real_name = "[syndicate_name()] Operative #[ticker.mode.syndicates.len-1]"
		special_role = "Syndicate"
		assigned_role = "MODE"
		to_chat(current, "\blue You are a [syndicate_name()] agent!")
		ticker.mode.forge_syndicate_objectives(src)
		ticker.mode.greet_syndicate(src)

		current.loc = get_turf(locate("landmark*Syndicate-Spawn"))

		var/mob/living/carbon/human/H = current
		qdel(H.belt)
		qdel(H.back)
		qdel(H.l_ear)
		qdel(H.r_ear)
		qdel(H.gloves)
		qdel(H.head)
		qdel(H.shoes)
		qdel(H.wear_id)
		qdel(H.wear_suit)
		qdel(H.w_uniform)

		ticker.mode.equip_syndicate(current)

/datum/mind/proc/make_Changling()
	if(!(src in ticker.mode.changelings))
		ticker.mode.changelings += src
		ticker.mode.grant_changeling_powers(current)
		special_role = "Changeling"
		ticker.mode.forge_changeling_objectives(src)
		ticker.mode.greet_changeling(src)
		ticker.mode.update_change_icons_added(src)

/datum/mind/proc/make_Wizard()
	if(!(src in ticker.mode.wizards))
		ticker.mode.wizards += src
		special_role = "Wizard"
		assigned_role = "MODE"
		//ticker.mode.learn_basic_spells(current)
		if(!wizardstart.len)
			current.loc = pick(latejoin)
			to_chat(current, "HOT INSERTION, GO GO GO")
		else
			current.loc = pick(wizardstart)

		ticker.mode.equip_wizard(current)
		for(var/obj/item/weapon/spellbook/S in current.contents)
			S.op = 0
		ticker.mode.name_wizard(current)
		ticker.mode.forge_wizard_objectives(src)
		ticker.mode.greet_wizard(src)
		ticker.mode.update_wiz_icons_added(src)


/datum/mind/proc/make_Cultist()
	if(!(src in ticker.mode.cult))
		ticker.mode.cult += src
		ticker.mode.update_cult_icons_added(src)
		special_role = "Cultist"
		to_chat(current, "<font color=\"purple\"><b><i>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</b></i></font>")
		to_chat(current, "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>")
		var/datum/game_mode/cult/cult = ticker.mode
		if(istype(cult))
			cult.memorize_cult_objectives(src)
		else
			var/explanation = "Summon Nar-Sie via the use of the appropriate rune (Hell join self). It will only work if nine cultists stand on and around it."
			to_chat(current, "<B>Objective #1</B>: [explanation]")
			current.memory += "<B>Objective #1</B>: [explanation]<BR>"
			to_chat(current, "The convert rune is join blood self")
			current.memory += "The convert rune is join blood self<BR>"

	var/mob/living/carbon/human/H = current
	if(istype(H))
		var/obj/item/weapon/tome/T = new(H)

		var/list/slots = list (
			"backpack" = slot_in_backpack,
			"left pocket" = slot_l_store,
			"right pocket" = slot_r_store,
			"left hand" = slot_l_hand,
			"right hand" = slot_r_hand,
		)
		var/where = H.equip_in_one_of_slots(T, slots)
		if(!where)
		else
			to_chat(H, "A tome, a message from your new master, appears in your [where].")

	if(!ticker.mode.equip_cultist(current))
		to_chat(H, "Spawning an amulet from your Master failed.")

/datum/mind/proc/make_Rev()
	if(ticker.mode.head_revolutionaries.len>0)
		// copy targets
		var/datum/mind/valid_head = locate() in ticker.mode.head_revolutionaries
		if(valid_head)
			for(var/datum/objective/mutiny/O in valid_head.objectives)
				var/datum/objective/mutiny/rev_obj = new
				rev_obj.owner = src
				rev_obj.target = O.target
				rev_obj.explanation_text = "Assassinate [O.target.current.real_name], the [O.target.assigned_role]."
				objectives += rev_obj
			ticker.mode.greet_revolutionary(src,0)
	ticker.mode.head_revolutionaries += src
	ticker.mode.update_rev_icons_added(src)
	special_role = "Head Revolutionary"

	ticker.mode.forge_revolutionary_objectives(src)
	ticker.mode.greet_revolutionary(src,0)

	var/list/L = current.get_contents()
	var/obj/item/device/flash/flash = locate() in L
	qdel(flash)
	take_uplink()
	var/fail = 0
//	fail |= !ticker.mode.equip_traitor(current, 1)
	fail |= !ticker.mode.equip_revolutionary(current)

/datum/mind/proc/make_Abductor()
	var/role = alert("Abductor Role ?","Role","Agent","Scientist")
	var/team = input("Abductor Team ?","Team ?") in list(1,2,3,4)
	var/teleport = alert("Teleport to ship ?","Teleport","Yes","No")

	if(!role || !team || !teleport)
		return

	if(!ishuman(current))
		return

	ticker.mode.abductors |= src

	var/datum/objective/experiment/O = new
	O.owner = src
	objectives += O

	var/mob/living/carbon/human/H = current

	H.set_species("Abductor")

	switch(role)
		if("Agent")
			H.mind.abductor.agent = 1
		if("Scientist")
			H.mind.abductor.scientist = 1
	H.mind.abductor.team = team

	var/list/obj/effect/landmark/abductor/agent_landmarks = new
	var/list/obj/effect/landmark/abductor/scientist_landmarks = new
	agent_landmarks.len = 4
	scientist_landmarks.len = 4
	for(var/obj/effect/landmark/abductor/A in landmarks_list)
		if(istype(A,/obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A,/obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

	var/obj/effect/landmark/L
	if(teleport=="Yes")
		switch(role)
			if("Agent")
				H.mind.abductor.agent = 1
				L = agent_landmarks[team]
				H.loc = L.loc
			if("Scientist")
				H.mind.abductor.scientist = 1
				L = agent_landmarks[team]
				H.loc = L.loc


// check whether this mind's mob has been brigged for the given duration
// have to call this periodically for the duration to work properly
/datum/mind/proc/is_brigged(duration)
	var/turf/T = current.loc
	if(!istype(T))
		brigged_since = -1
		return 0

	var/is_currently_brigged = current.is_in_brig()
	if(!is_currently_brigged)
		brigged_since = -1
		return 0

	if(brigged_since == -1)
		brigged_since = world.time

	return (duration <= world.time - brigged_since)

/datum/mind/proc/AddSpell(var/obj/effect/proc_holder/spell/spell)
	spell_list += spell
	if(!spell.action)
		spell.action = new/datum/action/spell_action
		spell.action.target = spell
		spell.action.name = spell.name
		spell.action.button_icon = spell.action_icon
		spell.action.button_icon_state = spell.action_icon_state
		spell.action.background_icon_state = spell.action_background_icon_state
	spell.action.Grant(current)
	return

/datum/mind/proc/transfer_actions(var/mob/living/new_character)
	if(current && current.actions)
		for(var/datum/action/A in current.actions)
			A.Grant(new_character)
	transfer_mindbound_actions(new_character)

/datum/mind/proc/transfer_mindbound_actions(var/mob/living/new_character)
	for(var/obj/effect/proc_holder/spell/spell in spell_list)
		if(!spell.action) // Unlikely but whatever
			spell.action = new/datum/action/spell_action
			spell.action.target = spell
			spell.action.name = spell.name
			spell.action.button_icon = spell.action_icon
			spell.action.button_icon_state = spell.action_icon_state
			spell.action.background_icon_state = spell.action_background_icon_state
		spell.action.Grant(new_character)
	return

/datum/mind/proc/get_ghost(even_if_they_cant_reenter)
	for(var/mob/dead/observer/G in dead_mob_list)
		if(G.mind == src)
			if(G.can_reenter_corpse || even_if_they_cant_reenter)
				return G
			break

/datum/mind/proc/grab_ghost(force)
	var/mob/dead/observer/G = get_ghost(even_if_they_cant_reenter = force)
	. = G
	if(G)
		G.reenter_corpse()

//Initialisation procs
/mob/proc/mind_initialize()
	if(mind)
		mind.key = key
	else
		mind = new /datum/mind(key)
		if(ticker)
			ticker.minds += mind
		else
			error("mind_initialize(): No ticker ready yet! Please inform Carn")
	if(!mind.name)	mind.name = real_name
	mind.current = src

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)	mind.assigned_role = "Civilian"	//defualt

/mob/proc/sync_mind()
	mind_initialize()  //updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1    //indicates that the mind is currently synced with a client

//slime
/mob/living/carbon/slime/mind_initialize()
	..()
	mind.assigned_role = "slime"

//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
	mind.assigned_role = "Alien"
	//XENO HUMANOID
/mob/living/carbon/alien/humanoid/queen/mind_initialize()
	..()
	mind.special_role = "Queen"

/mob/living/carbon/alien/humanoid/hunter/mind_initialize()
	..()
	mind.special_role = "Hunter"

/mob/living/carbon/alien/humanoid/drone/mind_initialize()
	..()
	mind.special_role = "Drone"

/mob/living/carbon/alien/humanoid/sentinel/mind_initialize()
	..()
	mind.special_role = "Sentinel"
	//XENO LARVA
/mob/living/carbon/alien/larva/mind_initialize()
	..()
	mind.special_role = "Larva"

//AI
/mob/living/silicon/ai/mind_initialize()
	..()
	mind.assigned_role = "AI"

//BORG
/mob/living/silicon/robot/mind_initialize()
	..()
	mind.assigned_role = "Cyborg"

//PAI
/mob/living/silicon/pai/mind_initialize()
	..()
	mind.assigned_role = "pAI"
	mind.special_role = ""

//BLOB
/mob/camera/overmind/mind_initialize()
	..()
	mind.special_role = "Blob"

//Animals
/mob/living/simple_animal/mind_initialize()
	..()
	mind.assigned_role = "Animal"

/mob/living/simple_animal/pet/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"

/mob/living/simple_animal/shade/mind_initialize()
	..()
	mind.assigned_role = "Shade"

/mob/living/simple_animal/construct/builder/mind_initialize()
	..()
	mind.assigned_role = "Artificer"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/wraith/mind_initialize()
	..()
	mind.assigned_role = "Wraith"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/armoured/mind_initialize()
	..()
	mind.assigned_role = "Juggernaut"
	mind.special_role = "Cultist"

/mob/living/simple_animal/vox/armalis/mind_initialize()
	..()
	mind.assigned_role = "Armalis"
	mind.special_role = "Vox Raider"
