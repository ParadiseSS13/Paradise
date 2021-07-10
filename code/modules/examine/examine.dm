/*	This code is responsible for the examine tab.  When someone examines something, it copies the examined object's description_info,
	description_fluff, and description_antag, and shows it in a new tab.

	In this file, some atom and mob stuff is defined here.  It is defined here instead of in the normal files, to keep the whole system self-contained.
	This means that this file can be unchecked, along with the other examine files, and can be removed entirely with no effort.
*/

/atom/proc/detailed_examine()
	return

/atom/proc/detailed_examine_antag()
	return

/atom/proc/detailed_examine_fluff()
	return

/mob/detailed_examine_fluff()
	if(flavor_text) //Get flavor text for the green text.
		return flavor_text
	else //No flavor text?  Try for hardcoded fluff instead.
		return ..()

/mob/living/carbon/human/detailed_examine_fluff()
	return print_flavor_text()

/* The examine panel itself */

/client/proc/update_description_holders(atom/A, update_antag_info = FALSE)
	description_holders["name"] = "[A.name]"
	description_holders["icon"] = "[bicon(A)]"
	description_holders["desc"] = A.desc

	description_holders["info"] = A.detailed_examine()
	description_holders["fluff"] = A.detailed_examine_fluff()
	description_holders["antag"] = update_antag_info ? A.detailed_examine_antag() : null

/client/Stat()
	. = ..()
	if(usr && statpanel("Examine"))
		stat(null, "[description_holders["icon"]]    <font size='5'>[description_holders["name"]]</font>") //The name, written in big letters.
		stat(null, "[description_holders["desc"]]") //the default examine text.
		if(description_holders["info"])
			stat(null, "<font color='#084B8A'><b>[description_holders["info"]]</b></font>") //Blue, informative text.
		if(description_holders["fluff"])
			stat(null, "<font color='#298A08'><b>[description_holders["fluff"]]</b></font>") //Yellow, fluff-related text.
		if(description_holders["antag"])
			stat(null, "<font color='#8A0808'><b>[description_holders["antag"]]</b></font>") //Red, malicious antag-related text
