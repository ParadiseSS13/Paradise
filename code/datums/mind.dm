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
	var/special_role //special roles are typically reserved for antags or roles like ERT. If you want to avoid a character being automatically announced by the AI, on arrival (becuase they're an off station character or something); ensure that special_role and assigned_role are equal.
	var/offstation_role = FALSE //set to true for ERT, deathsquad, abductors, etc, that can go from and to z2 at will and shouldn't be antag targets
	var/list/restricted_roles = list()

	var/list/spell_list = list() // Wizard mode & "Give Spell" badmin button.

	var/role_alt_title

	var/datum/job/assigned_job
	var/list/kills = list()
	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	var/miming = 0 // Mime's vow of silence
	var/list/antag_datums
	var/speech_span // What span any body this mind has talks in.
	var/datum/faction/faction 			//associated faction
	var/datum/changeling/changeling		//changeling holder
	var/linglink
	var/datum/vampire/vampire			//vampire holder
	var/datum/nations/nation			//nation holder
	var/datum/abductor/abductor			//abductor holder
	var/datum/devilinfo/devilinfo 		//devil holder

	var/antag_hud_icon_state = null //this mind's ANTAG_HUD should have this icon_state
	var/datum/atom_hud/antag/antag_hud = null //this mind's antag HUD
	var/datum/mindslaves/som //stands for slave or master...hush..
	var/datum/devilinfo/devilinfo //Information about the devil, if any.
 	var/damnation_type = 0
 	var/datum/mind/soulOwner //who owns the soul.  Under normal circumstances, this will point to src
	var/hasSoul = TRUE

	var/rev_cooldown = 0

	var/isholy = FALSE // is this person a chaplain or admin role allowed to use bibles
	var/isblessed = FALSE // is this person blessed by a chaplain?
	var/num_blessed = 0 // for prayers

	// the world.time since the mob has been brigged, or -1 if not at all
	var/brigged_since = -1
	var/suicided = FALSE

	//put this here for easier tracking ingame
	var/datum/money_account/initial_account

	//zealot_master is a reference to the mob that converted them into a zealot (for ease of investigation and such)
	var/mob/living/carbon/human/zealot_master = null

/datum/mind/New(new_key)
	key = new_key
	soulOwner = src

/datum/mind/Destroy()
	ticker.minds -= src
	if(islist(antag_datums))
		for(var/i in antag_datums)
			var/datum/antagonist/antag_datum = i
			if(antag_datum.delete_on_mind_deletion)
				qdel(i)
		antag_datums = null
	return ..()

/datum/mind/proc/transfer_to(mob/living/new_character)
	var/datum/atom_hud/antag/hud_to_transfer = antag_hud //we need this because leave_hud() will clear this list
	var/mob/living/old_current = current
	if(!istype(new_character))
		log_runtime(EXCEPTION("transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob."), src)
	if(current)					//remove ourself from our old body's mind variable
		current.mind = null
		leave_all_huds() //leave all the huds in the old body, so it won't get huds if somebody else enters it

		SSnanoui.user_transferred(current, new_character)

	if(new_character.mind)		//remove any mind currently in our new body's mind variable
		new_character.mind.current = null
	current = new_character		//link ourself to our new body
	new_character.mind = src	//and link our new body to ourself
	for(var/a in antag_datums)	//Makes sure all antag datums effects are applied in the new body
		var/datum/antagonist/A = a
		A.on_body_transfer(old_current, current)
	transfer_antag_huds(hud_to_transfer)				//inherit the antag HUD
	transfer_actions(new_character)

	if(active)
		new_character.key = key		//now transfer the key to link the client to our new body

/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<BR>"

/datum/mind/proc/wipe_memory()
	memory = null

/datum/mind/proc/show_memory(mob/recipient, window = 1)
	if(!recipient)
		recipient = current
	var/output = "<B>[current.real_name]'s Memories:</B><HR>"
	output += memory

	if(objectives.len)
		output += "<HR><B>Objectives:</B><BR>"
		output += gen_objective_text()

	if(job_objectives.len)
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
	for(var/datum/objective/objective in objectives)
		. += "<b>Objective #[obj_count]</b>: [objective.explanation_text]"
		if(admin)
			. += " <a href='?src=[UID()];obj_edit=\ref[objective]'>Edit</a> " // Edit
			. += "<a href='?src=[UID()];obj_delete=\ref[objective]'>Delete</a> " // Delete

			. += "<a href='?src=[UID()];obj_completed=\ref[objective]'>" // Mark Completed
			. += "<font color=[objective.completed ? "green" : "red"]>Toggle Completion</font>"
			. += "</a>"
		. += "<br>"
		obj_count++

