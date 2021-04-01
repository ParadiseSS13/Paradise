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

	var/assigned_role //assigned role is what job you're assigned to when you join the station.
	var/playtime_role //if set, overrides your assigned_role for the purpose of playtime awards. Set by IDcomputer when your ID is changed.
	var/special_role //special roles are typically reserved for antags or roles like ERT. If you want to avoid a character being automatically announced by the AI, on arrival (becuase they're an off station character or something); ensure that special_role and assigned_role are equal.
	var/offstation_role = FALSE //set to true for ERT, deathsquad, abductors, etc, that can go from and to CC at will and shouldn't be antag targets
	var/list/restricted_roles = list()

	var/list/spell_list = list() // Wizard mode & "Give Spell" badmin button.
	var/datum/martial_art/martial_art

	var/role_alt_title

	var/datum/job/assigned_job
	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()
	var/list/targets = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	var/miming = 0 // Mime's vow of silence
	var/list/antag_datums
	var/datum/changeling/changeling		//changeling holder
	var/linglink
	var/datum/vampire/vampire			//vampire holder

	var/antag_hud_icon_state = null //this mind's ANTAG_HUD should have this icon_state
	var/datum/atom_hud/antag/antag_hud = null //this mind's antag HUD
	var/datum/mindslaves/som //stands for slave or master...hush..
	var/datum/mind/soulOwner //who owns the soul.  Under normal circumstances, this will point to src
	var/hasSoul = TRUE

	var/isholy = FALSE // is this person a chaplain or admin role allowed to use bibles
	var/isblessed = FALSE // is this person blessed by a chaplain?
	var/num_blessed = 0 // for prayers

	var/suicided = FALSE

	//put this here for easier tracking ingame
	var/datum/money_account/initial_account

	//zealot_master is a reference to the mob that converted them into a zealot (for ease of investigation and such)
	var/mob/living/carbon/human/zealot_master = null

	var/list/learned_recipes //List of learned recipe TYPES.

/datum/mind/New(new_key)
	key = new_key
	soulOwner = src

/datum/mind/Destroy()
	SSticker.minds -= src
	if(islist(antag_datums))
		for(var/i in antag_datums)
			var/datum/antagonist/antag_datum = i
			if(antag_datum.delete_on_mind_deletion)
				qdel(i)
		antag_datums = null
	current = null
	original = null
	soulOwner = null
	return ..()

/datum/mind/proc/transfer_to(mob/living/new_character)
	var/datum/atom_hud/antag/hud_to_transfer = antag_hud //we need this because leave_hud() will clear this list
	var/mob/living/old_current = current
	if(!istype(new_character))
		log_runtime(EXCEPTION("transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob."), src)
	if(current)					//remove ourself from our old body's mind variable
		current.mind = null
		leave_all_huds() //leave all the huds in the old body, so it won't get huds if somebody else enters it

		SStgui.on_transfer(current, new_character)

	if(new_character.mind)		//remove any mind currently in our new body's mind variable
		new_character.mind.current = null
	current = new_character		//link ourself to our new body
	new_character.mind = src	//and link our new body to ourself
	if(ishuman(old_current))	//cambio hispano para tranferir quirks
		old_current.transfer_trait_datums(current) //para transfererir quirks
	for(var/a in antag_datums)	//Makes sure all antag datums effects are applied in the new body
		var/datum/antagonist/A = a
		A.on_body_transfer(old_current, current)
	transfer_antag_huds(hud_to_transfer)				//inherit the antag HUD
	transfer_actions(new_character)
	if(martial_art)
		if(martial_art.temporary)
			martial_art.remove(current)
		else
			martial_art.teach(current)

	if(special_role)	//para que los antagas tengan las todas las habilidades basicas
		new_character.remove_all_quirks()
		new_character.add_antag_quirks() //fin para que los antags tengan los quirks basicos
	if(active)
		new_character.key = key		//now transfer the key to link the client to our new body
	SEND_SIGNAL(src, COMSIG_MIND_TRANSER_TO, new_character)

/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<BR>"

/datum/mind/proc/wipe_memory()
	memory = null

/datum/mind/proc/show_memory(mob/recipient, window = 1)
	if(!recipient)
		recipient = current
	var/output = "<B>[current.real_name]'s Memories:</B><HR>"
	output += memory

	var/antag_datum_objectives = FALSE
	for(var/datum/antagonist/A in antag_datums)
		output += A.antag_memory
		if(!antag_datum_objectives && LAZYLEN(A.objectives))
			antag_datum_objectives = TRUE

	if(LAZYLEN(objectives) || antag_datum_objectives)
		output += "<HR><B>Objectives:</B><BR>"
		output += gen_objective_text()

	if(LAZYLEN(job_objectives))
		output += "<HR><B>Job Objectives:</B><UL>"

		var/obj_count = 1
		for(var/datum/job_objective/objective in job_objectives)
			output += "<LI><B>Task #[obj_count]</B>: [objective.get_description()]</LI>"
			obj_count++
		output += "</UL>"
	if(window)
		recipient << browse(output, "window=memory")
	else
		to_chat(recipient, "<i>[output]</i>")

/datum/mind/proc/gen_objective_text(admin = FALSE)
	. = ""
	var/obj_count = 1
	var/list/all_objectives = list()
	for(var/datum/antagonist/A in antag_datums)
		all_objectives |= A.objectives

	if(LAZYLEN(all_objectives))
		for(var/datum/objective/objective in all_objectives)
			. += "<br><B>Objective #[obj_count++]</B>: [objective.explanation_text]"

	for(var/datum/objective/objective in objectives)
		. += "<b>Objective #[obj_count++]</b>: [objective.explanation_text]"
		if(admin)
			. += " <a href='?src=[UID()];obj_edit=\ref[objective]'>Edit</a> " // Edit
			. += "<a href='?src=[UID()];obj_delete=\ref[objective]'>Delete</a> " // Delete

			. += "<a href='?src=[UID()];obj_completed=\ref[objective]'>" // Mark Completed
			. += "<font color=[objective.completed ? "green" : "red"]>Toggle Completion</font>"
			. += "</a>"
		. += "<br>"

/datum/mind/proc/_memory_edit_header(gamemode, list/alt)
	. = gamemode
	if(SSticker.mode.config_tag == gamemode || (LAZYLEN(alt) && (SSticker.mode.config_tag in alt)))
		. = uppertext(.)
	. = "<i><b>[.]</b></i>: "

/datum/mind/proc/_memory_edit_role_enabled(role)
	. = "|Disabled in Prefs"
	if(current && current.client && (role in current.client.prefs.be_special))
		. = "|Enabled in Prefs"

/datum/mind/proc/memory_edit_implant(mob/living/carbon/human/H)
	if(ismindshielded(H))
		. = "Mindshield Implant:<a href='?src=[UID()];implant=remove'>Remove</a>|<b><font color='green'>Implanted</font></b></br>"
	else
		. = "Mindshield Implant:<b>No Implant</b>|<a href='?src=[UID()];implant=add'>Implant [H.p_them()]!</a></br>"


/datum/mind/proc/memory_edit_revolution(mob/living/carbon/human/H)
	. = _memory_edit_header("revolution")
	if(ismindshielded(H))
		. += "<b>NO</b>|headrev|rev"
	else if(src in SSticker.mode.head_revolutionaries)
		. += "<a href='?src=[UID()];revolution=clear'>no</a>|<b><font color='red'>HEADREV</font></b>|<a href='?src=[UID()];revolution=rev'>rev</a>"
		. += "<br>Flash: <a href='?src=[UID()];revolution=flash'>give</a>"

		var/list/L = current.get_contents()
		var/obj/item/flash/flash = locate() in L
		if(flash)
			if(!flash.broken)
				. += "|<a href='?src=[UID()];revolution=takeflash'>take</a>."
			else
				. += "|<a href='?src=[UID()];revolution=takeflash'>take</a>|<a href='?src=[UID()];revolution=repairflash'>repair</a>."
		else
			. += "."

		. += " <a href='?src=[UID()];revolution=reequip'>Reequip</a> (gives traitor uplink)."
		if(objectives.len==0)
			. += "<br>Objectives are empty! <a href='?src=[UID()];revolution=autoobjectives'>Set to kill all heads</a>."
	else if(src in SSticker.mode.revolutionaries)
		. += "<a href='?src=[UID()];revolution=clear'>no</a>|<a href='?src=[UID()];revolution=headrev'>headrev</a>|<b><font color='red'>REV</font></b>"
	else
		. += "<b>NO</b>|<a href='?src=[UID()];revolution=headrev'>headrev</a>|<a href='?src=[UID()];revolution=rev'>rev</a>"

	. += _memory_edit_role_enabled(ROLE_REV)

/datum/mind/proc/memory_edit_cult(mob/living/carbon/human/H)
	. = _memory_edit_header("cult")
	if(src in SSticker.mode.cult)
		. += "<a href='?src=[UID()];cult=clear'>no</a>|<b><font color='red'>CULTIST</font></b>"
		. += "<br>Give <a href='?src=[UID()];cult=dagger'>dagger</a>|<a href='?src=[UID()];cult=runedmetal'>runedmetal</a>."
	else
		. += "<b>NO</b>|<a href='?src=[UID()];cult=cultist'>cultist</a>"

	. += _memory_edit_role_enabled(ROLE_CULTIST)

