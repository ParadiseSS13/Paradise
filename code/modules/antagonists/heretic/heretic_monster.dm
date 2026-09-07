///Tracking reasons
/datum/antagonist/mindslave/heretic_monster
	name = "\improper Eldritch Horror"
	roundend_category = "Heretics"
	job_rank = ROLE_HERETIC
	antag_hud_type = ANTAG_HUD_HERETIC_BEAST
	antag_hud_name = "heretic_beast"
	master_hud_name = "heretic"

/datum/antagonist/mindslave/heretic_monster/farewell()
	if(owner.current)
		to_chat(owner.current, SPAN_BIGGERDANGER("Your mind begins to fill with haze - your master is no longer[master ? " [master]":""], you are free!"))
		owner.current.visible_message(SPAN_DANGER("[owner.current] looks like [owner.current.p_theyve()] been freed from the chains of the Mansus!"))

	return ..()

/datum/antagonist/mindslave/heretic_monster/Destroy(force, ...)
	if(master.current)
		to_chat(master.current, SPAN_DANGER("The essence of [owner], your servant, fades from your mind."))
	return ..()


/datum/antagonist/mindslave/heretic_monster/add_owner_to_gamemode()
	SSticker.mode.heretics += owner

/datum/antagonist/mindslave/heretic_monster/remove_owner_from_gamemode()
	SSticker.mode.heretics -= owner

/datum/antagonist/mindslave/heretic_monster/greet()
	var/list/messages = list()
	messages.Add(SPAN_BOLDNOTICE("You are a [ishuman(owner.current) ? "shambling corpse returned":"horrible creation brought"] to this plane through the Gates of the Mansus."))
	messages.Add(SPAN_NOTICE("Your master is [master.current.name]. Assist them to all ends."))
	SEND_SOUND(owner.current, sound('sound/ambience/antag/heretic/heretic_gain.ogg'))
	return messages
