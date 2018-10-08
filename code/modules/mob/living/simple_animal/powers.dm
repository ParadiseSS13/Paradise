/mob/living/simple_animal/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Animal"

	if(stat != CONSCIOUS)
		return

	if(layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		visible_message("<B>[src] scurries to the ground!</B>", "<span class=notice'>You are now hiding.</span>")
	else
		layer = MOB_LAYER
		visible_message("[src] slowly peeks up from the ground...", "<span class=notice'>You have stopped hiding.</span>")
