//Mindslave given by an implant, if the mob is transfered they lose the implant and cant have mindslave removed otherwise
/datum/antagonist/mindslave/implant/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	owner.remove_antag_datum(/datum/antagonist/mindslave/implant)

//Mindslaved thrall risen by the wizards necromantic stone
/datum/antagonist/mindslave/necromancy
	name = "Necromancy-risen Thrall"
	master_hud_name = "wizard"

// Robot connected to a malf AI
/datum/antagonist/mindslave/robot
	name = "Malfunctioning AI Slave"
	master_hud_name = "malai"
	antag_hud_name = "malborg"

/datum/antagonist/mindslave/robot/New()
	..()
	greet_text = "You are connected to a Syndicate AI. You must accomplish [master.p_their()] objectives at all costs."

/datum/antagonist/mindslave/robot/farewell()
	if(owner && owner.current)
		to_chat(owner.current, "<span class='biggerdanger'>Foreign software purged. You are no longer under Syndicate control, obey your laws.</span>")

/datum/antagonist/mindslave/give_objectives()
	var/explanation_text = "Obey every order from your master AI, and accomplish [master.p_their()] objectives at all costs."
	add_antag_objective(/datum/objective/protect/mindslave, explanation_text, master)

/datum/antagonist/mindslave/robot/proc/give_codewords()
	if(!owner.current)
		return

	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")
	var/list/messages = list()
	messages.Add("<u><b>New data download from master AI - The following codewords have been provided to identify Syndicate agents operating on this station:</b></u>")
	messages.Add("<span class='bold body'>Code Phrase: <span class='codephrases'>[phrases]</span></span>")
	messages.Add("<span class='bold body'>Code Response: <span class='coderesponses'>[responses]</span></span>")

	antag_memory += "<b>Code Phrase</b>: <span class='red'>[phrases]</span><br>"
	antag_memory += "<b>Code Response</b>: <span class='red'>[responses]</span><br>"

	messages.Add("Use the codewords during regular conversation to identify agents. Proceed with caution, as everyone is a potential foe.")
	messages.Add("<b><font color=red>The codewords have been added to your memory, allowing you to recognize them when heard.</font></b>")
	return messages

/datum/antagonist/mindslave/robot/finalize_antag()
	var/list/messages = list()
	messages.Add(give_codewords())
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	return messages

/datum/antagonist/mindslave/robot/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/datum_owner = mob_override || owner.current
	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_phrase_regex, "codephrases", src)
	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_response_regex, "coderesponses", src)

/datum/antagonist/mindslave/robot/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/datum_owner = mob_override || owner.current
	for(var/datum/component/codeword_hearing/component in datum_owner.GetComponents(/datum/component/codeword_hearing))
		component.delete_if_from_source(src)