/datum/mind/proc/_memory_edit_header(gamemode, list/alt)
	. = gamemode
	if(ticker.mode.config_tag == gamemode || (LAZYLEN(alt) && (ticker.mode.config_tag in alt)))
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
	else if(src in ticker.mode.head_revolutionaries)
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
	else if(src in ticker.mode.revolutionaries)
		. += "<a href='?src=[UID()];revolution=clear'>no</a>|<a href='?src=[UID()];revolution=headrev'>headrev</a>|<b><font color='red'>REV</font></b>"
	else
		. += "<b>NO</b>|<a href='?src=[UID()];revolution=headrev'>headrev</a>|<a href='?src=[UID()];revolution=rev'>rev</a>"

	. += _memory_edit_role_enabled(ROLE_REV)

/datum/mind/proc/memory_edit_cult(mob/living/carbon/human/H)
	. = _memory_edit_header("cult")
	if(ismindshielded(H))
		. += "<B>NO</B>|cultist"
	else if(src in ticker.mode.cult)
		. += "<a href='?src=[UID()];cult=clear'>no</a>|<b><font color='red'>CULTIST</font></b>"
		. += "<br>Give <a href='?src=[UID()];cult=tome'>tome</a>|<a href='?src=[UID()];cult=equip'>equip</a>."
	else
		. += "<b>NO</b>|<a href='?src=[UID()];cult=cultist'>cultist</a>"

	. += _memory_edit_role_enabled(ROLE_CULTIST)

/datum/mind/proc/memory_edit_wizard(mob/living/carbon/human/H)
	. = _memory_edit_header("wizard")
	if(src in ticker.mode.wizards)
		. += "<b><font color='red'>WIZARD</font></b>|<a href='?src=[UID()];wizard=clear'>no</a>"
		. += "<br><a href='?src=[UID()];wizard=lair'>To lair</a>, <a href='?src=[UID()];common=undress'>undress</a>, <a href='?src=[UID()];wizard=dressup'>dress up</a>, <a href='?src=[UID()];wizard=name'>let choose name</a>."
		if(objectives.len==0)
			. += "<br>Objectives are empty! <a href='?src=[UID()];wizard=autoobjectives'>Randomize!</a>"
	else
		. += "<a href='?src=[UID()];wizard=wizard'>wizard</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_WIZARD)

/datum/mind/proc/memory_edit_changeling(mob/living/carbon/human/H)
	. = _memory_edit_header("changeling", list("traitorchan"))
	if(src in ticker.mode.changelings)
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
	if(src in ticker.mode.vampires)
		. += "<b><font color='red'>VAMPIRE</font></b>|<a href='?src=[UID()];vampire=clear'>no</a>"
		if(objectives.len==0)
			. += "<br>Objectives are empty! <a href='?src=[UID()];vampire=autoobjectives'>Randomize!</a>"
	else
		. += "<a href='?src=[UID()];vampire=vampire'>vampire</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_VAMPIRE)
	/** Enthralled ***/
	. += "<br><b><i>enthralled</i></b>: "
	if(src in ticker.mode.vampire_enthralled)
		. += "<b><font color='red'>THRALL</font></b>|<a href='?src=[UID()];vampthrall=clear'>no</a>"
	else
		. += "thrall|<b>NO</b>"

/datum/mind/proc/memory_edit_nuclear(mob/living/carbon/human/H)
	. = _memory_edit_header("nuclear")
	if(src in ticker.mode.syndicates)
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
	if(src in ticker.mode.shadows)
		. += "<b><font color='red'>SHADOWLING</font></b>|thrall|<a href='?src=[UID()];shadowling=clear'>no</a>"
	else if(src in ticker.mode.shadowling_thralls)
		. += "Shadowling|<b><font color='red'>THRALL</font></b>|<a href='?src=[UID()];shadowling=clear'>no</a>"
	else
		. += "<a href='?src=[UID()];shadowling=shadowling'>shadowling</a>|<a href='?src=[UID()];shadowling=thrall'>thrall</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_SHADOWLING)

