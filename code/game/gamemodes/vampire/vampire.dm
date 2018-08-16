//This is the gamemode file for the ported goon gamemode vampires.
//They get a traitor objective and a blood sucking objective
/datum/game_mode
	var/list/datum/mind/vampires = list()
	var/list/datum/mind/vampire_enthralled = list() //those controlled by a vampire
	var/list/vampire_thralls = list() //vammpires controlling somebody

/datum/game_mode/vampire
	name = "vampire"
	config_tag = "vampire"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Chaplain", "Brig Physician", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer")
	protected_species = list("Machine")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4

	var/vampire_amount = 4

/datum/game_mode/vampire/announce()
	to_chat(world, "<B>The current game mode is - Vampires!</B>")
	to_chat(world, "<B>There are Vampires from Space Transylvania on the station, keep your blood close and neck safe!</B>")

/datum/game_mode/vampire/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)

	vampire_amount = 1 + round(num_players() / 10)

	if(possible_vampires.len>0)
		for(var/i = 0, i < vampire_amount, i++)
			if(!possible_vampires.len) break
			var/datum/mind/vampire = pick(possible_vampires)
			possible_vampires -= vampire
			vampires += vampire
			vampire.restricted_roles = restricted_jobs
			modePlayer += vampires
			var/datum/mindslaves/slaved = new()
			slaved.masters += vampire
			vampire.som = slaved //we MIGT want to mindslave someone
			vampire.special_role = SPECIAL_ROLE_VAMPIRE
		..()
		return 1
	else
		return 0

/datum/game_mode/vampire/post_setup()
	for(var/datum/mind/vampire in vampires)
		add_vampire(vampire)
	..()

/datum/game_mode/proc/auto_declare_completion_vampire()
	if(vampires.len)
		var/text = "<FONT size = 2><B>The vampires were:</B></FONT>"
		for(var/datum/mind/vampire in vampires)

			if(!is_vampire(vampire))
				continue

			text += printplayer(vampire)
			text += printobjectives(vampire)
		text += "<br>"
		to_chat(world, text)
	return 1

/datum/game_mode/proc/auto_declare_completion_enthralled()
	if(vampire_enthralled.len)
		var/text = "<FONT size = 2><B>The Enthralled were:</B></FONT>"
		for(var/datum/mind/Mind in vampire_enthralled)
			text += printplayer(Mind)
		text += "<br>"
		to_chat(world, text)
	return 1


/proc/add_vampire(mob/living/L)
	if(!L || !L.mind)
		return FALSE
	var/datum/antagonist/vampire/vamp = L.mind.add_antag_datum(/datum/antagonist/vampire)
	return vamp

/proc/remove_vampire(mob/living/L)
	if(!L || !L.mind)
		return FALSE
	var/datum/antagonist/vamp = L.mind.has_antag_datum(/datum/antagonist/vampire)
	vamp.on_removal()
	return TRUE

/proc/is_vampire(mob/living/M)
	return M && M.mind && M.mind.has_antag_datum(/datum/antagonist/vampire)


//prepare for copypaste
/datum/game_mode/proc/update_vampire_icons_added(datum/mind/vampire_mind)
	var/datum/atom_hud/antag/vamp_hud = huds[ANTAG_HUD_VAMPIRE]
	vamp_hud.join_hud(vampire_mind.current)
	set_antag_hud(vampire_mind.current, ((vampire_mind in vampires) ? "hudvampire" : "hudvampirethrall"))

/datum/game_mode/proc/update_vampire_icons_removed(datum/mind/vampire_mind)
	var/datum/atom_hud/antag/vampire_hud = huds[ANTAG_HUD_VAMPIRE]
	vampire_hud.leave_hud(vampire_mind.current)
	set_antag_hud(vampire_mind.current, null)

/datum/game_mode/proc/remove_vampire_mind(datum/mind/vampire_mind, datum/mind/head)
	//var/list/removal
	if(!istype(head))
		head = vampire_mind //workaround for removing a thrall's control over the enthralled
	var/ref = "\ref[head]"
	if(ref in vampire_thralls)
		vampire_thralls[ref] -= vampire_mind
	vampire_enthralled -= vampire_mind
	vampire_mind.special_role = null
	var/datum/mindslaves/slaved = vampire_mind.som
	slaved.serv -= vampire_mind
	vampire_mind.som = null
	slaved.leave_serv_hud(vampire_mind)
	update_vampire_icons_removed(vampire_mind)
	vampire_mind.current.visible_message("<span class='userdanger'>[vampire_mind.current] looks as though a burden has been lifted!</span>", "<span class='userdanger'>The dark fog in your mind clears as you regain control of your own faculties, you are no longer a vampire thrall!</span>")
	if(vampire_mind.current.hud_used)
		vampire_mind.current.hud_used.remove_vampire_hud()


/datum/hud/proc/remove_vampire_hud()
	if(!vampire_blood_display)
		return

	static_inventory -= vampire_blood_display
	QDEL_NULL(vampire_blood_display)
	show_hud(hud_version)
