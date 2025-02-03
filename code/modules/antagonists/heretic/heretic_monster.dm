///Tracking reasons
/datum/antagonist/heretic_monster
	name = "\improper Eldritch Horror"
	roundend_category = "Heretics"
	job_rank = ROLE_HERETIC
	antag_hud_type = ANTAG_HUD_HERETIC_BEAST
	antag_hud_name = "heretic_beast"
	/// Our master (a heretic)'s mind.
	var/datum/mind/master

/datum/antagonist/heretic_monster/farewell()
	if(master?.current)
		to_chat(master.current, "<span class='warning'>The essence of [owner], your servant, fades from your mind.</span>")
	if(owner.current)
		to_chat(owner.current, "<span class='deconversion_message'>Your mind begins to fill with haze - your master is no longer[master ? " [master]":""], you are free!</span>")
		owner.current.visible_message("<span class='deconversion_message'>[owner.current] looks like [owner.current.p_theyve()] been freed from the chains of the Mansus!</span>")

	master = null
	return ..()

/datum/antagonist/heretic_monster/add_owner_to_gamemode()
	SSticker.mode.heretics += owner

/datum/antagonist/heretic_monster/remove_owner_from_gamemode()
	SSticker.mode.heretics -= owner
/*
 * Set our [master] var to a new mind.
 */
/datum/antagonist/heretic_monster/proc/set_owner(datum/mind/master)
	src.master = master
	//owner.enslave_mind_to_creator(master.current)

	add_antag_objective(/datum/objective/assist_master)

/datum/objective/assist_master
	explanation_text = "Assist your master."
	completed = TRUE
	needs_target = FALSE

/datum/antagonist/heretic_monster/greet()
	var/list/messages = list()
	messages.Add("<span class='boldnotice'>You are a [ishuman(owner.current) ? "shambling corpse returned":"horrible creation brought"] to this plane through the Gates of the Mansus.</span>")
	messages.Add("<span class='notice'>Your master is [master]. Assist them to all ends.</span>")
	SEND_SOUND(owner.current, sound('sound/ambience/antag/heretic/heretic_gain.ogg'))
	return messages
