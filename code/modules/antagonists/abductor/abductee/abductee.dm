/**
 * ## Abductees
 *
 * Abductees are created by being operated on by abductors. They get some instructions about not
 * remembering the abduction, plus some random weird objectives for them to act crazy with.
 */
/datum/antagonist/abductee
	name = "\improper Abductee"
	roundend_category = "abductees"
	antag_hud_name = "abductee"

/datum/antagonist/abductee/on_gain()
	give_objective()
	. = ..()

/datum/antagonist/abductee/greet()
    to_chat(owner, "<span class='warning'><b>Your mind snaps!</b></span>")
    to_chat(owner, "<big><span class='warning'><b>You can't remember how you got here...</b></span></big>")
    owner.announce_objectives()

/datum/antagonist/abductee/proc/give_objective()
	var/objtype = pick(subtypesof(/datum/objective/abductee/))
	var/datum/objective/abductee/O = new objtype()
	objectives += O
