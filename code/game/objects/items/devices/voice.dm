/obj/item/voice_changer
	name = "voice changer"
	desc = "A voice scrambling module."
	icon = 'icons/obj/device.dmi'
	icon_state = "voice_changer_off"

	actions_types = list(/datum/action/item_action/voice_changer/toggle, /datum/action/item_action/voice_changer/voice)

	var/obj/item/parent
	//Флаг для Ниндзя и других подобных случаев, когда мы применяем войс ченджер, но не даём кнопок его контролировать на прямую
	var/inform_about_toggle = TRUE

	var/voice
	var/tts_voice
	var/active

/obj/item/voice_changer/New()
	. = ..()

	if(isitem(loc))
		parent = loc
		parent.actions |= actions

/obj/item/voice_changer/Destroy()
	if(isitem(parent))
		parent.actions -= actions

	return ..()

/obj/item/voice_changer/attack_self(mob/user)
	active = !active
	icon_state = "voice_changer_[active ? "on" : "off"]"
	if(inform_about_toggle)
		to_chat(user, span_notice("You toggle [src] [active ? "on" : "off"]."))

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/voice_changer/proc/set_voice(mob/user)
	var/mimic_voice
	var/mimic_voice_tts

	var/mimic_option = alert(user, "What voice do you want to mimic?", "Set Voice Changer", "Real Voice", "Custom Voice", "Cancel")
	switch(mimic_option)
		if("Real Voice")
			var/mob/living/carbon/human/human = input(user, "Select a voice to copy from.", "Set Voice Changer") in GLOB.human_list
			mimic_voice = human.real_name
			mimic_voice_tts = human.dna.tts_seed_dna
		if("Custom Voice")
			mimic_voice = reject_bad_name(stripped_input(user, "Enter a name to mimic.", "Set Voice Changer", null, MAX_NAME_LEN), TRUE)
			if(!mimic_voice)
				to_chat(user, span_warning("Invalid name, try again."))
				return
			mimic_voice_tts = user.select_voice(user, override = TRUE)
		if("Cancel")
			return

	voice = mimic_voice
	tts_voice = mimic_voice_tts
	if(inform_about_toggle)
		to_chat(user, span_notice("You are now mimicking <b>[voice]</b>."))

//Войс ченджер является частью способности хамелиона и должен быть недосягаем без неё, хоть и хранится в маске
/obj/item/voice_changer/ninja
	name = "ninja voice changer"
	desc = "A voice scrambling module."
	actions_types = list()
	inform_about_toggle = FALSE

/obj/item/voice_changer/ninja/set_voice(mob/user, chosen_voice)
	if(!chosen_voice)
		voice = null
		tts_voice = null
		if(inform_about_toggle)
			to_chat(user, span_notice("You are now mimicking the voice on your ID card."))
		return
	voice = chosen_voice
	tts_voice = null
	for(var/mob/living/carbon/human/target in GLOB.human_list)
		if(target.name == chosen_voice)
			tts_voice = target.dna.tts_seed_dna
			return
