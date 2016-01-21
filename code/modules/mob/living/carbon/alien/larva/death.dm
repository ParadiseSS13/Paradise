/mob/living/carbon/alien/larva/death(gibbed)
	if(stat == DEAD)	return
	if(healths)			healths.icon_state = "health6"
	stat = DEAD
	icon_state = "larva_dead"

	if(!gibbed)
		visible_message("<span class='name'>[src]</span> lets out a waning high-pitched cry.")
		update_canmove()
		if(client)	blind.layer = 0

	timeofdeath = worldtime2text()
	if(mind)	mind.store_memory("Time of death: [timeofdeath]", 0)
	living_mob_list -= src

	return ..(gibbed)
