/mob/living/simple_animal/pet/corgi/verb/chasetail()
	set name = "Chase your tail"
	set desc = "d'awwww."
	set category = "Corgi"
	to_chat(src, text("[pick("You dance around","You chase your tail")]."))
	for(var/mob/O in oviewers(src, null))
		if((O.client && !( O.blinded )))
			to_chat(O, text("[] [pick("dances around","chases its tail")].", src))
			spin(20, 1)