
/datum/antagonist/abductor
	name = "Abductor"
	roundend_category = "abductors"
	job_rank = ROLE_ABDUCTOR
	special_role = SPECIAL_ROLE_ABDUCTOR_AGENT
	give_objectives = FALSE
	antag_hud_name = "abductor"
	antag_hud_type = ANTAG_HUD_ABDUCTOR
	clown_gain_text = "How are you a clown and an abductor? This is a bug!"
	clown_removal_text = "How are you a clown and an abductor? This is a bug!"
	wiki_page_name = "Abductor"
	var/datum/team/abductor/our_team

/datum/antagonist/abductor/on_gain()
	. = ..()
	owner.assigned_role = special_role
	owner.offstation_role = TRUE
	SEND_SOUND(owner.current, sound('sound/ambience/antag/abductors.ogg'))

/datum/antagonist/abductor/greet()
	var/list/messages = list()
	messages.Add("<span class='userdanger'>You are an agent of [our_team.name]!</span>")
	messages.Add("<span class='boldnotice'>With the help of your teammate, kidnap and experiment on station crew members! Use your stealth technology and equipment to incapacitate humanoids for your scientist to retrieve.</span>")
	return messages

/datum/antagonist/abductor/add_owner_to_gamemode()
	SSticker.mode.abductors |= owner

/datum/antagonist/abductor/remove_owner_from_gamemode()
	SSticker.mode.abductors -= owner

/datum/antagonist/abductor/get_team()
	return our_team

/datum/antagonist/abductor/proc/equip_abductor()
	var/mob/living/carbon/human/agent = owner.current
	agent.equipOutfit(/datum/outfit/abductor/agent)

/datum/antagonist/abductor/scientist
	special_role = SPECIAL_ROLE_ABDUCTOR_SCIENTIST

/datum/antagonist/abductor/scientist/equip_abductor()
	var/mob/living/carbon/human/scientist = owner.current
	scientist.equipOutfit(/datum/outfit/abductor/scientist)

/datum/antagonist/abductor/scientist/greet()
	var/list/messages = list()
	messages.Add("<span class='userdanger'>You are a scientist of [our_team.name]!</span>")
	messages.Add("<span class='boldnotice'>With the help of your teammate, kidnap and experiment on station crew members! Use your tool and ship consoles to support the agent and retrieve humanoid specimens.</span>")
	return messages
