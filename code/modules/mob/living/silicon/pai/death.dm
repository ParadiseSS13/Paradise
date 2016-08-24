/mob/living/silicon/pai/death(gibbed, cleanWipe)
	. = ..()
	if(!.)
		return

	if(!cleanWipe)
		force_fold_out()

	visible_message("<span class=warning>[src] emits a dull beep before it loses power and collapses.</span>", "<span class=warning>You hear a dull beep followed by the sound of glass crunching.</span>")
	name = "pAI debris"
	desc = "The unfortunate remains of some poor personal AI device."
	icon_state = "[chassis]_dead"

	// Can we move this up into a higher level of `death`?
	update_canmove()
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	//New pAI's get a brand new mind to prevent meta stuff from their previous life. This new mind causes problems down the line if it's not deleted here.
	//Read as: I have no idea what I'm doing but asking for help got me nowhere so this is what you get. - Nodrak
	// Causes problems? SURE WHY NOT, LETS FIND OUT! -- Crazylemon
	// if(mind)	qdel(mind)

	// pAIs don't get to hang out in their body after death - unlink the mind
	ghostize()
	mind.current = null
	mind = null
	if(icon_state != "[chassis]_dead" || cleanWipe)
		qdel(src)
