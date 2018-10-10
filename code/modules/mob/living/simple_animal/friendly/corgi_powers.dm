/mob/living/simple_animal/pet/corgi/verb/chasetail()
	set name = "Chase your tail"
	set desc = "d'awwww."
	set category = "Corgi"
	visible_message("[src] [pick("dances around","chases [p_their()] tail")].","[pick("You dance around","You chase your tail")].")
	spin(20, 1)
