/mob/living/simple_animal/death(gibbed)
	. = ..()
	if(!.)	return
	if(nest)
		nest.spawned_mobs -= src
		nest = null
	if(loot.len)
		for(var/i in loot)
			new i(loc)
	if(!gibbed)
		if(death_sound)
			playsound(get_turf(src),death_sound, 200, 1)
		if(deathmessage)
			visible_message("<span class='danger'>\The [src] [deathmessage]</span>")
		else if(!del_on_death)
			visible_message("<span class='danger'>\The [src] stops moving...</span>")
	if(del_on_death)
		ghostize()
		qdel(src)
	else
		health = 0
		icon_state = icon_dead
		density = 0
		lying = 1
	..()