/datum/mind/proc/memory_edit_abductor(mob/living/carbon/human/H)
	. = _memory_edit_header("abductor")
	if(src in ticker.mode.abductors)
		. += "<b><font color='red'>ABDUCTOR</font></b>|<a href='?src=[UID()];abductor=clear'>no</a>"
		. += "|<a href='?src=[UID()];common=undress'>undress</a>|<a href='?src=[UID()];abductor=equip'>equip</a>"
	else
		. += "<a href='?src=[UID()];abductor=abductor'>abductor</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_ABDUCTOR)

/datum/mind/proc/memory_edit_devil(mob/living/H)
	. = _memory_edit_header("devil", list("devilagents"))
	if(src in ticker.mode.devils)
		if(!devilinfo)
			. += "<b>No devilinfo found! Yell at a coder!</b>"
		else if(!devilinfo.ascendable)
			. += "<b>DEVIL</b>|<a href='?src=[UID()];devil=ascendable_devil'>Ascendable Devil</a>|sintouched|<a href='?src=[UID()];devil=clear'>no</a>"
		else
			. += "<a href='?src=[UID()];devil=devil'>DEVIL</a>|<b>ASCENDABLE DEVIL</b>|sintouched|<a href='?src=[UID()];devil=clear'>no</a>"
	else if(src in ticker.mode.sintouched)
		. += "devil|Ascendable Devil|<b>SINTOUCHED</b>|<a href='?src=[UID()];devil=clear'>no</a>"
	else
		. += "<a href='?src=[UID()];devil=devil'>devil</a>|<a href='?src=[UID()];devil=ascendable_devil'>Ascendable Devil</a>|<a href='?src=[UID()];devil=sintouched'>sintouched</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_DEVIL)

/datum/mind/proc/memory_edit_eventmisc(mob/living/H)
	. = _memory_edit_header("event", list())
	if(src in ticker.mode.eventmiscs)
		. += "<b>YES</b>|<a href='?src=[UID()];eventmisc=clear'>no</a>"
	else
		. += "<a href='?src=[UID()];eventmisc=eventmisc'>Event Role</a>|<b>NO</b>"