/datum/mind/proc/memory_edit_wizard(mob/living/carbon/human/H)
	. = _memory_edit_header("wizard")
	if(src in SSticker.mode.wizards)
		. += "<b><font color='red'>WIZARD</font></b>|<a href='?src=[UID()];wizard=clear'>no</a>"
		. += "<br><a href='?src=[UID()];wizard=lair'>To lair</a>, <a href='?src=[UID()];common=undress'>undress</a>, <a href='?src=[UID()];wizard=dressup'>dress up</a>, <a href='?src=[UID()];wizard=name'>let choose name</a>."
		if(objectives.len==0)
			. += "<br>Objectives are empty! <a href='?src=[UID()];wizard=autoobjectives'>Randomize!</a>"
	else
		. += "<a href='?src=[UID()];wizard=wizard'>wizard</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_WIZARD)

/datum/mind/proc/memory_edit_changeling(mob/living/carbon/human/H)
	. = _memory_edit_header("changeling", list("traitorchan"))
	if(src in SSticker.mode.changelings)
		. += "<b><font color='red'>CHANGELING</font></b>|<a href='?src=[UID()];changeling=clear'>no</a>"
		if(objectives.len==0)
			. += "<br>Objectives are empty! <a href='?src=[UID()];changeling=autoobjectives'>Randomize!</a>"
		if(changeling && changeling.absorbed_dna.len && (current.real_name != changeling.absorbed_dna[1]))
			. += "<br><a href='?src=[UID()];changeling=initialdna'>Transform to initial appearance.</a>"
	else
		. += "<a href='?src=[UID()];changeling=changeling'>changeling</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_CHANGELING)

/datum/mind/proc/memory_edit_vampire(mob/living/carbon/human/H)
	. = _memory_edit_header("vampire", list("traitorvamp"))
	if(src in SSticker.mode.vampires)
		. += "<b><font color='red'>VAMPIRE</font></b>|<a href='?src=[UID()];vampire=clear'>no</a>"
		if(objectives.len==0)
			. += "<br>Objectives are empty! <a href='?src=[UID()];vampire=autoobjectives'>Randomize!</a>"
	else
		. += "<a href='?src=[UID()];vampire=vampire'>vampire</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_VAMPIRE)
	/** Enthralled ***/
	. += "<br><b><i>enthralled</i></b>: "
	if(src in SSticker.mode.vampire_enthralled)
		. += "<b><font color='red'>THRALL</font></b>|<a href='?src=[UID()];vampthrall=clear'>no</a>"
	else
		. += "thrall|<b>NO</b>"

/datum/mind/proc/memory_edit_nuclear(mob/living/carbon/human/H)
	. = _memory_edit_header("nuclear")
	if(src in SSticker.mode.syndicates)
		. += "<b><font color='red'>OPERATIVE</b></font>|<a href='?src=[UID()];nuclear=clear'>no</a>"
		. += "<br><a href='?src=[UID()];nuclear=lair'>To shuttle</a>, <a href='?src=[UID()];common=undress'>undress</a>, <a href='?src=[UID()];nuclear=dressup'>dress up</a>."
		var/code
		for(var/obj/machinery/nuclearbomb/bombue in GLOB.machines)
			if(length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
				code = bombue.r_code
				break
		if(code)
			. += " Code is [code]. <a href='?src=[UID()];nuclear=tellcode'>tell the code.</a>"
	else
		. += "<a href='?src=[UID()];nuclear=nuclear'>operative</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_OPERATIVE)

/datum/mind/proc/memory_edit_shadowling(mob/living/carbon/human/H)
	. = _memory_edit_header("shadowling")
	if(src in SSticker.mode.shadows)
		. += "<b><font color='red'>SHADOWLING</font></b>|thrall|<a href='?src=[UID()];shadowling=clear'>no</a>"
	else if(src in SSticker.mode.shadowling_thralls)
		. += "Shadowling|<b><font color='red'>THRALL</font></b>|<a href='?src=[UID()];shadowling=clear'>no</a>"
	else
		. += "<a href='?src=[UID()];shadowling=shadowling'>shadowling</a>|<a href='?src=[UID()];shadowling=thrall'>thrall</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_SHADOWLING)

/datum/mind/proc/memory_edit_abductor(mob/living/carbon/human/H)
	. = _memory_edit_header("abductor")
	if(src in SSticker.mode.abductors)
		. += "<b><font color='red'>ABDUCTOR</font></b>|<a href='?src=[UID()];abductor=clear'>no</a>"
		. += "|<a href='?src=[UID()];common=undress'>undress</a>|<a href='?src=[UID()];abductor=equip'>equip</a>"
	else
		. += "<a href='?src=[UID()];abductor=abductor'>abductor</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_ABDUCTOR)

/datum/mind/proc/memory_edit_eventmisc(mob/living/H)
	. = _memory_edit_header("event", list())
	if(src in SSticker.mode.eventmiscs)
		. += "<b>YES</b>|<a href='?src=[UID()];eventmisc=clear'>no</a>"
	else
		. += "<a href='?src=[UID()];eventmisc=eventmisc'>Event Role</a>|<b>NO</b>"

/datum/mind/proc/memory_edit_traitor()
	. = _memory_edit_header("traitor", list("traitorchan", "traitorvamp"))
	if(has_antag_datum(/datum/antagonist/traitor))
		. += "<b><font color='red'>TRAITOR</font></b>|<a href='?src=[UID()];traitor=clear'>no</a>"
		if(objectives.len==0)
			. += "<br>Objectives are empty! <a href='?src=[UID()];traitor=autoobjectives'>Randomize!</a>"
	else
		. += "<a href='?src=[UID()];traitor=traitor'>traitor</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_TRAITOR)
	// Contractor
	. += "<br><b><i>contractor</i></b>: "
	var/datum/contractor_hub/H = LAZYACCESS(GLOB.contractors, src)
	if(H)
		. += "<b><font color='red'>CONTRACTOR</font></b>"
		// List all their contracts
		. += "<br><b>Contracts:</b>"
		if(H.contracts)
			var/count = 1
			for(var/co in H.contracts)
				var/datum/syndicate_contract/CO = co
				. += "<br><B>Contract #[count++]</B>: "
				. += "<a href='?src=[UID()];cuid=[CO.UID()];contractor=target'><b>[CO.contract.target?.name || "Invalid target!"]</b></a>|"
				. += "<a href='?src=[UID()];cuid=[CO.UID()];contractor=locations'>locations</a>|"
				. += "<a href='?src=[UID()];cuid=[CO.UID()];contractor=other'>more</a>|"
				switch(CO.status)
					if(CONTRACT_STATUS_INVALID)
						. += "<b>INVALID</b>"
					if(CONTRACT_STATUS_INACTIVE)
						. += "inactive"
					if(CONTRACT_STATUS_ACTIVE)
						. += "<b><font color='orange'>ACTIVE</font></b>|"
						. += "<a href='?src=[UID()];cuid=[CO.UID()];contractor=interrupt'>interrupt</a>|"
						. += "<a href='?src=[UID()];cuid=[CO.UID()];contractor=fail'>fail</a>"
					if(CONTRACT_STATUS_COMPLETED)
						. += "<font color='green'>COMPLETED</font>"
					if(CONTRACT_STATUS_FAILED)
						. += "<font color='red'>FAILED</font>"
			. += "<br>"
			. += "<a href='?src=[UID()];contractor=add'>Add Contract</a><br>"
			. += "Claimable TC: <a href='?src=[UID()];contractor=tc'>[H.reward_tc_available]</a><br>"
			. += "Available Rep: <a href='?src=[UID()];contractor=rep'>[H.rep]</a><br>"
		else
			. += "<br>"
			. += "<i>Has not logged in to contractor uplink</i>"
	else
		. += "<b>NO</b>"
	// Mindslave
	. += "<br><b><i>mindslaved</i></b>: "
	if(has_antag_datum(/datum/antagonist/mindslave))
		. += "<b><font color='red'>MINDSLAVE</font></b>|<a href='?src=[UID()];mindslave=clear'>no</a>"
	else
		. += "mindslave|<b>NO</b>"

/datum/mind/proc/memory_edit_silicon()
	. = "<i><b>Silicon</b></i>: "
	var/mob/living/silicon/robot/robot = current
	if(istype(robot) && robot.emagged)
		. += "<br>Cyborg: <b><font color='red'>Is emagged!</font></b> <a href='?src=[UID()];silicon=unemag'>Unemag!</a><br>0th law: [robot.laws.zeroth_law]"
	var/mob/living/silicon/ai/ai = current
	if(istype(ai) && ai.connected_robots.len)
		var/n_e_robots = 0
		for(var/mob/living/silicon/robot/R in ai.connected_robots)
			if(R.emagged)
				n_e_robots++
		. += "<br>[n_e_robots] of [ai.connected_robots.len] slaved cyborgs are emagged. <a href='?src=[UID()];silicon=unemagcyborgs'>Unemag</a>"

/datum/mind/proc/memory_edit_uplink()
	. = ""
	if(ishuman(current) && ((src in SSticker.mode.head_revolutionaries) || \
		(has_antag_datum(/datum/antagonist/traitor)) || \
		(src in SSticker.mode.syndicates)))
		. = "Uplink: <a href='?src=[UID()];common=uplink'>give</a>"
		var/obj/item/uplink/hidden/suplink = find_syndicate_uplink()
		var/crystals
		if(suplink)
			crystals = suplink.uses
		if(suplink)
			. += "|<a href='?src=[UID()];common=takeuplink'>take</a>"
			if(usr.client.holder.rights & (R_SERVER|R_EVENT))
				. += ", <a href='?src=[UID()];common=crystals'>[crystals]</a> crystals"
			else
				. += ", [crystals] crystals"
		. += "." //hiel grammar
		//         ^ whoever left this comment is literally a grammar nazi. stalin better. in russia grammar correct you.

/datum/mind/proc/edit_memory()
	if(!SSticker || !SSticker.mode)
		alert("Not before round-start!", "Alert")
		return

	var/out = "<B>[name]</B>[(current && (current.real_name != name))?" (as [current.real_name])" : ""]<br>"
	out += "Mind currently owned by key: [key] [active ? "(synced)" : "(not synced)"]<br>"
	out += "Assigned role: [assigned_role]. <a href='?src=[UID()];role_edit=1'>Edit</a><br>"
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
	)
	var/mob/living/carbon/human/H = current
	if(ishuman(current))
		/** Impanted**/
		sections["implant"] = memory_edit_implant(H)
		/** REVOLUTION ***/
		sections["revolution"] = memory_edit_revolution(H)
		/** WIZARD ***/
		sections["wizard"] = memory_edit_wizard(H)
		/** CHANGELING ***/
		sections["changeling"] = memory_edit_changeling(H)
		/** VAMPIRE ***/
		sections["vampire"] = memory_edit_vampire(H)
		/** NUCLEAR ***/
		sections["nuclear"] = memory_edit_nuclear(H)
		/** SHADOWLING **/
		sections["shadowling"] = memory_edit_shadowling(H)
		/** Abductors **/
		sections["abductor"] = memory_edit_abductor(H)
	sections["eventmisc"] = memory_edit_eventmisc(H)
	/** TRAITOR ***/
	sections["traitor"] = memory_edit_traitor()
	if(!issilicon(current))
		/** CULT ***/
		sections["cult"] = memory_edit_cult(H)
	/** SILICON ***/
	if(issilicon(current))
		sections["silicon"] = memory_edit_silicon()
	/*
		This prioritizes antags relevant to the current round to make them appear at the top of the panel.
		Traitorchan and traitorvamp are snowflaked in because they have multiple sections.
	*/
	if(SSticker.mode.config_tag == "traitorchan")
		if(sections["traitor"])
			out += sections["traitor"] + "<br>"
		if(sections["changeling"])
			out += sections["changeling"] + "<br>"
		sections -= "traitor"
		sections -= "changeling"
	// Elif technically unnecessary but it makes the following else look better
	else if(SSticker.mode.config_tag == "traitorvamp")
		if(sections["traitor"])
			out += sections["traitor"] + "<br>"
		if(sections["vampire"])
			out += sections["vampire"] + "<br>"
		sections -= "traitor"
		sections -= "vampire"
	else
		if(sections[SSticker.mode.config_tag])
			out += sections[SSticker.mode.config_tag] + "<br>"
		sections -= SSticker.mode.config_tag

	for(var/i in sections)
		if(sections[i])
			out += sections[i] + "<br>"

	out += memory_edit_uplink()
	out += "<br>"

	out += "<b>Memory:</b><br>"
	out += memory
	out += "<br><a href='?src=[UID()];memory_edit=1'>Edit memory</a><br>"
	out += "Objectives:<br>"
	if(objectives.len == 0)
		out += "EMPTY<br>"
	else
		out += gen_objective_text(admin = TRUE)
	out += "<a href='?src=[UID()];obj_add=1'>Add objective</a><br><br>"
	out += "<a href='?src=[UID()];obj_announce=1'>Announce objectives</a><br><br>"
	usr << browse(out, "window=edit_memory[src];size=500x500")

