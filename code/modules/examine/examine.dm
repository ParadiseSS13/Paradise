/**
 * Used for showing a more detailed description in the 'Examine' tab after examining the atom.
 *
 * Shown as blue text in the Examine tab.
 */
/atom/proc/detailed_examine()
	return null

/**
 * Used for showing a more detailed description to antags in the 'Examine' after examining the atom.
 *
 * Shown as red text in the Examine tab.
 */
/atom/proc/detailed_examine_antag()
	return null

/**
 * Used for showing flavour text in the 'Examine' tab after examining the atom.
 *
 * Shown as green text in the Examine tab. The custom flavour text of `/mob` subtypes override this.
 */
/atom/proc/detailed_examine_fluff()
	return null

/mob/detailed_examine_fluff()
	if(flavor_text) //Get flavor text for the green text.
		return flavor_text
	else //No flavor text? Try for hardcoded fluff instead.
		return ..()

/mob/living/carbon/human/detailed_examine_fluff()
	return print_flavor_text()


/client/proc/update_description_holders(atom/A, update_antag_info = FALSE)
	description_holders["name"] = "[A.name]"
	description_holders["desc"] = A.desc

	description_holders["info"] = A.detailed_examine()
	description_holders["fluff"] = A.detailed_examine_fluff()
	description_holders["antag"] = update_antag_info ? A.detailed_examine_antag() : null

// The examine panel itself
/client/Stat()
	. = ..()
	if(usr && statpanel("Examine"))
		stat(null, "<font size='5'>[description_holders["name"]]</font>") //The name, written in big letters.
		stat(null, "[description_holders["desc"]]") //the default examine text.
		if(description_holders["info"])
			stat(null, "<font color='#084B8A'><b>[description_holders["info"]]</b></font>") //Blue, informative text.
		if(description_holders["fluff"])
			stat(null, "<font color='#298A08'><b>[description_holders["fluff"]]</b></font>") //Yellow, fluff-related text.
		if(description_holders["antag"])
			stat(null, "<font color='#8A0808'><b>[description_holders["antag"]]</b></font>") //Red, malicious antag-related text
