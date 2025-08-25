/datum/game_mode
	var/list/datum/mind/blood_brothers = list()

/datum/antagonist/blood_brother
	name = "Blood Brother"
	roundend_category = "Blood Brothers"
	job_rank = ROLE_BLOOD_BROTHER
	special_role = SPECIAL_ROLE_BLOOD_BROTHER
	antag_hud_name = "hudbloodbrother"
	antag_hud_type = ANTAG_HUD_BLOOD_BROTHER
	clown_gain_text = {"Ты очень много тренировался, чтобы наконец-то вступить в Синдикат, даже твоя клоунская натура не сможет помешать.
Ты уверенно владеешь всем оружием."}
	clown_removal_text = "Все тренировки пошли насмарку - ты как был клоуном, так и остался."
	wiki_page_name = "Blood_Brothers"
	var/datum/team/blood_brothers_team/brothers_team = null

/datum/antagonist/blood_brother/add_owner_to_gamemode()
	SSticker.mode.blood_brothers |= owner

/datum/antagonist/blood_brother/remove_owner_from_gamemode()
	SSticker.mode.blood_brothers -= owner

/datum/antagonist/blood_brother/greet()
	. = ..()
	SEND_SOUND(owner.current, sound('modular_ss220/antagonists/sound/ambience/antag/blood_brothers_intro.ogg'))

	. += trim({"
Вы ненавидите Нанотрейзен, корпорация дала вам достаточно поводов для этого.
Лучшую возможность бороться с ней предоставляет Синдикат, так что вы со своим напарником, разделяющим подобные чувства, связались с ними, чтобы вступить в их ряды.
Теперь вы кровные братья и вы готовы сделать все ради общей цели.
"})

	var/brother_names = get_brother_names_text()
	if(brother_names)
		. += "Оберегай и кооперируйся с братьями: <b>[brother_names]</b>. Ведь только вместе вы сможете добиться успеха!"
		antag_memory += "<b>Ваши братья</b>: [brother_names]<br>"

	var/meeting_area = get_meeting_area()
	if(meeting_area)
		. += "Встреть их в назначенном месте:  <b>[meeting_area]</b>"
		antag_memory += "<b>Место встречи</b>: [meeting_area]<br>"

	. += "Слава Синдикату!"

/datum/antagonist/blood_brother/create_team(datum/team/blood_brothers_team/team)
	if(!istype(team))
		error("Wrong team type passed to [type].")
		return

	brothers_team = team
	return brothers_team

/datum/antagonist/blood_brother/get_team()
	return brothers_team

/datum/antagonist/blood_brother/proc/get_brother_names_text()
	PRIVATE_PROC(TRUE)
	var/datum/team/blood_brothers_team/team = get_team()
	if(!istype(team))
		return ""

	return team.get_brother_names_text(owner)

/datum/antagonist/blood_brother/proc/get_meeting_area()
	PRIVATE_PROC(TRUE)
	var/datum/team/blood_brothers_team/team = get_team()
	if(!istype(team))
		return ""

	return team.meeting_area

/datum/antagonist/blood_brother/proc/admin_add(admin, datum/mind/new_antag)
	if(!new_antag)
		return FALSE

	if(new_antag.has_antag_datum(/datum/antagonist/blood_brother))
		alert(admin, "Candidate is already blood brother")
		return FALSE

	if(!can_be_owned(new_antag))
		alert(admin, "Candidate can't be blood brother.")
		return FALSE

	switch(alert(admin, "Create new team or add to existing?", "Blood Brothers", "Create", "Add", "Cancel"))
		if("Create")
			return create_new_blood_brothers_team(admin, new_antag)
		if("Add")
			return add_to_existing_blood_brothers_team(admin, new_antag)

	return FALSE

/datum/antagonist/blood_brother/proc/create_new_blood_brothers_team(admin, datum/mind/first_brother)
	PRIVATE_PROC(TRUE)
	var/list/choices = list()
	for(var/mob/living/alive_living_mob in GLOB.alive_mob_list)
		var/datum/mind/mind_to_check = alive_living_mob.mind
		if(!mind_to_check || mind_to_check == first_brother || !can_be_owned(mind_to_check))
			continue

		choices["[mind_to_check.name]([alive_living_mob.ckey])"] = mind_to_check

	if(!length(choices))
		alert(admin, "No candidates for second blood brother found.")
		return FALSE

	var/choice = tgui_input_list(admin, "Choose the blood brother.", "Brother", sortTim(choices, GLOBAL_PROC_REF(cmp_text_asc)))
	if(!choice)
		return FALSE

	var/datum/mind/second_brother = choices[choice]
	if(!second_brother)
		stack_trace("Chosen second blood brother `[choice]` was `null` for some reason")

	var/datum/team/blood_brothers_team/brother_team = new(list(first_brother, second_brother), FALSE)
	if(isnull(first_brother.add_antag_datum(src, brother_team)))
		qdel(brother_team)
		return FALSE

	if(isnull(second_brother.add_antag_datum(/datum/antagonist/blood_brother, brother_team)))
		error("Antag datum couldn't be granted to second brother in `/datum/antagonist/blood_brother/proc/create_new_blood_brothers_team`")
		alert(admin, "Second brother wasn't made into `Blood Brother` for some reason. Try again.")
		return TRUE

	log_admin("[key_name(admin)] made [key_name(first_brother)] and [key_name(second_brother)] into blood brothers.")
	return TRUE

/datum/antagonist/blood_brother/proc/add_to_existing_blood_brothers_team(admin, datum/mind/brother_to_add)
	PRIVATE_PROC(TRUE)
	var/list/choices = list()
	for(var/datum/team/blood_brothers_team/team in GLOB.antagonist_teams)
		var/list/member_ckeys = team.get_member_ckeys()
		choices["[team.name][length(member_ckeys) ? "([member_ckeys.Join(", ")])" : ""]"] = team

	if(!length(choices))
		alert(admin, "No blood brother teams found. Try creating new one.")
		return FALSE

	sortTim(choices, GLOBAL_PROC_REF(cmp_text_asc))
	var/choice = tgui_input_list(admin, "Choose the blood brothers team.", "Blood Brothers Team", choices)
	if(!choice)
		return FALSE

	var/datum/team/blood_brothers_team/chosen_team = choices[choice]
	if(!chosen_team)
		stack_trace("Chosen blood brothers team `[choice]` was `null` for some reason.")


	return !isnull(brother_to_add.add_antag_datum(src, chosen_team))