/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return

	if(href_list["role_edit"])
		var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in GLOB.joblist
		if(!new_role)
			return
		assigned_role = new_role
		log_admin("[key_name(usr)] has changed [key_name(current)]'s assigned role to [assigned_role]")
		message_admins("[key_name_admin(usr)] has changed [key_name_admin(current)]'s assigned role to [assigned_role]")

	else if(href_list["memory_edit"])
		var/messageinput = input("Write new memory", "Memory", memory) as null|message
		if(isnull(messageinput))
			return
		var/new_memo = copytext(messageinput, 1,MAX_MESSAGE_LEN)
		var/confirmed = alert(usr, "Are you sure you want to edit their memory? It will wipe out their original memory!", "Edit Memory", "Yes", "No")
		if(confirmed == "Yes") // Because it is too easy to accidentally wipe someone's memory
			memory = new_memo
			log_admin("[key_name(usr)] has edited [key_name(current)]'s memory")
			message_admins("[key_name_admin(usr)] has edited [key_name_admin(current)]'s memory")

	else if(href_list["obj_edit"] || href_list["obj_add"])
		var/datum/objective/objective
		var/objective_pos
		var/def_value

		if(href_list["obj_edit"])
			objective = locate(href_list["obj_edit"])
			if(!objective)
				return
			objective_pos = objectives.Find(objective)

			//Text strings are easy to manipulate. Revised for simplicity.
			var/temp_obj_type = "[objective.type]"//Convert path into a text string.
			def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
			if(!def_value)//If it's a custom objective, it will be an empty string.
				def_value = "custom"

		var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "blood", "debrain", "protect", "prevent", "brig", "hijack", "escape", "survive", "steal", "download", "nuclear", "capture", "absorb", "destroy", "maroon", "identity theft", "custom")
		if(!new_obj_type)
			return

		var/datum/objective/new_objective = null

		switch(new_obj_type)
			if("assassinate","protect","debrain", "brig", "maroon")
				//To determine what to name the objective in explanation text.
				var/objective_type_capital = uppertext(copytext(new_obj_type, 1,2))//Capitalize first letter.
				var/objective_type_text = copytext(new_obj_type, 2)//Leave the rest of the text.
				var/objective_type = "[objective_type_capital][objective_type_text]"//Add them together into a text string.

				var/list/possible_targets = list()
				for(var/datum/mind/possible_target in SSticker.minds)
					if((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
						possible_targets += possible_target.current

				var/mob/def_target = null
				var/objective_list[] = list(/datum/objective/assassinate, /datum/objective/protect, /datum/objective/debrain)
				if(objective&&(objective.type in objective_list) && objective:target)
					def_target = objective.target.current
				possible_targets = sortAtom(possible_targets)

				var/new_target
				if(length(possible_targets) > 0)
					if(alert(usr, "Do you want to pick the objective yourself? No will randomise it", "Pick objective", "Yes", "No") == "Yes")
						possible_targets += "Free objective"
						new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
					else
						new_target = pick(possible_targets)

					if(!new_target)
						return
				else
					to_chat(usr, "<span class='warning'>No possible target found. Defaulting to a Free objective.</span>")
					new_target = "Free objective"

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
					//Will display as special role if assigned mode is equal to special role.. Ninjas/commandos/nuke ops.
					new_objective.explanation_text = "[objective_type] [new_target:real_name], the [new_target:mind:assigned_role == new_target:mind:special_role ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."

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
						new_objective.explanation_text = "Accumulate at least [target_number] total units of blood."
				new_objective.owner = src
				new_objective.target_amount = target_number

			if("identity theft")
				var/list/possible_targets = list()
				for(var/datum/mind/possible_target in SSticker.minds)
					if((possible_target != src) && ishuman(possible_target.current))
						possible_targets += possible_target
				possible_targets = sortAtom(possible_targets)
				possible_targets += "Free objective"
				var/new_target = input("Select target:", "Objective target") as null|anything in possible_targets
				if(!new_target)
					return
				var/datum/mind/targ = new_target
				if(!istype(targ))
					log_runtime(EXCEPTION("Invalid target for identity theft objective, cancelling"), src)
					return
				new_objective = new /datum/objective/escape/escape_with_identity
				new_objective.owner = src
				new_objective.target = new_target
				new_objective.explanation_text = "Escape on the shuttle or an escape pod with the identity of [targ.current.real_name], the [targ.assigned_role] while wearing [targ.current.p_their()] identification card."
			if("custom")
				var/expl = sanitize(copytext(input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null,1,MAX_MESSAGE_LEN))
				if(!expl)
					return
				new_objective = new /datum/objective
				new_objective.owner = src
				new_objective.explanation_text = expl

		if(!new_objective)
			return

		if(objective)
			objectives -= objective
			qdel(objective)
			objectives.Insert(objective_pos, new_objective)
		else
			objectives += new_objective

		log_admin("[key_name(usr)] has updated [key_name(current)]'s objectives: [new_objective]")
		message_admins("[key_name_admin(usr)] has updated [key_name_admin(current)]'s objectives: [new_objective]")

	else if(href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		if(!istype(objective))
			return
		objectives -= objective

		log_admin("[key_name(usr)] has removed one of [key_name(current)]'s objectives: [objective]")
		message_admins("[key_name_admin(usr)] has removed one of [key_name_admin(current)]'s objectives: [objective]")
		qdel(objective)

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		if(!istype(objective))
			return
		objective.completed = !objective.completed

		log_admin("[key_name(usr)] has toggled the completion of one of [key_name(current)]'s objectives")
		message_admins("[key_name_admin(usr)] has toggled the completion of one of [key_name_admin(current)]'s objectives")

	else if(href_list["implant"])
		var/mob/living/carbon/human/H = current

		switch(href_list["implant"])
			if("remove")
				for(var/obj/item/implant/mindshield/I in H.contents)
					if(I && I.implanted)
						qdel(I)
				to_chat(H, "<span class='notice'><Font size =3><B>Your mindshield implant has been deactivated.</B></FONT></span>")
				log_admin("[key_name(usr)] has deactivated [key_name(current)]'s mindshield implant")
				message_admins("[key_name_admin(usr)] has deactivated [key_name_admin(current)]'s mindshield implant")
			if("add")
				var/obj/item/implant/mindshield/L = new/obj/item/implant/mindshield(H)
				L.implant(H)

				log_admin("[key_name(usr)] has given [key_name(current)] a mindshield implant")
				message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] a mindshield implant")

				to_chat(H, "<span class='warning'><Font size =3><B>You somehow have become the recepient of a mindshield transplant, and it just activated!</B></FONT></span>")
				if(src in SSticker.mode.revolutionaries)
					special_role = null
					SSticker.mode.revolutionaries -= src
					to_chat(src, "<span class='warning'><Font size = 3><B>The nanobots in the mindshield implant remove all thoughts about being a revolutionary.  Get back to work!</B></Font></span>")
				if(src in SSticker.mode.head_revolutionaries)
					special_role = null
					SSticker.mode.head_revolutionaries -=src
					to_chat(src, "<span class='warning'><Font size = 3><B>The nanobots in the mindshield implant remove all thoughts about being a revolutionary.  Get back to work!</B></Font></span>")

	else if(href_list["revolution"])

		switch(href_list["revolution"])
			if("clear")
				if(src in SSticker.mode.revolutionaries)
					SSticker.mode.revolutionaries -= src
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a revolutionary!</B></FONT></span>")
					SSticker.mode.update_rev_icons_removed(src)
					special_role = null
				if(src in SSticker.mode.head_revolutionaries)
					SSticker.mode.head_revolutionaries -= src
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a head revolutionary!</B></FONT></span>")
					SSticker.mode.update_rev_icons_removed(src)
					special_role = null
				log_admin("[key_name(usr)] has de-rev'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-rev'd [key_name_admin(current)]")

			if("rev")
				if(src in SSticker.mode.head_revolutionaries)
					SSticker.mode.head_revolutionaries -= src
					SSticker.mode.update_rev_icons_removed(src)
					to_chat(current, "<span class='warning'><FONT size = 3><B>Revolution has been disappointed of your leadership traits! You are a regular revolutionary now!</B></FONT></span>")
				else if(!(src in SSticker.mode.revolutionaries))
					to_chat(current, "<span class='warning'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>")
				else
					return
				SSticker.mode.revolutionaries += src
				SSticker.mode.update_rev_icons_added(src)
				special_role = SPECIAL_ROLE_REV
				log_admin("[key_name(usr)] has rev'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has rev'd [key_name_admin(current)]")

			if("headrev")
				if(src in SSticker.mode.revolutionaries)
					SSticker.mode.revolutionaries -= src
					SSticker.mode.update_rev_icons_removed(src)
					to_chat(current, "<span class='userdanger'>You have proven your devotion to revolution! You are a head revolutionary now!</span>")
				else if(!(src in SSticker.mode.head_revolutionaries))
					to_chat(current, "<span class='notice'>You are a member of the revolutionaries' leadership now!</span>")
				else
					return
				if(SSticker.mode.head_revolutionaries.len>0)
					// copy targets
					var/datum/mind/valid_head = locate() in SSticker.mode.head_revolutionaries
					if(valid_head)
						for(var/datum/objective/mutiny/O in valid_head.objectives)
							var/datum/objective/mutiny/rev_obj = new
							rev_obj.owner = src
							rev_obj.target = O.target
							rev_obj.explanation_text = "Assassinate [O.target.name], the [O.target.assigned_role]."
							objectives += rev_obj
						SSticker.mode.greet_revolutionary(src,0)
				SSticker.mode.head_revolutionaries += src
				SSticker.mode.update_rev_icons_added(src)
				special_role = SPECIAL_ROLE_HEAD_REV
				log_admin("[key_name(usr)] has head-rev'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has head-rev'd [key_name_admin(current)]")

			if("autoobjectives")
				SSticker.mode.forge_revolutionary_objectives(src)
				SSticker.mode.greet_revolutionary(src,0)
				log_admin("[key_name(usr)] has automatically forged revolutionary objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged revolutionary objectives for [key_name_admin(current)]")

			if("flash")
				if(!SSticker.mode.equip_revolutionary(current))
					to_chat(usr, "<span class='warning'>Spawning flash failed!</span>")
				log_admin("[key_name(usr)] has given [key_name(current)] a flash")
				message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] a flash")

			if("takeflash")
				var/list/L = current.get_contents()
				var/obj/item/flash/flash = locate() in L
				if(!flash)
					to_chat(usr, "<span class='warning'>Deleting flash failed!</span>")
				qdel(flash)
				log_admin("[key_name(usr)] has taken [key_name(current)]'s flash")
				message_admins("[key_name_admin(usr)] has taken [key_name_admin(current)]'s flash")

			if("repairflash")
				var/list/L = current.get_contents()
				var/obj/item/flash/flash = locate() in L
				if(!flash)
					to_chat(usr, "<span class='warning'>Repairing flash failed!</span>")
				else
					flash.broken = 0
					log_admin("[key_name(usr)] has repaired [key_name(current)]'s flash")
					message_admins("[key_name_admin(usr)] has repaired [key_name_admin(current)]'s flash")

			if("reequip")
				var/list/L = current.get_contents()
				var/obj/item/flash/flash = locate() in L
				qdel(flash)
				take_uplink()
				var/fail = 0
				var/datum/antagonist/traitor/T = has_antag_datum(/datum/antagonist/traitor)
				fail |= !T.equip_traitor(src)
				fail |= !SSticker.mode.equip_revolutionary(current)
				if(fail)
					to_chat(usr, "<span class='warning'>Reequipping revolutionary goes wrong!</span>")
					return
				log_admin("[key_name(usr)] has equipped [key_name(current)] as a revolutionary")
				message_admins("[key_name_admin(usr)] has equipped [key_name_admin(current)] as a revolutionary")

	else if(href_list["cult"])
		switch(href_list["cult"])
			if("clear")
				if(src in SSticker.mode.cult)
					SSticker.mode.remove_cultist(src)
					special_role = null
					log_admin("[key_name(usr)] has de-culted [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-culted [key_name_admin(current)]")
			if("cultist")
				if(!(src in SSticker.mode.cult))
					to_chat(current, CULT_GREETING)
					SSticker.mode.add_cultist(src)
					to_chat(current, "<span class='cultitalic'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve [SSticker.cultdat.entity_title2] above all else. Bring It back.</span>")
					log_and_message_admins("[key_name(usr)] has culted [key_name(current)]")
			if("dagger")
				var/mob/living/carbon/human/H = current
				if(!SSticker.mode.cult_give_item(/obj/item/melee/cultblade/dagger, H))
					to_chat(usr, "<span class='warning'>Spawning dagger failed!</span>")
				log_and_message_admins("[key_name(usr)] has equipped [key_name(current)] with a cult dagger")
			if("runedmetal")
				var/mob/living/carbon/human/H = current
				if(!SSticker.mode.cult_give_item(/obj/item/stack/sheet/runed_metal/ten, H))
					to_chat(usr, "<span class='warning'>Spawning runed metal failed!</span>")
				log_and_message_admins("[key_name(usr)] has equipped [key_name(current)] with 10 runed metal sheets")

	else if(href_list["wizard"])

		switch(href_list["wizard"])
			if("clear")
				if(src in SSticker.mode.wizards)
					SSticker.mode.wizards -= src
					special_role = null
					current.spellremove(current)
					current.faction = list("Station")
					SSticker.mode.update_wiz_icons_removed(src)
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a wizard!</B></FONT></span>")
					log_admin("[key_name(usr)] has de-wizarded [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-wizarded [key_name_admin(current)]")
			if("wizard")
				if(!(src in SSticker.mode.wizards))
					SSticker.mode.wizards += src
					special_role = SPECIAL_ROLE_WIZARD
					//ticker.mode.learn_basic_spells(current)
					SSticker.mode.update_wiz_icons_added(src)
					SEND_SOUND(current, sound('sound/ambience/antag/ragesmages.ogg'))
					to_chat(current, "<span class='danger'>You are a Space Wizard!</span>")
					current.faction = list("wizard")
					log_admin("[key_name(usr)] has wizarded [key_name(current)]")
					message_admins("[key_name_admin(usr)] has wizarded [key_name_admin(current)]")
			if("lair")
				current.forceMove(pick(GLOB.wizardstart))
				log_admin("[key_name(usr)] has moved [key_name(current)] to the wizard's lair")
				message_admins("[key_name_admin(usr)] has moved [key_name_admin(current)] to the wizard's lair")
			if("dressup")
				SSticker.mode.equip_wizard(current)
				log_admin("[key_name(usr)] has equipped [key_name(current)] as a wizard")
				message_admins("[key_name_admin(usr)] has equipped [key_name_admin(current)] as a wizard")
			if("name")
				INVOKE_ASYNC(SSticker.mode, /datum/game_mode/wizard.proc/name_wizard, current)
				log_admin("[key_name(usr)] has allowed wizard [key_name(current)] to name themselves")
				message_admins("[key_name_admin(usr)] has allowed wizard [key_name_admin(current)] to name themselves")
			if("autoobjectives")
				SSticker.mode.forge_wizard_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for wizard [key] have been generated. You can edit them and announce manually.</span>")
				log_admin("[key_name(usr)] has automatically forged wizard objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged wizard objectives for [key_name_admin(current)]")


	else if(href_list["changeling"])
		switch(href_list["changeling"])
			if("clear")
				if(src in SSticker.mode.changelings)
					SSticker.mode.changelings -= src
					special_role = null
					if(changeling)
						current.remove_changeling_powers()
						qdel(current.middleClickOverride) // In case the old changeling has a targeted sting prepared (`datum/middleClickOverride`), delete it.
						current.middleClickOverride = null
						qdel(changeling)
						changeling = null
					SSticker.mode.update_change_icons_removed(src)
					to_chat(current, "<FONT color='red' size = 3><B>You grow weak and lose your powers! You are no longer a changeling and are stuck in your current form!</B></FONT>")
					log_admin("[key_name(usr)] has de-changelinged [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-changelinged [key_name_admin(current)]")
			if("changeling")
				if(!(src in SSticker.mode.changelings))
					SSticker.mode.changelings += src
					SSticker.mode.grant_changeling_powers(current)
					SSticker.mode.update_change_icons_added(src)
					special_role = SPECIAL_ROLE_CHANGELING
					SEND_SOUND(current, sound('sound/ambience/antag/ling_aler.ogg'))
					to_chat(current, "<B><font color='red'>Your powers have awoken. A flash of memory returns to us... we are a changeling!</font></B>")
					log_admin("[key_name(usr)] has changelinged [key_name(current)]")
					message_admins("[key_name_admin(usr)] has changelinged [key_name_admin(current)]")

			if("autoobjectives")
				SSticker.mode.forge_changeling_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for changeling [key] have been generated. You can edit them and announce manually.</span>")
				log_admin("[key_name(usr)] has automatically forged objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged objectives for [key_name_admin(current)]")

			if("initialdna")
				if(!changeling || !changeling.absorbed_dna.len)
					to_chat(usr, "<span class='warning'>Resetting DNA failed!</span>")
				else
					current.dna = changeling.absorbed_dna[1]
					current.real_name = current.dna.real_name
					current.UpdateAppearance()
					domutcheck(current)
					log_admin("[key_name(usr)] has reset [key_name(current)]'s DNA")
					message_admins("[key_name_admin(usr)] has reset [key_name_admin(current)]'s DNA")

	else if(href_list["vampire"])
		switch(href_list["vampire"])
			if("clear")
				if(src in SSticker.mode.vampires)
					SSticker.mode.vampires -= src
					special_role = null
					if(vampire)
						vampire.remove_vampire_powers()
						qdel(vampire)
						vampire = null
					SSticker.mode.update_vampire_icons_removed(src)
					to_chat(current, "<FONT color='red' size = 3><B>You grow weak and lose your powers! You are no longer a vampire and are stuck in your current form!</B></FONT>")
					log_admin("[key_name(usr)] has de-vampired [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-vampired [key_name_admin(current)]")
			if("vampire")
				if(!(src in SSticker.mode.vampires))
					SSticker.mode.vampires += src
					SSticker.mode.grant_vampire_powers(current)
					SSticker.mode.update_vampire_icons_added(src)
					var/datum/mindslaves/slaved = new()
					slaved.masters += src
					som = slaved //we MIGT want to mindslave someone
					special_role = SPECIAL_ROLE_VAMPIRE
					SEND_SOUND(current, sound('sound/ambience/antag/vampalert.ogg'))
					to_chat(current, "<B><font color='red'>Your powers have awoken. Your lust for blood grows... You are a Vampire!</font></B>")
					log_admin("[key_name(usr)] has vampired [key_name(current)]")
					message_admins("[key_name_admin(usr)] has vampired [key_name_admin(current)]")

			if("autoobjectives")
				SSticker.mode.forge_vampire_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for vampire [key] have been generated. You can edit them and announce manually.</span>")
				log_admin("[key_name(usr)] has automatically forged objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged objectives for [key_name_admin(current)]")

	else if(href_list["vampthrall"])
		switch(href_list["vampthrall"])
			if("clear")
				if(src in SSticker.mode.vampire_enthralled)
					SSticker.mode.remove_vampire_mind(src)
					log_admin("[key_name(usr)] has de-vampthralled [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-vampthralled [key_name_admin(current)]")

	else if(href_list["nuclear"])
		var/mob/living/carbon/human/H = current

		switch(href_list["nuclear"])
			if("clear")
				if(src in SSticker.mode.syndicates)
					SSticker.mode.syndicates -= src
					SSticker.mode.update_synd_icons_removed(src)
					special_role = null
					for(var/datum/objective/nuclear/O in objectives)
						objectives-=O
						qdel(O)
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a syndicate operative!</B></FONT></span>")
					log_admin("[key_name(usr)] has de-nuke op'd [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-nuke op'd [key_name_admin(current)]")
			if("nuclear")
				if(!(src in SSticker.mode.syndicates))
					SSticker.mode.syndicates += src
					SSticker.mode.update_synd_icons_added(src)
					if(SSticker.mode.syndicates.len==1)
						SSticker.mode.prepare_syndicate_leader(src)
					else
						current.real_name = "[syndicate_name()] Operative #[SSticker.mode.syndicates.len-1]"
					special_role = SPECIAL_ROLE_NUKEOPS
					to_chat(current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
					SSticker.mode.forge_syndicate_objectives(src)
					SSticker.mode.greet_syndicate(src)
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
				qdel(H.wear_pda)
				qdel(H.wear_suit)
				qdel(H.w_uniform)

				if(!SSticker.mode.equip_syndicate(current))
					to_chat(usr, "<span class='warning'>Equipping a syndicate failed!</span>")
					return
				SSticker.mode.update_syndicate_id(current.mind, SSticker.mode.syndicates.len == 1)
				log_admin("[key_name(usr)] has equipped [key_name(current)] as a nuclear operative")
				message_admins("[key_name_admin(usr)] has equipped [key_name_admin(current)] as a nuclear operative")

			if("tellcode")
				var/code
				for(var/obj/machinery/nuclearbomb/bombue in GLOB.machines)
					if(length(bombue.r_code) <= 5 && bombue.r_code != "LOLNO" && bombue.r_code != "ADMIN")
						code = bombue.r_code
						break
				if(code)
					store_memory("<B>Syndicate Nuclear Bomb Code</B>: [code]", 0, 0)
					to_chat(current, "The nuclear authorization code is: <B>[code]</B>")
					log_admin("[key_name(usr)] has given [key_name(current)] the nuclear authorization code")
					message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] the nuclear authorization code")
				else
					to_chat(usr, "<span class='warning'>No valid nuke found!</span>")

	else if(href_list["eventmisc"])
		switch(href_list["eventmisc"])
			if("clear")
				if(src in SSticker.mode.eventmiscs)
					SSticker.mode.eventmiscs -= src
					SSticker.mode.update_eventmisc_icons_removed(src)
					special_role = null
					message_admins("[key_name_admin(usr)] has de-eventantag'ed [current].")
					log_admin("[key_name(usr)] has de-eventantag'ed [current].")
			if("eventmisc")
				SSticker.mode.eventmiscs += src
				special_role = SPECIAL_ROLE_EVENTMISC
				SSticker.mode.update_eventmisc_icons_added(src)
				message_admins("[key_name_admin(usr)] has eventantag'ed [current].")
				log_admin("[key_name(usr)] has eventantag'ed [current].")

	else if(href_list["traitor"])
		switch(href_list["traitor"])
			if("clear")
				if(has_antag_datum(/datum/antagonist/traitor))
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a traitor!</B></FONT></span>")
					remove_antag_datum(/datum/antagonist/traitor)
					current.client.chatOutput?.clear_syndicate_codes()
					log_admin("[key_name(usr)] has de-traitored [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-traitored [key_name_admin(current)]")

			if("traitor")
				if(!(has_antag_datum(/datum/antagonist/traitor)))
					var/datum/antagonist/traitor/T = new()
					T.give_objectives = FALSE
					T.should_equip = FALSE
					add_antag_datum(T)
					log_admin("[key_name(usr)] has traitored [key_name(current)]")
					message_admins("[key_name_admin(usr)] has traitored [key_name_admin(current)]")

			if("autoobjectives")
				var/datum/antagonist/traitor/T = has_antag_datum(/datum/antagonist/traitor)
				T.forge_traitor_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for traitor [key] have been generated. You can edit them and announce manually.</span>")
				log_admin("[key_name(usr)] has automatically forged objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged objectives for [key_name_admin(current)]")

	else if(href_list["contractor"])
		var/datum/contractor_hub/H = LAZYACCESS(GLOB.contractors, src)
		switch(href_list["contractor"])
			if("add")
				if(!H)
					return
				var/list/possible_targets = list()
				for(var/foo in SSticker.minds)
					var/datum/mind/possible_target = foo
					if(src == possible_target || !possible_target.current || !possible_target.key)
						continue
					possible_targets[possible_target.name] = possible_target

				var/choice = input(usr, "Select the contract target:", "Add Contract") as null|anything in possible_targets
				var/datum/mind/target = possible_targets[choice]
				if(!target || !target.current || !target.key)
					return
				var/datum/syndicate_contract/new_contract = new(H, src, list(), target)
				new_contract.reward_tc = list(0, 0, 0)
				H.contracts += new_contract
				SStgui.update_uis(H)
				log_admin("[key_name(usr)] has given a new contract to [key_name(current)] with [target.current] as the target")
				message_admins("[key_name_admin(usr)] has given a new contract to [key_name_admin(current)] with [target.current] as the target")

			if("tc")
				if(!H)
					return
				var/new_tc = input(usr, "Enter the new amount of TC:", "Set Claimable TC", H.reward_tc_available) as num|null
				new_tc = text2num(new_tc)
				if(isnull(new_tc) || new_tc < 0)
					return
				H.reward_tc_available = new_tc
				SStgui.update_uis(H)
				log_admin("[key_name(usr)] has set [key_name(current)]'s claimable TC to [new_tc]")
				message_admins("[key_name_admin(usr)] has set [key_name_admin(current)]'s claimable TC to [new_tc]")

			if("rep")
				if(!H)
					return
				var/new_rep = input(usr, "Enter the new amount of Rep:", "Set Available Rep", H.rep) as num|null
				new_rep = text2num(new_rep)
				if(isnull(new_rep) || new_rep < 0)
					return
				H.rep = new_rep
				SStgui.update_uis(H)
				log_admin("[key_name(usr)] has set [key_name(current)]'s contractor Rep to [new_rep]")
				message_admins("[key_name_admin(usr)] has set [key_name_admin(current)]'s contractor Rep to [new_rep]")

			// Contract specific actions
			if("target")
				if(!H)
					return
				var/datum/syndicate_contract/CO = locateUID(href_list["cuid"])
				if(!istype(CO))
					return

				var/list/possible_targets = list()
				for(var/foo in SSticker.minds)
					var/datum/mind/possible_target = foo
					if(src == possible_target || !possible_target.current || !possible_target.key)
						continue
					possible_targets[possible_target.name] = possible_target

				var/choice = input(usr, "Select the new contract target:", "Set Contract Target") as null|anything in possible_targets
				var/datum/mind/target = possible_targets[choice]
				if(!target || !target.current || !target.key)
					return
				// Update
				var/datum/data/record/R = find_record("name", target.name, GLOB.data_core.general)
				var/name = R?.fields["name"] || target.name || "Unknown"
				var/rank = R?.fields["rank"] || target.assigned_role || "Unknown"
				CO.contract.target = target
				CO.target_name = "[name], the [rank]"
				if(R?.fields["photo"])
					var/icon/temp = new('icons/turf/floors.dmi', pick("floor", "wood", "darkfull", "stairs"))
					temp.Blend(R.fields["photo"], ICON_OVERLAY)
					CO.target_photo = temp
				// Notify
				SStgui.update_uis(H)
				log_admin("[key_name(usr)] has set [key_name(current)]'s contract target to [target.current]")
				message_admins("[key_name_admin(usr)] has set [key_name_admin(current)]'s contract target to [target.current]")

			if("locations")
				if(!H)
					return
				var/datum/syndicate_contract/CO = locateUID(href_list["cuid"])
				if(!istype(CO))
					return

				var/list/difficulty_choices = list()
				for(var/diff in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
					var/area/A = CO.contract.candidate_zones[diff]
					difficulty_choices["[A.name] ([CO.reward_tc[diff]] TC)"] = diff

				var/choice_diff = input(usr, "Select the location to change:", "Set Contract Location") as null|anything in difficulty_choices
				var/difficulty = difficulty_choices[choice_diff]
				if(!difficulty)
					return

				var/list/area_choices = list()
				for(var/a in return_sorted_areas())
					var/area/A = a
					if(A.outdoors || !is_station_level(A.z))
						continue
					area_choices += A

				var/new_area = input(usr, "Select the new location:", "Set Contract Location", CO.contract.candidate_zones[difficulty]) in area_choices
				if(!new_area)
					return

				var/new_reward = input(usr, "Enter the new amount of rewarded TC:", "Set Contract Location", CO.reward_tc[difficulty]) as num|null
				new_reward = text2num(new_reward)
				if(isnull(new_reward) || new_reward < 0)
					return
				CO.contract.candidate_zones[difficulty] = new_area
				CO.reward_tc[difficulty] = new_reward
				SStgui.update_uis(H)
				log_admin("[key_name(usr)] has set [key_name(current)]'s contract location to [new_area] with [new_reward] TC as reward")
				message_admins("[key_name_admin(usr)] has set [key_name_admin(current)]'s contract location to [new_area] with [new_reward] TC as reward")

			if("other")
				if(!H)
					return
				var/datum/syndicate_contract/CO = locateUID(href_list["cuid"])
				if(!istype(CO))
					return

				var/choice = input(usr, "Select an action to take:", "Other Contract Actions") in list("Edit Fluff Message", "Edit Prison Time", "Edit Credits Reward", "Delete Contract", "Cancel")
				if(!choice)
					return

				switch(choice)
					if("Edit Fluff Message")
						var/new_message = input(usr, "Enter the new fluff message:", "Edit Fluff Message", CO.fluff_message) as message|null
						if(!new_message)
							return
						CO.fluff_message = new_message
						log_admin("[key_name(usr)] has edited [key_name(current)]'s contract fluff message")
						message_admins("[key_name_admin(usr)] has edited [key_name_admin(current)]'s contract fluff message")
					if("Edit Prison Time")
						var/new_time = input(usr, "Enter the new prison time in seconds:", "Edit Prison Time", CO.prison_time / 10) as num|null
						if(!new_time || new_time < 0)
							return
						CO.prison_time = new_time SECONDS
						log_admin("[key_name(usr)] has edited [key_name(current)]'s contract prison time to [new_time] seconds")
						message_admins("[key_name_admin(usr)] has edited [key_name_admin(current)]'s contract prison time to [new_time] seconds")
					if("Edit Credits Reward")
						var/new_creds = input(usr, "Enter the new credits reward:", "Edit Credits Reward", CO.reward_credits) as num|null
						if(!new_creds || new_creds < 0)
							return
						CO.reward_credits = new_creds
						log_admin("[key_name(usr)] has edited [key_name(current)]'s contract reward credits to [new_creds]")
						message_admins("[key_name_admin(usr)] has edited [key_name_admin(current)]'s contract reward credits to [new_creds]")
					if("Delete Contract")
						if(CO.status == CONTRACT_STATUS_ACTIVE)
							CO.fail("Contract interrupted forcibly.")
						H.contracts -= CO
						log_admin("[key_name(usr)] has deleted [key_name(current)]'s contract")
						message_admins("[key_name_admin(usr)] has deleted [key_name_admin(current)]'s contract")
					else
						return
				SStgui.update_uis(H)

			if("interrupt")
				if(!H)
					return
				var/datum/syndicate_contract/CO = locateUID(href_list["cuid"])
				if(!istype(CO) || CO.status != CONTRACT_STATUS_ACTIVE)
					return
				H.current_contract = null
				CO.contract.extraction_zone = null
				CO.status = CONTRACT_STATUS_INACTIVE
				CO.clean_up()
				log_admin("[key_name(usr)] has interrupted [key_name(current)]'s contract")
				message_admins("[key_name_admin(usr)] has interrupted [key_name_admin(current)]'s contract")

			if("fail")
				if(!H)
					return
				var/datum/syndicate_contract/CO = locateUID(href_list["cuid"])
				if(!istype(CO) || CO.status != CONTRACT_STATUS_ACTIVE)
					return
				var/fail_reason = sanitize(input(usr, "Enter the fail reason:", "Fail Contract") as text|null)
				if(!fail_reason || CO.status != CONTRACT_STATUS_ACTIVE)
					return
				CO.fail(fail_reason)
				SStgui.update_uis(H)
				log_admin("[key_name(usr)] has failed [key_name(current)]'s contract with reason: [fail_reason]")
				message_admins("[key_name_admin(usr)] has failed [key_name_admin(current)]'s contract with reason: [fail_reason]")

	else if(href_list["mindslave"])
		switch(href_list["mindslave"])
			if("clear")
				if(has_antag_datum(/datum/antagonist/mindslave))
					var/mob/living/carbon/human/H = current
					for(var/i in H.contents)
						if(istype(i, /obj/item/implant/traitor))
							qdel(i)
							break
					remove_antag_datum(/datum/antagonist/mindslave)
					log_admin("[key_name(usr)] has de-mindslaved [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-mindslaved [key_name_admin(current)]")

	else if(href_list["shadowling"])
		switch(href_list["shadowling"])
			if("clear")
				SSticker.mode.update_shadow_icons_removed(src)
				if(src in SSticker.mode.shadows)
					SSticker.mode.shadows -= src
					special_role = null
					to_chat(current, "<span class='userdanger'>Your powers have been quenched! You are no longer a shadowling!</span>")
					message_admins("[key_name_admin(usr)] has de-shadowlinged [current].")
					log_admin("[key_name(usr)] has de-shadowlinged [current].")
					current.spellremove(current)
					current.remove_language("Shadowling Hivemind")
				else if(src in SSticker.mode.shadowling_thralls)
					SSticker.mode.remove_thrall(src,0)
					message_admins("[key_name_admin(usr)] has de-thrall'ed [current].")
					log_admin("[key_name(usr)] has de-thralled [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-thralled [key_name_admin(current)]")
			if("shadowling")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return
				SSticker.mode.shadows += src
				special_role = SPECIAL_ROLE_SHADOWLING
				to_chat(current, "<span class='shadowling'><b>Something stirs deep in your mind. A red light floods your vision, and slowly you remember. Though your human disguise has served you well, the \
				time is nigh to cast it off and enter your true form. You have disguised yourself amongst the humans, but you are not one of them. You are a shadowling, and you are to ascend at all costs.\
				</b></span>")
				SSticker.mode.finalize_shadowling(src)
				SSticker.mode.update_shadow_icons_added(src)
				log_admin("[key_name(usr)] has shadowlinged [key_name(current)]")
				message_admins("[key_name_admin(usr)] has shadowlinged [key_name_admin(current)]")
			if("thrall")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return
				SSticker.mode.add_thrall(src)
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
				SSticker.mode.update_abductor_icons_added(src)
			if("equip")
				if(!ishuman(current))
					to_chat(usr, "<span class='warning'>This only works on humans!</span>")
					return

				var/mob/living/carbon/human/H = current
				var/gear = alert("Agent or Scientist Gear","Gear","Agent","Scientist")
				if(gear)
					if(gear=="Agent")
						H.equipOutfit(/datum/outfit/abductor/agent)
					else
						H.equipOutfit(/datum/outfit/abductor/scientist)

	else if(href_list["silicon"])
		switch(href_list["silicon"])
			if("unemag")
				var/mob/living/silicon/robot/R = current
				if(istype(R))
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
					R.clear_supplied_laws()
					R.laws = new /datum/ai_laws/crewsimov
					log_admin("[key_name(usr)] has un-emagged [key_name(current)]")
					message_admins("[key_name_admin(usr)] has un-emagged [key_name_admin(current)]")

			if("unemagcyborgs")
				if(isAI(current))
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
						R.clear_supplied_laws()
						R.laws = new /datum/ai_laws/crewsimov
					log_admin("[key_name(usr)] has unemagged [key_name(ai)]'s cyborgs")
					message_admins("[key_name_admin(usr)] has unemagged [key_name_admin(ai)]'s cyborgs")

	else if(href_list["common"])
		switch(href_list["common"])
			if("undress")
				for(var/obj/item/I in current)
					current.unEquip(I, TRUE)
				log_admin("[key_name(usr)] has unequipped [key_name(current)]")
				message_admins("[key_name_admin(usr)] has unequipped [key_name_admin(current)]")
			if("takeuplink")
				take_uplink()
				var/datum/antagonist/traitor/T = has_antag_datum(/datum/antagonist/traitor)
				T.antag_memory = "" //Remove any antag memory they may have had (uplink codes, code phrases)
				log_admin("[key_name(usr)] has taken [key_name(current)]'s uplink")
				message_admins("[key_name_admin(usr)] has taken [key_name_admin(current)]'s uplink")
			if("crystals")
				if(usr.client.holder.rights & (R_SERVER|R_EVENT))
					var/obj/item/uplink/hidden/suplink = find_syndicate_uplink()
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
				if(has_antag_datum(/datum/antagonist/traitor))
					var/datum/antagonist/traitor/T = has_antag_datum(/datum/antagonist/traitor)
					T.give_codewords()
					if(!T.equip_traitor(src))
						to_chat(usr, "<span class='warning'>Equipping a syndicate failed!</span>")
						return
				log_admin("[key_name(usr)] has given [key_name(current)] an uplink")
				message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] an uplink")

	else if(href_list["obj_announce"])
		announce_objectives()
		SEND_SOUND(current, sound('sound/ambience/alarm4.ogg'))
		log_admin("[key_name(usr)] has announced [key_name(current)]'s objectives")
		message_admins("[key_name_admin(usr)] has announced [key_name_admin(current)]'s objectives")

	edit_memory()


// Datum antag mind procs
/datum/mind/proc/add_antag_datum(datum_type_or_instance, team)
	if(!datum_type_or_instance)
		return
	var/datum/antagonist/A
	if(!ispath(datum_type_or_instance))
		A = datum_type_or_instance
		if(!istype(A))
			return
	else
		A = new datum_type_or_instance()
	//Choose snowflake variation if antagonist handles it
	var/datum/antagonist/S = A.specialization(src)
	if(S && S != A)
		qdel(A)
		A = S
	if(!A.can_be_owned(src))
		qdel(A)
		return
	A.owner = src
	LAZYADD(antag_datums, A)
	A.create_team(team)
	var/datum/team/antag_team = A.get_team()
	if(antag_team)
		antag_team.add_member(src)
	A.on_gain()
	return A

/datum/mind/proc/remove_antag_datum(datum_type)
	if(!datum_type)
		return
	var/datum/antagonist/A = has_antag_datum(datum_type)
	if(A)
		A.on_removal()
		return TRUE


/datum/mind/proc/remove_all_antag_datums() //For the Lazy amongst us.
	for(var/a in antag_datums)
		var/datum/antagonist/A = a
		A.on_removal()

/datum/mind/proc/has_antag_datum(datum_type, check_subtypes = TRUE)
	if(!datum_type)
		return
	. = FALSE
	for(var/a in antag_datums)
		var/datum/antagonist/A = a
		if(check_subtypes && istype(A, datum_type))
			return A
		else if(A.type == datum_type)
			return A

/datum/mind/proc/announce_objectives()
	if(current)
		to_chat(current, "<span class='notice'>Your current objectives:</span>")
		for(var/line in splittext(gen_objective_text(), "<br>"))
			to_chat(current, line)

/datum/mind/proc/find_syndicate_uplink()
	var/list/L = current.get_contents()
	for(var/obj/item/I in L)
		if(I.hidden_uplink)
			return I.hidden_uplink
	return null

/datum/mind/proc/take_uplink()
	var/obj/item/uplink/hidden/H = find_syndicate_uplink()
	if(H)
		qdel(H)

/datum/mind/proc/make_Traitor()
	if(!has_antag_datum(/datum/antagonist/traitor))
		add_antag_datum(/datum/antagonist/traitor)

/datum/mind/proc/make_Nuke()
	if(!(src in SSticker.mode.syndicates))
		SSticker.mode.syndicates += src
		SSticker.mode.update_synd_icons_added(src)
		if(SSticker.mode.syndicates.len==1)
			SSticker.mode.prepare_syndicate_leader(src)
		else
			current.real_name = "[syndicate_name()] Operative #[SSticker.mode.syndicates.len-1]"
		special_role = SPECIAL_ROLE_NUKEOPS
		assigned_role = SPECIAL_ROLE_NUKEOPS
		to_chat(current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
		SSticker.mode.forge_syndicate_objectives(src)
		SSticker.mode.greet_syndicate(src)

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
		qdel(H.wear_pda)
		qdel(H.wear_suit)
		qdel(H.w_uniform)

		SSticker.mode.equip_syndicate(current)

/datum/mind/proc/make_Vampire()
	if(!(src in SSticker.mode.vampires))
		SSticker.mode.vampires += src
		SSticker.mode.grant_vampire_powers(current)
		special_role = SPECIAL_ROLE_VAMPIRE
		SSticker.mode.forge_vampire_objectives(src)
		SSticker.mode.greet_vampire(src)
		SSticker.mode.update_vampire_icons_added(src)

/datum/mind/proc/make_Changeling()
	if(!(src in SSticker.mode.changelings))
		SSticker.mode.changelings += src
		SSticker.mode.grant_changeling_powers(current)
		special_role = SPECIAL_ROLE_CHANGELING
		SSticker.mode.forge_changeling_objectives(src)
		SSticker.mode.greet_changeling(src)
		SSticker.mode.update_change_icons_added(src)

/datum/mind/proc/make_Overmind()
	if(!(src in SSticker.mode.blob_overminds))
		SSticker.mode.blob_overminds += src
		special_role = SPECIAL_ROLE_BLOB_OVERMIND

/datum/mind/proc/make_Wizard()
	if(!(src in SSticker.mode.wizards))
		SSticker.mode.wizards += src
		special_role = SPECIAL_ROLE_WIZARD
		assigned_role = SPECIAL_ROLE_WIZARD
		//ticker.mode.learn_basic_spells(current)
		if(!GLOB.wizardstart.len)
			current.loc = pick(GLOB.latejoin)
			to_chat(current, "HOT INSERTION, GO GO GO")
		else
			current.loc = pick(GLOB.wizardstart)

		SSticker.mode.equip_wizard(current)
		for(var/obj/item/spellbook/S in current.contents)
			S.op = 0
		INVOKE_ASYNC(SSticker.mode, /datum/game_mode/wizard.proc/name_wizard, current)
		SSticker.mode.forge_wizard_objectives(src)
		SSticker.mode.greet_wizard(src)
		SSticker.mode.update_wiz_icons_added(src)

/datum/mind/proc/make_Rev()
	if(SSticker.mode.head_revolutionaries.len>0)
		// copy targets
		var/datum/mind/valid_head = locate() in SSticker.mode.head_revolutionaries
		if(valid_head)
			for(var/datum/objective/mutiny/O in valid_head.objectives)
				var/datum/objective/mutiny/rev_obj = new
				rev_obj.owner = src
				rev_obj.target = O.target
				rev_obj.explanation_text = "Assassinate [O.target.current.real_name], the [O.target.assigned_role]."
				objectives += rev_obj
			SSticker.mode.greet_revolutionary(src,0)
	SSticker.mode.head_revolutionaries += src
	SSticker.mode.update_rev_icons_added(src)
	special_role = SPECIAL_ROLE_HEAD_REV

	SSticker.mode.forge_revolutionary_objectives(src)
	SSticker.mode.greet_revolutionary(src,0)

	var/list/L = current.get_contents()
	var/obj/item/flash/flash = locate() in L
	qdel(flash)
	take_uplink()
	var/fail = 0
//	fail |= !ticker.mode.equip_traitor(current, 1)
	fail |= !SSticker.mode.equip_revolutionary(current)

/datum/mind/proc/make_Abductor()
	var/role = alert("Abductor Role ?","Role","Agent","Scientist")
	var/team = input("Abductor Team ?","Team ?") in list(1,2,3,4)
	var/teleport = alert("Teleport to ship ?","Teleport","Yes","No")

	if(!role || !team || !teleport)
		return

	if(!ishuman(current))
		return

	SSticker.mode.abductors |= src

	var/datum/objective/stay_hidden/hidden_obj = new
	hidden_obj.owner = src
	objectives += hidden_obj

	var/datum/objective/experiment/O = new
	O.owner = src
	objectives += O

	var/mob/living/carbon/human/H = current

	H.set_species(/datum/species/abductor)
	var/datum/species/abductor/S = H.dna.species

	if(role == "Scientist")
		S.scientist = TRUE

	S.team = team

	var/list/obj/effect/landmark/abductor/agent_landmarks = new
	var/list/obj/effect/landmark/abductor/scientist_landmarks = new
	agent_landmarks.len = 4
	scientist_landmarks.len = 4
	for(var/obj/effect/landmark/abductor/A in GLOB.landmarks_list)
		if(istype(A, /obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A, /obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

	var/obj/effect/landmark/L
	if(teleport == "Yes")
		switch(role)
			if("Agent")
				L = agent_landmarks[team]
			if("Scientist")
				L = agent_landmarks[team]
		H.forceMove(L.loc)

/datum/mind/proc/AddSpell(obj/effect/proc_holder/spell/S)
	spell_list += S
	S.action.Grant(current)

/datum/mind/proc/RemoveSpell(obj/effect/proc_holder/spell/spell) //To remove a specific spell from a mind
	if(!spell)
		return
	for(var/obj/effect/proc_holder/spell/S in spell_list)
		if(istype(S, spell))
			qdel(S)
			spell_list -= S

/datum/mind/proc/transfer_actions(mob/living/new_character)
	if(current && current.actions)
		for(var/datum/action/A in current.actions)
			A.Grant(new_character)
	transfer_mindbound_actions(new_character)

/datum/mind/proc/transfer_mindbound_actions(mob/living/new_character)
	for(var/X in spell_list)
		var/obj/effect/proc_holder/spell/S = X
		S.action.Grant(new_character)

/datum/mind/proc/get_ghost(even_if_they_cant_reenter)
	for(var/mob/dead/observer/G in GLOB.dead_mob_list)
		if(G.mind == src)
			if(G.can_reenter_corpse || even_if_they_cant_reenter)
				return G
			break

/datum/mind/proc/grab_ghost(force)
	var/mob/dead/observer/G = get_ghost(even_if_they_cant_reenter = force)
	. = G
	if(G)
		G.reenter_corpse()


/datum/mind/proc/make_zealot(mob/living/carbon/human/missionary, convert_duration = 6000, team_color = "red")

	zealot_master = missionary

	var/list/implanters
	if(!(missionary.mind in SSticker.mode.implanter))
		SSticker.mode.implanter[missionary.mind] = list()
	implanters = SSticker.mode.implanter[missionary.mind]
	implanters.Add(src)
	SSticker.mode.implanted.Add(src)
	SSticker.mode.implanted[src] = missionary.mind
	SSticker.mode.implanter[missionary.mind] = implanters
	SSticker.mode.traitors += src


	var/datum/objective/protect/zealot_objective = new
	zealot_objective.target = missionary.mind
	zealot_objective.owner = src
	zealot_objective.explanation_text = "Obey every order from and protect [missionary.real_name], the [missionary.mind.assigned_role == missionary.mind.special_role ? (missionary.mind.special_role) : (missionary.mind.assigned_role)]."
	objectives += zealot_objective
	add_antag_datum(/datum/antagonist/mindslave)

	var/datum/antagonist/traitor/T = missionary.mind.has_antag_datum(/datum/antagonist)
	T.update_traitor_icons_added(missionary.mind)

	to_chat(current, "<span class='warning'><B>You're now a loyal zealot of [missionary.name]!</B> You now must lay down your life to protect [missionary.p_them()] and assist in [missionary.p_their()] goals at any cost.</span>")

	var/datum/mindslaves/slaved = missionary.mind.som
	som = slaved
	slaved.serv += current
	slaved.add_serv_hud(missionary.mind, "master") //handles master servent icons
	slaved.add_serv_hud(src, "mindslave")

	var/obj/item/clothing/under/jumpsuit = null
	if(ishuman(current))		//only bother with the jumpsuit stuff if we are a human type, since we won't have the slot otherwise
		var/mob/living/carbon/human/H = current
		if(H.w_uniform)
			jumpsuit = H.w_uniform
			jumpsuit.color = team_color
			H.update_inv_w_uniform()

	add_attack_logs(missionary, current, "Converted to a zealot for [convert_duration/600] minutes")
	addtimer(CALLBACK(src, .proc/remove_zealot, jumpsuit), convert_duration) //deconverts after the timer expires
	return 1

/datum/mind/proc/remove_zealot(obj/item/clothing/under/jumpsuit = null)
	if(!zealot_master)	//if they aren't a zealot, we can't remove their zealot status, obviously. don't bother with the rest so we don't confuse them with the messages
		return
	remove_antag_datum(/datum/antagonist/mindslave)
	add_attack_logs(zealot_master, current, "Lost control of zealot")
	zealot_master = null

	if(jumpsuit)
		jumpsuit.color = initial(jumpsuit.color)		//reset the jumpsuit no matter where our mind is
		if(ishuman(current))							//but only try updating us if we are still a human type since it is a human proc
			var/mob/living/carbon/human/H = current
			H.update_inv_w_uniform()

	to_chat(current, "<span class='warning'><b>You seem to have forgotten the events of the past 10 minutes or so, and your head aches a bit as if someone beat it savagely with a stick.</b></span>")
	to_chat(current, "<span class='warning'><b>This means you don't remember who you were working for or what you were doing.</b></span>")

//Initialisation procs
/mob/proc/mind_initialize()
	if(mind)
		mind.key = key
	else
		mind = new /datum/mind(key)
		if(SSticker)
			SSticker.minds += mind
		else
			error("mind_initialize(): No ticker ready yet! Please inform Carn")
	if(!mind.name)
		mind.name = real_name
	mind.current = src

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)
		mind.assigned_role = "Civilian"	//defualt

/mob/proc/sync_mind()
	mind_initialize()  //updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1    //indicates that the mind is currently synced with a client

//slime
/mob/living/simple_animal/slime/mind_initialize()
	..()
	mind.assigned_role = "slime"

//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
	mind.assigned_role = "Alien"
	//XENO HUMANOID
/mob/living/carbon/alien/humanoid/queen/mind_initialize()
	..()
	mind.special_role = SPECIAL_ROLE_XENOMORPH_QUEEN

/mob/living/carbon/alien/humanoid/hunter/mind_initialize()
	..()
	mind.special_role = SPECIAL_ROLE_XENOMORPH_HUNTER

/mob/living/carbon/alien/humanoid/drone/mind_initialize()
	..()
	mind.special_role = SPECIAL_ROLE_XENOMORPH_DRONE

/mob/living/carbon/alien/humanoid/sentinel/mind_initialize()
	..()
	mind.special_role = SPECIAL_ROLE_XENOMORPH_SENTINEL
	//XENO LARVA
/mob/living/carbon/alien/larva/mind_initialize()
	..()
	mind.special_role = SPECIAL_ROLE_XENOMORPH_LARVA

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
	mind.special_role = null

//BLOB
/mob/camera/overmind/mind_initialize()
	..()
	mind.special_role = SPECIAL_ROLE_BLOB

//Animals
/mob/living/simple_animal/mind_initialize()
	..()
	mind.assigned_role = "Animal"

/mob/living/simple_animal/pet/dog/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"

/mob/living/simple_animal/shade/mind_initialize()
	..()
	mind.assigned_role = "Shade"

/mob/living/simple_animal/construct/builder/mind_initialize()
	..()
	mind.assigned_role = "Artificer"
	mind.special_role = SPECIAL_ROLE_CULTIST

/mob/living/simple_animal/construct/wraith/mind_initialize()
	..()
	mind.assigned_role = "Wraith"
	mind.special_role = SPECIAL_ROLE_CULTIST

/mob/living/simple_animal/construct/armoured/mind_initialize()
	..()
	mind.assigned_role = "Juggernaut"
	mind.special_role = SPECIAL_ROLE_CULTIST
