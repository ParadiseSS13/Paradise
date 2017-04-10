/mob/living/silicon
	var/datum/ai_laws/laws = null
	var/list/additional_law_channels = list("State" = "")

/mob/living/silicon/proc/laws_sanity_check()
	if(!src.laws)
		laws = new base_law_type

/mob/living/silicon/proc/has_zeroth_law()
	return laws.zeroth_law != null

/mob/living/silicon/proc/set_zeroth_law(var/law, var/law_borg)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.set_zeroth_law(law, law_borg)
	if(!isnull(usr) && law)
		log_and_message_admins("has given [src] the zeroth laws: [law]/[law_borg ? law_borg : "N/A"]")

/mob/living/silicon/robot/set_zeroth_law(var/law, var/law_borg)
	..()
	if(tracking_entities)
		to_chat(src, "<span class='warning'>Internal camera is currently being accessed.</span>")

/mob/living/silicon/proc/add_ion_law(var/law)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.add_ion_law(law)
	if(!isnull(usr) && law)
		log_and_message_admins("has given [src] the ion law: [law]")

/mob/living/silicon/proc/add_inherent_law(var/law)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.add_inherent_law(law)
	if(!isnull(usr) && law)
		log_and_message_admins("has given [src] the inherent law: [law]")

/mob/living/silicon/proc/add_supplied_law(var/number, var/law)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.add_supplied_law(number, law)
	if(!isnull(usr) && law)
		log_and_message_admins("has given [src] the supplied law: [law]")

/mob/living/silicon/proc/delete_law(var/datum/ai_law/law)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.delete_law(law)
	if(!isnull(usr) && law)
		log_and_message_admins("has deleted a law belonging to [src]: [law.law]")

/mob/living/silicon/proc/clear_inherent_laws(var/silent = 0)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.clear_inherent_laws()
	if(!silent && !isnull(usr))
		log_and_message_admins("cleared the inherent laws of [src]")

/mob/living/silicon/proc/clear_ion_laws(var/silent = 0)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.clear_ion_laws()
	if(!silent && !isnull(usr))
		log_and_message_admins("cleared the ion laws of [src]")

/mob/living/silicon/proc/clear_supplied_laws(var/silent = 0)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.clear_supplied_laws()
	if(!silent && !isnull(usr))
		log_and_message_admins("cleared the supplied laws of [src]")

/mob/living/silicon/proc/statelaws(var/datum/ai_laws/laws)
	var/prefix = ""
	if(MAIN_CHANNEL == lawchannel)
		prefix = ";"
	else if(lawchannel in additional_law_channels)
		prefix = additional_law_channels[lawchannel]
	else
		prefix = get_radio_key_from_channel(lawchannel)

	dostatelaws(lawchannel, prefix, laws)

/mob/living/silicon/proc/dostatelaws(var/method, var/prefix, var/datum/ai_laws/laws)
	if(stating_laws[prefix])
		to_chat(src, "<span class='notice'>[method]: Already stating laws using this communication method.</span>")
		return

	stating_laws[prefix] = 1

	var/can_state = statelaw("[prefix]Current Active Laws:")

	for(var/datum/ai_law/law in laws.laws_to_state())
		can_state = statelaw("[prefix][law.get_index()]. [law.law]")
		if(!can_state)
			break

	if(!can_state)
		to_chat(src, "<span class='danger'>[method]: Unable to state laws. Communication method unavailable.</span>")
	stating_laws[prefix] = 0

/mob/living/silicon/proc/statelaw(var/law)
	if(src.say(law))
		sleep(10)
		return 1

	return 0

/mob/living/silicon/proc/law_channels()
	var/list/channels = new()
	channels += MAIN_CHANNEL
	channels += common_radio.channels
	channels += additional_law_channels
	return channels

/mob/living/silicon/proc/lawsync()
	laws_sanity_check()
	laws.sort_laws()

/mob/living/silicon/proc/make_laws()
	switch(config.default_laws)
		if(0)
			laws = new /datum/ai_laws/crewsimov()
		else
			laws = get_random_lawset()

/mob/living/silicon/proc/get_random_lawset()
	var/list/law_options[0]
	var/paths = subtypesof(/datum/ai_laws)
	for(var/law in paths)
		var/datum/ai_laws/L = new law
		if(!L.default)
			continue
		law_options += L
	return pick(law_options)