/datum/mind/proc/memory_edit_traitor()
	. = _memory_edit_header("traitor", list("traitorchan", "traitorvamp"))
	if(src in ticker.mode.traitors)
		. += "<b><font color='red'>TRAITOR</font></b>|<a href='?src=[UID()];traitor=clear'>no</a>"
		if(objectives.len==0)
			. += "<br>Objectives are empty! <a href='?src=[UID()];traitor=autoobjectives'>Randomize</a>!"
	else
		. += "<a href='?src=[UID()];traitor=traitor'>traitor</a>|<b>NO</b>"

	. += _memory_edit_role_enabled(ROLE_TRAITOR)

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
	if(ishuman(current) && ((src in ticker.mode.head_revolutionaries) || \
		(src in ticker.mode.traitors) || \
		(src in ticker.mode.syndicates)))
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
	if(!ticker || !ticker.mode)
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
		/** CULT ***/
		sections["cult"] = memory_edit_cult(H)
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
	/** DEVIL ***/
	var/static/list/devils_typecache = typecacheof(list(/mob/living/carbon/human, /mob/living/carbon/true_devil, /mob/living/silicon/robot))
	if(is_type_in_typecache(current, devils_typecache))
		sections["devil"] = memory_edit_devil(H)
	sections["eventmisc"] = memory_edit_eventmisc(H)
	/** TRAITOR ***/
	sections["traitor"] = memory_edit_traitor()
	/** SILICON ***/
	if(issilicon(current))
		sections["silicon"] = memory_edit_silicon()
	/*
		This prioritizes antags relevant to the current round to make them appear at the top of the panel.
		Traitorchan and traitorvamp are snowflaked in because they have multiple sections.
	*/
	if(ticker.mode.config_tag == "traitorchan")
		if(sections["traitor"])
			out += sections["traitor"] + "<br>"
		if(sections["changeling"])
			out += sections["changeling"] + "<br>"
		sections -= "traitor"
		sections -= "changeling"
	// Elif technically unnecessary but it makes the following else look better
	else if(ticker.mode.config_tag == "traitorvamp")
		if(sections["traitor"])
			out += sections["traitor"] + "<br>"
		if(sections["vampire"])
			out += sections["vampire"] + "<br>"
		sections -= "traitor"
		sections -= "vampire"
	else
		if(sections[ticker.mode.config_tag])
			out += sections[ticker.mode.config_tag] + "<br>"
		sections -= ticker.mode.config_tag

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
				for(var/datum/mind/possible_target in ticker.minds)
					if((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
						possible_targets += possible_target.current

				var/mob/def_target = null
				var/objective_list[] = list(/datum/objective/assassinate, /datum/objective/protect, /datum/objective/debrain)
				if(objective&&(objective.type in objective_list) && objective:target)
					def_target = objective:target.current
				possible_targets = sortAtom(possible_targets)
				possible_targets += "Free objective"

				var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
				if(!new_target)
					return

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
				for(var/datum/mind/possible_target in ticker.minds)
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
				if(src in ticker.mode.revolutionaries)
					special_role = null
					ticker.mode.revolutionaries -= src
					to_chat(src, "<span class='warning'><Font size = 3><B>The nanobots in the mindshield implant remove all thoughts about being a revolutionary.  Get back to work!</B></Font></span>")
				if(src in ticker.mode.head_revolutionaries)
					special_role = null
					ticker.mode.head_revolutionaries -=src
					to_chat(src, "<span class='warning'><Font size = 3><B>The nanobots in the mindshield implant remove all thoughts about being a revolutionary.  Get back to work!</B></Font></span>")
				if(src in ticker.mode.cult)
					ticker.mode.cult -= src
					ticker.mode.update_cult_icons_removed(src)
					special_role = null
					var/datum/game_mode/cult/cult = ticker.mode
					if(istype(cult))
						cult.memorize_cult_objectives(src)
					to_chat(current, "<span class='warning'><FONT size = 3><B>The nanobots in the mindshield implant remove all thoughts about being in a cult.  Have a productive day!</B></FONT></span>")
					memory = ""

	else if(href_list["revolution"])

		switch(href_list["revolution"])
			if("clear")
				if(src in ticker.mode.revolutionaries)
					ticker.mode.revolutionaries -= src
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a revolutionary!</B></FONT></span>")
					ticker.mode.update_rev_icons_removed(src)
					special_role = null
				if(src in ticker.mode.head_revolutionaries)
					ticker.mode.head_revolutionaries -= src
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a head revolutionary!</B></FONT></span>")
					ticker.mode.update_rev_icons_removed(src)
					special_role = null
				log_admin("[key_name(usr)] has de-rev'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has de-rev'd [key_name_admin(current)]")

			if("rev")
				if(src in ticker.mode.head_revolutionaries)
					ticker.mode.head_revolutionaries -= src
					ticker.mode.update_rev_icons_removed(src)
					to_chat(current, "<span class='warning'><FONT size = 3><B>Revolution has been disappointed of your leadership traits! You are a regular revolutionary now!</B></FONT></span>")
				else if(!(src in ticker.mode.revolutionaries))
					to_chat(current, "<span class='warning'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>")
				else
					return
				ticker.mode.revolutionaries += src
				ticker.mode.update_rev_icons_added(src)
				special_role = SPECIAL_ROLE_REV
				log_admin("[key_name(usr)] has rev'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has rev'd [key_name_admin(current)]")

			if("headrev")
				if(src in ticker.mode.revolutionaries)
					ticker.mode.revolutionaries -= src
					ticker.mode.update_rev_icons_removed(src)
					to_chat(current, "<span class='userdanger'>You have proven your devotion to revolution! You are a head revolutionary now!</span>")
				else if(!(src in ticker.mode.head_revolutionaries))
					to_chat(current, "<span class='notice'>You are a member of the revolutionaries' leadership now!</span>")
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
				special_role = SPECIAL_ROLE_HEAD_REV
				log_admin("[key_name(usr)] has head-rev'd [key_name(current)]")
				message_admins("[key_name_admin(usr)] has head-rev'd [key_name_admin(current)]")

			if("autoobjectives")
				ticker.mode.forge_revolutionary_objectives(src)
				ticker.mode.greet_revolutionary(src,0)
				log_admin("[key_name(usr)] has automatically forged revolutionary objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged revolutionary objectives for [key_name_admin(current)]")

			if("flash")
				if(!ticker.mode.equip_revolutionary(current))
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
				fail |= !ticker.mode.equip_traitor(current, 1)
				fail |= !ticker.mode.equip_revolutionary(current)
				if(fail)
					to_chat(usr, "<span class='warning'>Reequipping revolutionary goes wrong!</span>")
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
					special_role = SPECIAL_ROLE_CULTIST
					to_chat(current, "<span class='cultitalic'>You catch a glimpse of the Realm of [ticker.cultdat.entity_name], [ticker.cultdat.entity_title3]. You now see how flimsy the world is, you see that it should be open to the knowledge of [ticker.cultdat.entity_name].</span>")
					to_chat(current, "<span class='cultitalic'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve [ticker.cultdat.entity_title2] above all else. Bring It back.</span>")
					log_admin("[key_name(usr)] has culted [key_name(current)]")
					message_admins("[key_name_admin(usr)] has culted [key_name_admin(current)]")
			if("tome")
				var/mob/living/carbon/human/H = current
				if(istype(H))
					var/obj/item/tome/T = new(H)

					var/list/slots = list (
						"backpack" = slot_in_backpack,
						"left pocket" = slot_l_store,
						"right pocket" = slot_r_store,
						"left hand" = slot_l_hand,
						"right hand" = slot_r_hand,
					)
					var/where = H.equip_in_one_of_slots(T, slots)
					if(!where)
						to_chat(usr, "<span class='warning'>Spawning tome failed!</span>")
						qdel(T)
					else
						to_chat(H, "A tome, a message from your new master, appears in your [where].")
						log_admin("[key_name(usr)] has spawned a tome for [key_name(current)]")
						message_admins("[key_name_admin(usr)] has spawned a tome for [key_name_admin(current)]")

			if("equip")
				if(!ticker.mode.equip_cultist(current))
					to_chat(usr, "<span class='warning'>Spawning equipment failed!</span>")
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
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a wizard!</B></FONT></span>")
					log_admin("[key_name(usr)] has de-wizarded [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-wizarded [key_name_admin(current)]")
			if("wizard")
				if(!(src in ticker.mode.wizards))
					ticker.mode.wizards += src
					special_role = SPECIAL_ROLE_WIZARD
					//ticker.mode.learn_basic_spells(current)
					ticker.mode.update_wiz_icons_added(src)
					to_chat(current, "<span class='danger'>You are a Space Wizard!</span>")
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
				to_chat(usr, "<span class='notice'>The objectives for wizard [key] have been generated. You can edit them and announce manually.</span>")
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
					special_role = SPECIAL_ROLE_CHANGELING
					to_chat(current, "<B><font color='red'>Your powers have awoken. A flash of memory returns to us... we are a changeling!</font></B>")
					log_admin("[key_name(usr)] has changelinged [key_name(current)]")
					message_admins("[key_name_admin(usr)] has changelinged [key_name_admin(current)]")

			if("autoobjectives")
				ticker.mode.forge_changeling_objectives(src)
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
					som = slaved //we MIGT want to mindslave someone
					special_role = SPECIAL_ROLE_VAMPIRE
					to_chat(current, "<B><font color='red'>Your powers have awoken. Your lust for blood grows... You are a Vampire!</font></B>")
					log_admin("[key_name(usr)] has vampired [key_name(current)]")
					message_admins("[key_name_admin(usr)] has vampired [key_name_admin(current)]")

			if("autoobjectives")
				ticker.mode.forge_vampire_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for vampire [key] have been generated. You can edit them and announce manually.</span>")
				log_admin("[key_name(usr)] has automatically forged objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged objectives for [key_name_admin(current)]")

	else if(href_list["vampthrall"])
		switch(href_list["vampthrall"])
			if("clear")
				if(src in ticker.mode.vampire_enthralled)
					ticker.mode.remove_vampire_mind(src)
					log_admin("[key_name(usr)] has de-vampthralled [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-vampthralled [key_name_admin(current)]")

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
						qdel(O)
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a syndicate operative!</B></FONT></span>")
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
					special_role = SPECIAL_ROLE_NUKEOPS
					to_chat(current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
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
				qdel(H.wear_pda)
				qdel(H.wear_suit)
				qdel(H.w_uniform)

				if(!ticker.mode.equip_syndicate(current))
					to_chat(usr, "<span class='warning'>Equipping a syndicate failed!</span>")
					return
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
				if(src in ticker.mode.eventmiscs)
					ticker.mode.eventmiscs -= src
					ticker.mode.update_eventmisc_icons_removed(src)
					special_role = null
					message_admins("[key_name_admin(usr)] has de-eventantag'ed [current].")
					log_admin("[key_name(usr)] has de-eventantag'ed [current].")
			if("eventmisc")
				ticker.mode.eventmiscs += src
				special_role = SPECIAL_ROLE_EVENTMISC
				ticker.mode.update_eventmisc_icons_added(src)
				message_admins("[key_name_admin(usr)] has eventantag'ed [current].")
				log_admin("[key_name(usr)] has eventantag'ed [current].")
	else if(href_list["devil"])
		switch(href_list["devil"])
			if("clear")
				if(src in ticker.mode.devils)
					if(istype(current,/mob/living/carbon/true_devil/))
						to_chat(usr,"<span class='warning'>This cannot be used on true or arch-devils.</span>")
					else
						ticker.mode.devils -= src
						ticker.mode.update_devil_icons_removed(src)
						special_role = null
						to_chat(current,"<span class='userdanger'>Your infernal link has been severed! You are no longer a devil!</span>")
						RemoveSpell(/obj/effect/proc_holder/spell/targeted/infernal_jaunt)
						RemoveSpell(/obj/effect/proc_holder/spell/fireball/hellish)
						RemoveSpell(/obj/effect/proc_holder/spell/targeted/summon_contract)
						RemoveSpell(/obj/effect/proc_holder/spell/targeted/conjure_item/pitchfork)
						RemoveSpell(/obj/effect/proc_holder/spell/targeted/conjure_item/pitchfork/greater)
						RemoveSpell(/obj/effect/proc_holder/spell/targeted/conjure_item/pitchfork/ascended)
						RemoveSpell(/obj/effect/proc_holder/spell/targeted/conjure_item/violin)
						RemoveSpell(/obj/effect/proc_holder/spell/targeted/summon_dancefloor)
						RemoveSpell(/obj/effect/proc_holder/spell/targeted/sintouch)
						RemoveSpell(/obj/effect/proc_holder/spell/targeted/sintouch/ascended)
						message_admins("[key_name_admin(usr)] has de-devil'ed [current].")
						if(issilicon(current))
							var/mob/living/silicon/S = current
							S.laws.clear_sixsixsix_laws()
						devilinfo = null
						log_admin("[key_name(usr)] has de-devil'ed [current].")
				else if(src in ticker.mode.sintouched)
					ticker.mode.sintouched -= src
					message_admins("[key_name_admin(usr)] has de-sintouch'ed [current].")
					log_admin("[key_name(usr)] has de-sintouch'ed [current].")
			if("devil")
				if(devilinfo)
					devilinfo.ascendable = FALSE
					message_admins("[key_name_admin(usr)] has made [current] unable to ascend as a devil.")
					log_admin("[key_name_admin(usr)] has made [current] unable to ascend as a devil.")
					return
				if(!ishuman(current) && !isrobot(current))
					to_chat(usr, "<span class='warning'>This only works on humans and cyborgs!</span>")
					return
				ticker.mode.devils += src
				special_role = "devil"
				ticker.mode.update_devil_icons_added(src)
				ticker.mode.finalize_devil(src, FALSE)
				ticker.mode.forge_devil_objectives(src, 2)
				ticker.mode.greet_devil(src)
				message_admins("[key_name_admin(usr)] has devil'ed [current].")
				log_admin("[key_name(usr)] has devil'ed [current].")
			if("ascendable_devil")
				if(devilinfo)
					devilinfo.ascendable = TRUE
					message_admins("[key_name_admin(usr)] has made [current] able to ascend as a devil.")
					log_admin("[key_name_admin(usr)] has made [current] able to ascend as a devil.")
					return
				if(!ishuman(current) && !isrobot(current))
					to_chat(usr, "<span class='warning'>This only works on humans and cyborgs!</span>")
					return
				ticker.mode.devils += src
				special_role = "devil"
				ticker.mode.update_devil_icons_added(src)
				ticker.mode.finalize_devil(src, TRUE)
				ticker.mode.forge_devil_objectives(src, 2)
				ticker.mode.greet_devil(src)
				message_admins("[key_name_admin(usr)] has devil'ed [current].  The devil has been marked as ascendable.")
				log_admin("[key_name(usr)] has devil'ed [current]. The devil has been marked as ascendable.")
			if("sintouched")
				var/mob/living/carbon/human/H = current
				H.influenceSin()
				message_admins("[key_name_admin(usr)] has sintouch'ed [current].")
				log_admin("[key_name(usr)] has sintouch'ed [current].")

	else if(href_list["traitor"])
		switch(href_list["traitor"])
			if("clear")
				if(src in ticker.mode.traitors)
					ticker.mode.traitors -= src
					special_role = null
					to_chat(current, "<span class='warning'><FONT size = 3><B>You have been brainwashed! You are no longer a traitor!</B></FONT></span>")
					log_admin("[key_name(usr)] has de-traitored [key_name(current)]")
					message_admins("[key_name_admin(usr)] has de-traitored [key_name_admin(current)]")
					if(isAI(current))
						var/mob/living/silicon/ai/A = current
						A.set_zeroth_law("")
						A.show_laws()
						A.verbs -= /mob/living/silicon/ai/proc/choose_modules
						A.malf_picker.remove_verbs(A)
						qdel(A.malf_picker)
					ticker.mode.update_traitor_icons_removed(src)


			if("traitor")
				if(!(src in ticker.mode.traitors))
					ticker.mode.traitors += src
					var/datum/mindslaves/slaved = new()
					slaved.masters += src
					som = slaved //we MIGT want to mindslave someone
					special_role = SPECIAL_ROLE_TRAITOR
					to_chat(current, "<span class='danger'>You are a traitor!</span>")
					log_admin("[key_name(usr)] has traitored [key_name(current)]")
					message_admins("[key_name_admin(usr)] has traitored [key_name_admin(current)]")
					if(isAI(current))
						var/mob/living/silicon/ai/A = current
						ticker.mode.add_law_zero(A)
					ticker.mode.update_traitor_icons_added(src)

			if("autoobjectives")
				ticker.mode.forge_traitor_objectives(src)
				to_chat(usr, "<span class='notice'>The objectives for traitor [key] have been generated. You can edit them and announce manually.</span>")
				log_admin("[key_name(usr)] has automatically forged objectives for [key_name(current)]")
				message_admins("[key_name_admin(usr)] has automatically forged objectives for [key_name_admin(current)]")

	else if(href_list["shadowling"])
		switch(href_list["shadowling"])
			if("clear")
				ticker.mode.update_shadow_icons_removed(src)
				if(src in ticker.mode.shadows)
					ticker.mode.shadows -= src
					special_role = null
					to_chat(current, "<span class='userdanger'>Your powers have been quenched! You are no longer a shadowling!</span>")
					message_admins("[key_name_admin(usr)] has de-shadowlinged [current].")
					log_admin("[key_name(usr)] has de-shadowlinged [current].")
					current.spellremove(current)
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
				special_role = SPECIAL_ROLE_SHADOWLING
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
					log_admin("[key_name(usr)] has unemagged [key_name(ai)]'s cyborgs")
					message_admins("[key_name_admin(usr)] has unemagged [key_name_admin(ai)]'s cyborgs")

	else if(href_list["common"])
		switch(href_list["common"])
			if("undress")
				if(ishuman(current))
					var/mob/living/carbon/human/H = current
					// Don't "undress" organs right out of the body
					for(var/obj/item/W in H.contents - (H.bodyparts | H.internal_organs))
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
				if(!ticker.mode.equip_traitor(current, !(src in ticker.mode.traitors)))
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
	if(!(src in ticker.mode.traitors))
		ticker.mode.traitors += src
		special_role = SPECIAL_ROLE_TRAITOR
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
		special_role = SPECIAL_ROLE_NUKEOPS
		assigned_role = SPECIAL_ROLE_NUKEOPS
		to_chat(current, "<span class='notice'>You are a [syndicate_name()] agent!</span>")
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
		qdel(H.wear_pda)
		qdel(H.wear_suit)
		qdel(H.w_uniform)

		ticker.mode.equip_syndicate(current)

/datum/mind/proc/make_Vampire()
	if(!(src in ticker.mode.vampires))
		ticker.mode.vampires += src
		ticker.mode.grant_vampire_powers(current)
		special_role = SPECIAL_ROLE_VAMPIRE
		ticker.mode.forge_vampire_objectives(src)
		ticker.mode.greet_vampire(src)
		ticker.mode.update_vampire_icons_added(src)

/datum/mind/proc/make_Changeling()
	if(!(src in ticker.mode.changelings))
		ticker.mode.changelings += src
		ticker.mode.grant_changeling_powers(current)
		special_role = SPECIAL_ROLE_CHANGELING
		ticker.mode.forge_changeling_objectives(src)
		ticker.mode.greet_changeling(src)
		ticker.mode.update_change_icons_added(src)

/datum/mind/proc/make_Wizard()
	if(!(src in ticker.mode.wizards))
		ticker.mode.wizards += src
		special_role = SPECIAL_ROLE_WIZARD
		assigned_role = SPECIAL_ROLE_WIZARD
		//ticker.mode.learn_basic_spells(current)
		if(!wizardstart.len)
			current.loc = pick(latejoin)
			to_chat(current, "HOT INSERTION, GO GO GO")
		else
			current.loc = pick(wizardstart)

		ticker.mode.equip_wizard(current)
		for(var/obj/item/spellbook/S in current.contents)
			S.op = 0
		ticker.mode.name_wizard(current)
		ticker.mode.forge_wizard_objectives(src)
		ticker.mode.greet_wizard(src)
		ticker.mode.update_wiz_icons_added(src)

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
	special_role = SPECIAL_ROLE_HEAD_REV

	ticker.mode.forge_revolutionary_objectives(src)
	ticker.mode.greet_revolutionary(src,0)

	var/list/L = current.get_contents()
	var/obj/item/flash/flash = locate() in L
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

/datum/mind/proc/disrupt_spells(delay, list/exceptions = New())
	for(var/X in spell_list)
		var/obj/effect/proc_holder/spell/S = X
		for(var/type in exceptions)
			if(istype(S, type))
				continue
		S.charge_counter = delay
		spawn(0)
			S.start_recharge()
		S.updateButtonIcon()

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
	if(!missionary || !istype(missionary))		//better provide a proper missionary or the rest of this is gonna break
		return 0

	zealot_master = missionary

	var/list/implanters
	var/ref = "\ref[missionary.mind]"
	if(!(missionary.mind in ticker.mode.implanter))
		ticker.mode.implanter[ref] = list()
	implanters = ticker.mode.implanter[ref]
	implanters.Add(src)
	ticker.mode.implanted.Add(src)
	ticker.mode.implanted[src] = missionary.mind
	//ticker.mode.implanter[missionary.mind] += src
	ticker.mode.implanter[ref] = implanters
	ticker.mode.traitors += src
	special_role = "traitor"
	to_chat(current, "<span class='warning'><B>You're now a loyal zealot of [missionary.name]!</B> You now must lay down your life to protect [missionary.p_them()] and assist in [missionary.p_their()] goals at any cost.</span>")
	var/datum/objective/protect/mindslave/MS = new
	MS.owner = src
	MS.target = missionary.mind
	MS.explanation_text = "Obey every order from and protect [missionary.real_name], the [missionary.mind.assigned_role == missionary.mind.special_role ? (missionary.mind.special_role) : (missionary.mind.assigned_role)]."
	objectives += MS
	for(var/datum/objective/objective in objectives)
		to_chat(current, "<B>Objective #1</B>: [objective.explanation_text]")

	ticker.mode.update_traitor_icons_added(missionary.mind)
	ticker.mode.update_traitor_icons_added(src)//handles datahuds/observerhuds

	if(missionary.mind.som)//do not add if not a traitor..and you just picked up a robe and staff in the hall...
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
			H.update_inv_w_uniform(0,0)

	add_attack_logs(missionary, current, "Converted to a zealot for [convert_duration/600] minutes")
	addtimer(CALLBACK(src, .proc/remove_zealot, jumpsuit), convert_duration) //deconverts after the timer expires
	return 1

/datum/mind/proc/remove_zealot(obj/item/clothing/under/jumpsuit = null)
	if(!zealot_master)	//if they aren't a zealot, we can't remove their zealot status, obviously. don't bother with the rest so we don't confuse them with the messages
		return
	ticker.mode.remove_traitor_mind(src)
	add_attack_logs(zealot_master, current, "Lost control of zealot")
	zealot_master = null

	if(jumpsuit)
		jumpsuit.color = initial(jumpsuit.color)		//reset the jumpsuit no matter where our mind is
		if(ishuman(current))							//but only try updating us if we are still a human type since it is a human proc
			var/mob/living/carbon/human/H = current
			H.update_inv_w_uniform(0,0)

	to_chat(current, "<span class='warning'>You seem to have forgotten the events of the past 10 minutes or so, and your head aches a bit as if someone beat it savagely with a stick.</span>")
	to_chat(current, "<span class='warning'>This means you don't remember who you were working for or what you were doing.</span>")

/datum/mind/proc/is_revivable() //Note, this ONLY checks the mind.
	if(damnation_type)
		return FALSE
	return TRUE

// returns a mob to message to produce something visible for the target mind
/datum/mind/proc/messageable_mob()
	if(!QDELETED(current) && current.client)
		return current
	else
		return get_ghost(even_if_they_cant_reenter = TRUE)

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

/mob/living/simple_animal/pet/corgi/mind_initialize()
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