/mob/living/silicon/pai/death(gibbed)
	if(stat == DEAD)	return
	if(canmove || resting)
		var/turf/T = get_turf_or_move(loc)
		for (var/mob/M in viewers(T))
			M.show_message("\red A low buzz emanates from [src] as it loses power and falls to the ground, motionless.", 3, "\red You sense the faint smell of burned plastic, and hear a low buzzing noise.", 2)
		var/obj/effect/decal/cleanable/deadpai = new /obj/effect/decal/cleanable/robot_debris(loc)
		deadpai.name = "pAI debris"
		deadpai.desc = "The unfortunate remains of some poor personal AI device. Somebody should clean this up."
		deadpai.icon = 'icons/mob/pai.dmi'
		deadpai.icon_state = "[chassis]_dead"
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
	if(mind)	del(mind)
	living_mob_list -= src
	ghostize()
	del(src)
