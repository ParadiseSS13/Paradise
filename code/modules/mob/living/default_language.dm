/mob/living/verb/set_default_language()
	set name = "Set Default Language"
	set category = "IC"
	var/language = tgui_input_list(src, "Your current default language is: [default_language]", "Set your default language", languages)
	if(language)
		to_chat(src, "<span class='notice'>You will now speak [language] if you do not specify a language when speaking.</span>")
	else
		to_chat(src, "<span class='notice'>You will now speak whatever your standard default language is if you do not specify one when speaking.</span>")
	default_language = language

// Silicons can't neccessarily speak everything in their languages list
/mob/living/silicon/set_default_language()
	set name = "Set Default Language"
	set category = "IC"
	var/language = tgui_input_list(src, "Your current default language is: [default_language]", "Set your default language", speech_synthesizer_langs)
	if(language)
		to_chat(src, "<span class='notice'>You will now speak [language] if you do not specify a language when speaking.</span>")
	else
		to_chat(src, "<span class='notice'>You will now speak whatever your standard default language is if you do not specify one when speaking.</span>")
	default_language = language
