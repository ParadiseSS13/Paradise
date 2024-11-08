/mob/living/verb/set_default_language(language as null|anything in languages)
	set name = "Set Default Language"
	set category = "IC"

	if(!(language in languages) && !isnull(language))
		to_chat(src, "<span class='warning'>You don't seem to know how to speak [language].</span>")
		return
	if(language)
		to_chat(src, "<span class='notice'>You will now speak [language] if you do not specify a language when speaking.</span>")
	else
		to_chat(src, "<span class='notice'>You will now speak whatever your standard default language is if you do not specify one when speaking.</span>")
	default_language = language

// Silicons can't neccessarily speak everything in their languages list
/mob/living/silicon/set_default_language(language as null|anything in speech_synthesizer_langs)
	set name = "Set Default Language"
	set category = "IC"

	if(!(language in speech_synthesizer_langs) && !isnull(language))
		to_chat(src, "<span class='warning'>You don't seem to know how to speak [language].</span>")
		return
	if(language)
		to_chat(src, "<span class='notice'>You will now speak [language] if you do not specify a language when speaking.</span>")
	else
		to_chat(src, "<span class='notice'>You will now speak whatever your standard default language is if you do not specify one when speaking.</span>")
	default_language = language
