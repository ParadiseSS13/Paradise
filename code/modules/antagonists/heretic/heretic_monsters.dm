///Tracking reasons
/datum/antagonist/heretic_monster
	name = "\improper Eldritch Horror"
	roundend_category = "Heretics"
	job_rank = ROLE_HERETIC
	antag_hud_name = "heretic_beast"
	stinger_sound = 'sound/ambience/antag/heretic/heretic_gain.ogg'
	/// Our master (a heretic)'s mind.
	var/datum/mind/master

/datum/antagonist/heretic_monster/on_removal()
	if(!silent)
		if(master?.current)
			to_chat(master.current, "<span class='warning'>The essence of [owner], your servant, fades from your mind.</span>")
		if(owner.current)
			to_chat(owner.current, "<span class='deconversion_message'>Your mind begins to fill with haze - your master is no longer[master ? " [master]":""], you are free!</span>")
			owner.current.visible_message("<span class='deconversion_message'>[owner.current] looks like [owner.current.p_theyve()] been freed from the chains of the Mansus!</span>")

	master = null
	return ..()

/*
 * Set our [master] var to a new mind.
 */
/datum/antagonist/heretic_monster/proc/set_owner(datum/mind/master)
	src.master = master
	owner.enslave_mind_to_creator(master.current)

	var/datum/objective/master_obj = new()
	master_obj.owner = owner
	master_obj.explanation_text = "Assist your master."
	master_obj.completed = TRUE

	objectives += master_obj
	owner.announce_objectives()
	to_chat(owner, "<span class='boldnotice'>You are a [ishuman(owner.current) ? "shambling corpse returned":"horrible creation brought"] to this plane through the Gates of the Mansus.</span>")
	to_chat(owner, "<span class='notice'>Your master is [master]. Assist them to all ends.</span>")
	SEND_SOUND(owner.current, sound('sound/ambience/antag/heretic/heretic_gain.ogg'))
