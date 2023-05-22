/mob/living/carbon/alien/larva/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"

	if(stat != CONSCIOUS)
		return

	if(layer != ABOVE_NORMAL_TURF_LAYER)
		layer = ABOVE_NORMAL_TURF_LAYER
		visible_message("<B>[src] scurries to the ground!</B>", "<span class='noticealien'>You are now hiding.</span>")
	else
		layer = MOB_LAYER
		visible_message("[src] slowly peeks up from the ground...", "<span class=notice'>You have stopped hiding.</span>")

