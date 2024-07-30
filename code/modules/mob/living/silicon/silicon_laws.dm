#define BASE_LAW_TYPE /datum/ai_laws/nanotrasen

/mob/living/silicon/proc/laws_sanity_check()
	if(!src.laws)
		laws = new BASE_LAW_TYPE

/mob/living/silicon/proc/has_zeroth_law()
	return laws.zeroth_law != null

/mob/living/silicon/proc/set_zeroth_law(law, law_borg)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.set_zeroth_law(law, law_borg)
	if(!isnull(usr) && law)
		log_and_message_admins("has given [src] the zeroth laws: [law]/[law_borg ? law_borg : "N/A"]")

/mob/living/silicon/proc/add_ion_law(law)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.add_ion_law(law)
	if(!isnull(usr) && law)
		log_and_message_admins("has given [src] the ion law: [law]")

/mob/living/silicon/proc/add_inherent_law(law)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.add_inherent_law(law)
	if(!isnull(usr) && law)
		log_and_message_admins("has given [src] the inherent law: [law]")

/mob/living/silicon/proc/add_supplied_law(number, law)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.add_supplied_law(number, law)
	if(!isnull(usr) && law)
		log_and_message_admins("has given [src] the supplied law: [law]")

/mob/living/silicon/proc/delete_law(datum/ai_law/law)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.delete_law(law)
	if(!isnull(usr) && law)
		log_and_message_admins("has deleted a law belonging to [src]: [law.law]")

/mob/living/silicon/proc/clear_inherent_laws(silent = 0)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.clear_inherent_laws()
	if(!silent && !isnull(usr))
		log_and_message_admins("cleared the inherent laws of [src]")

/mob/living/silicon/proc/clear_ion_laws(silent = 0)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.clear_ion_laws()
	if(!silent && !isnull(usr))
		log_and_message_admins("cleared the ion laws of [src]")

/mob/living/silicon/proc/clear_supplied_laws(silent = 0)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.clear_supplied_laws()
	if(!silent && !isnull(usr))
		log_and_message_admins("cleared the supplied laws of [src]")

/mob/living/silicon/proc/clear_zeroth_law(silent = FALSE)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.clear_zeroth_laws()
	if(!silent && !isnull(usr))
		log_and_message_admins("cleared the zeroth law of [src]")

/mob/living/silicon/proc/statelaws(datum/ai_laws/laws)
	var/prefix = ""
	if(MAIN_CHANNEL == lawchannel)
		prefix = ";"
	else if(lawchannel in additional_law_channels)
		prefix = additional_law_channels[lawchannel]
	else
		prefix = get_radio_key_from_channel(lawchannel)

	dostatelaws(lawchannel, prefix, laws)

/mob/living/silicon/proc/dostatelaws(method, prefix, datum/ai_laws/laws)
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

/mob/living/silicon/proc/statelaw(law)
	if(src.say(law))
		sleep(10)
		return 1

	return 0

/mob/living/silicon/proc/law_channels()
	var/list/channels = list()
	channels += MAIN_CHANNEL
	var/obj/item/radio/radio = get_radio()
	channels += radio.channels
	channels += additional_law_channels
	return channels

/mob/living/silicon/proc/lawsync()
	laws_sanity_check()
	laws.sort_laws()

/mob/living/silicon/proc/make_laws()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI))
		laws = pick_unique_lawset()
	else if(GLOB.configuration.general.random_ai_lawset)
		laws = get_random_lawset()
	else
		laws = new /datum/ai_laws/crewsimov()

/mob/living/silicon/proc/get_random_lawset()
	var/list/law_options[0]
	var/paths = subtypesof(/datum/ai_laws)
	for(var/law in paths)
		var/datum/ai_laws/L = new law
		if(!L.default)
			continue
		law_options += L
	return pick(law_options)

///returns a random non starting / kill crew lawset if the station has a unique ai lawset
/proc/pick_unique_lawset()
	var/list/law_options = list()
	var/paths = subtypesof(/datum/ai_laws)
	for(var/law in paths)
		var/datum/ai_laws/L = new law
		if(!L.unique_ai)
			continue
		law_options += L
	return pick(law_options)
#undef BASE_LAW_TYPE
