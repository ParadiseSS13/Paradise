/mob/living/silicon/pai/death(gibbed)
	if(stat == DEAD)	return
	if(canmove || resting)
		var/turf/T = get_turf_or_move(loc)
		for (var/mob/M in viewers(T))
			M.show_message("\red [src] emits a dull beep before it loses power and collapses.", 3, "\red You hear a dull beep followed by the sound of glass crunching.", 2)
		name = "pAI debris"
		desc = "The unfortunate remains of some poor personal AI device."
		icon_state = "[chassis]_dead"
	else
		card.overlays.Cut()
		card.overlays += "pai-off"
	stat = DEAD
	canmove = 0
	if(blind)	blind.layer = 0
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	//var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	//mind.store_memory("Time of death: [tod]", 0)

	//New pAI's get a brand new mind to prevent meta stuff from their previous life. This new mind causes problems down the line if it's not deleted here.
	//Read as: I have no idea what I'm doing but asking for help got me nowhere so this is what you get. - Nodrak
	if(mind)	qdel(mind)
	living_mob_list -= src
	ghostize()
	if(icon_state != "[chassis]_dead")
		qdel(src)
