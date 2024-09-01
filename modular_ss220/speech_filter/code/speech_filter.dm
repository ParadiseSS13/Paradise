#define BRAINROT_FILTER_FILE "config/speech_filters/brainrot_filter.json"

/datum/element/speech_filter
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/static/list/brainrot_notifications = list(
		"Почему у меня такой скудный словарный запас? Стоит сходить в библиотеку и прочесть книгу...",
		"Что, черт побери, я несу?",
		"Я в своём уме? Надо следить за языком.",
		"Неужели я не могу подобрать нужных слов? Позор мне..."
	)

/datum/element/speech_filter/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/mob_to_censor = target
	if(!mob_to_censor.client)
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(mob_to_censor, COMSIG_MOB_SAY, PROC_REF(filter_speech), TRUE)
	RegisterSignal(mob_to_censor, COMSIG_MOB_LOGOUT, PROC_REF(Detach), TRUE)

/datum/element/speech_filter/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_MOB_SAY)
	UnregisterSignal(source, COMSIG_MOB_LOGOUT)

/datum/element/speech_filter/proc/filter_speech(mob/talker, list/speech_args)
	if(!GLOB.configuration.ss220_misc.enable_speech_filter || can_bypass_filter(talker))
		return

	var/message = speech_args[SPEECH_MESSAGE]
	if(!length(message))
		return

	if(message[1] == "*")
		return

	var/brainrot_regex = get_brainrot_filter_regex()
	if(!brainrot_regex)
		return

	var/original_message = copytext(message, 1)
	message = rustutils_regex_replace(message, brainrot_regex, "i", "цветочек")
	if(original_message == message)
		return

	speech_args[SPEECH_MESSAGE] = message
	addtimer(CALLBACK(talker, TYPE_PROC_REF(/mob, emote), "drool"), 0.3 SECONDS)
	to_chat(talker, span_sinister(pick(brainrot_notifications)))
	log_and_message_admins("[key_name(talker)] has attempted to say forbidden word. His message was: [original_message]")

/datum/element/speech_filter/proc/get_brainrot_filter_regex()
	if(!fexists(BRAINROT_FILTER_FILE))
		return

	var/static/list/filters = json_load(BRAINROT_FILTER_FILE)["brainrot_filter"]
	if(!length(filters))
		return list()

	var/static/brainrot_regex
	if(!brainrot_regex)
		var/list/unique_filters = list()
		unique_filters |= filters
		brainrot_regex = unique_filters.Join("|")

	return brainrot_regex

/datum/element/speech_filter/proc/can_bypass_filter(mob/mob_to_check)
	return mob_to_check.client.ckey in GLOB.configuration.ss220_misc.speech_filter_bypass

#undef BRAINROT_FILTER_FILE
