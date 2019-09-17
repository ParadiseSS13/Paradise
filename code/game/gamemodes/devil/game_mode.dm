/datum/game_mode
	var/list/datum/mind/sintouched = list()
	var/list/datum/mind/devils = list()
	var/devil_ascended = 0 // Number of arch devils on station

/datum/game_mode/proc/auto_declare_completion_sintouched()
	var/text = ""
	if(sintouched.len)
		text += "<br><span class='big'><b>The sintouched were:</b></span>"
		var/list/sintouchedUnique = uniqueList(sintouched)
		for(var/S in sintouchedUnique)
			var/datum/mind/sintouched_mind = S
			text += printplayer(sintouched_mind)
			text += printobjectives(sintouched_mind)
			text += "<br>"
		text += "<br>"
	to_chat(world,text)

/datum/game_mode/proc/auto_declare_completion_devils()
	/var/text = ""
	if(devils.len)
		text += "<br><span class='big'><b>The devils were:</b></span>"
		for(var/D in devils)
			var/datum/mind/devil = D
			text += printplayer(devil)
			text += printdevilinfo(devil)
			text += printobjectives(devil)
			text += "<br>"
		text += "<br>"
	to_chat(world,text)


/datum/game_mode/proc/finalize_devil(datum/mind/devil_mind, ascendable = FALSE)
	var/trueName= randomDevilName()
	devil_mind.devilinfo = devilInfo(trueName, 1)
	devil_mind.devilinfo.ascendable = ascendable
	devil_mind.store_memory("Your diabolical true name is [devil_mind.devilinfo.truename]<br>[lawlorify[LAW][devil_mind.devilinfo.ban]]<br>You may not use violence to coerce someone into selling their soul.<br>You may not directly and knowingly physically harm a devil, other than yourself.<br>[lawlorify[LAW][devil_mind.devilinfo.bane]]<br>[lawlorify[LAW][devil_mind.devilinfo.obligation]]<br>[lawlorify[LAW][devil_mind.devilinfo.banish]]<br>")
	devil_mind.devilinfo.link_with_mob(devil_mind.current)
	if(devil_mind.assigned_role == "Clown")
		to_chat(devil_mind.current, "Your infernal nature allows you to wield weapons without harming yourself.")
		devil_mind.current.mutations.Remove(CLUMSY)
		var/datum/action/innate/toggle_clumsy/A = new
		A.Grant(devil_mind.current)
	spawn(10)
		devil_mind.devilinfo.update_hud()
	if(issilicon(devil_mind.current))
		var/mob/living/silicon/S = devil_mind.current
		S.laws.set_sixsixsix_law("You may not use violence to coerce someone into selling their soul.")
		S.laws.set_sixsixsix_law("You may not directly and knowingly physically harm a devil, other than yourself.")
		S.laws.set_sixsixsix_law("[lawlorify[LAW][devil_mind.devilinfo.ban]]")
		S.laws.set_sixsixsix_law("[lawlorify[LAW][devil_mind.devilinfo.obligation]]")
		S.laws.set_sixsixsix_law("Accomplish your objectives at all costs.")

// unsure about the second "quantity" arg and how it fits with the antag refactor
/datum/game_mode/proc/forge_devil_objectives(datum/mind/devil_mind, quantity)
	var/list/validtypes = list(/datum/objective/devil/soulquantity, /datum/objective/devil/soulquality, /datum/objective/devil/sintouch, /datum/objective/devil/buy_target)
	for(var/i = 1 to quantity)
		var/type = pick(validtypes)
		var/datum/objective/devil/objective = new type(null)
		objective.owner = devil_mind
		devil_mind.objectives += objective
		if(!istype(objective, /datum/objective/devil/buy_target))
			validtypes -= type //prevent duplicate objectives, EXCEPT for buy_target.
		else
			objective.find_target()

/datum/game_mode/proc/greet_devil(datum/mind/devil_mind)
	if(!devil_mind.devilinfo)
		return
	devil_mind.devilinfo.announce_laws(devil_mind.current)
	devil_mind.announce_objectives()


/datum/game_mode/proc/printdevilinfo(datum/mind/ply)
	if(!ply.devilinfo)
		return "Target is not a devil."
	var/text = "</br>The devil's true name is: [ply.devilinfo.truename]</br>"
	text += "The devil's bans were:</br>"
	text += "	[lawlorify[LORE][ply.devilinfo.ban]]</br>"
	text += "	[lawlorify[LORE][ply.devilinfo.bane]]</br>"
	text += "	[lawlorify[LORE][ply.devilinfo.obligation]]</br>"
	text += "	[lawlorify[LORE][ply.devilinfo.banish]]</br></br>"
	return text

/datum/game_mode/proc/update_devil_icons_added(datum/mind/devil_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_DEVIL]
	hud.join_hud(devil_mind.current)
	set_antag_hud(devil_mind.current, "huddevil")

/datum/game_mode/proc/update_devil_icons_removed(datum/mind/devil_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_DEVIL]
	hud.leave_hud(devil_mind.current)
	set_antag_hud(devil_mind.current, null)
